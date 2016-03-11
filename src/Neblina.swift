//
//  File.swift
//  NeblinaCtrlPanel
//
//  Created by Hoan Hoang on 2015-10-07.
//  Copyright © 2015 Hoan Hoang. All rights reserved.
//

import Foundation
import CoreBluetooth

struct NebCmdItem {
	let SubSysId : Int32
	let	CmdId : Int32
	let Name : String
	let Actuator : Int
}

let NebCmdList = [NebCmdItem] (arrayLiteral:
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_DEBUG, CmdId: DEBUG_CMD_SET_INTERFACE, Name: "Set Interface (BLE/UART)", Actuator : 1),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_MOTION_ENG, CmdId: Quaternion, Name: "Quaternion Stream", Actuator : 1),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_MOTION_ENG, CmdId: MAG_Data, Name: "Mag Stream", Actuator : 1),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_MOTION_ENG, CmdId: LockHeadingRef, Name: "Lock Heading Ref.", Actuator : 1),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_STORAGE, CmdId: FlashEraseAll, Name: "Flash Erase All", Actuator : 1),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_STORAGE, CmdId: FlashRecordStartStop, Name: "Flash Record", Actuator : 1),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_STORAGE, CmdId: FlashPlaybackStartStop, Name: "Flash Playback", Actuator : 1),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_LED, CmdId: LED_CMD_SET_VALUE, Name: "Set LED0", Actuator : 1),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_LED, CmdId: LED_CMD_SET_VALUE, Name: "Set LED1", Actuator : 1),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_EEPROM, CmdId: EEPROM_Read, Name: "EEPROM Read", Actuator : 0)
)

// BLE custom UUID
let NEB_SERVICE_UUID = CBUUID (string:"0df9f021-1532-11e5-8960-0002a5d5c51b")
let NEB_DATACHAR_UUID = CBUUID (string:"0df9f022-1532-11e5-8960-0002a5d5c51b")
let NEB_CTRLCHAR_UUID = CBUUID (string:"0df9f023-1532-11e5-8960-0002a5d5c51b")

class Neblina : NSObject, CBPeripheralDelegate {
	var id : UInt64 = 0
	var device : CBPeripheral!
	var dataChar : CBCharacteristic! = nil
	var ctrlChar : CBCharacteristic! = nil
	var NebPkt = NEB_PKT()//(SubSys: 0, Len: 0, Crc: 0, Data: [UInt8](count:17, repeatedValue:0)
	var fp = Fusion_DataPacket_t()
	var delegate : NeblinaDelegate!
	var devid : UInt64 = 0
	var packetCnt : UInt32 = 0		// Data packet count
	var startTime : UInt64 = 0
	var currTime : UInt64 = 0
	var dataRate : Float = 0.0
	var timeBaseInfo = mach_timebase_info(numer: 0, denom:0)
	
	func getCmdIdx(subsysId : Int32, cmdId : Int32) -> Int {
		for (idx, item) in NebCmdList.enumerate() {
			if (item.SubSysId == subsysId && item.CmdId == cmdId) {
				return idx
			}
		}
		
		return -1
	}
	
	func setPeripheral(devid : UInt64, peripheral : CBPeripheral) {
		device = peripheral
		id = devid
		device!.delegate = self
		//while (device.state != CBPeripheralState.Connected) {}
		if (device.state == CBPeripheralState.Connected)
		{
			device!.discoverServices([NEB_SERVICE_UUID])
		}
		var info = mach_timebase_info(numer: 0, denom:0)
		mach_timebase_info(&timeBaseInfo)

		//print("Device : \(device)")
	}
	
	//
	// CBPeripheral stuffs
	//
	
	func peripheralDidUpdateRSSI(peripheral: CBPeripheral, error: NSError?) {
		if (device.RSSI != nil) {
			delegate.didReceiveRSSI(device.RSSI!)
		}
	}
	
	func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?)
	{
		for service in peripheral.services ?? []
		{
			if (service.UUID .isEqual(NEB_SERVICE_UUID))
			{
				peripheral.discoverCharacteristics(nil, forService: service)
			}
		}
	}
	
	func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?)
	{
		for characteristic in service.characteristics ?? []
		{
			//print("car \(characteristic.UUID)");
			if (characteristic.UUID .isEqual(NEB_DATACHAR_UUID))
			{
				dataChar = characteristic;
				if ((dataChar.properties.rawValue & CBCharacteristicProperties.Notify.rawValue) != 0)
				{
					peripheral.setNotifyValue(true, forCharacteristic: dataChar);
					packetCnt = 0	// reset packet count
					startTime = 0	// reset timer
				}
			}
			if (characteristic.UUID .isEqual(NEB_CTRLCHAR_UUID))
			{
				ctrlChar = characteristic;
				delegate.didConnectNeblina()
			}
		}
	}
	
	func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?)
	{
		//var textView : NSTextView
		//print("Value : \(characteristic.value)")
		
		//let pkt = unsafeBitCast(&NebPkt, UnsafePointer<uint8>.self)
		//let NebPktt = unsafeBitCast(characteristic.value, UnsafePointer<NEB_PKT>.self) //
		//let pkk = UnsafePointer<NEB_PKTX>(characteristic.value)
		///var ppk = NebPacket(SubSys: 0, Len: 0, Crc: 0, Cmd:0, TimeStamp: 0)
		var hdr = NEB_PKTHDR()
		//var hdr = NEB_PKTHDR(Ctrl : (SubSys:0, PkType : 0), Len: 0, Crc: 0, Cmd: 0)
		if (characteristic.UUID .isEqual(NEB_DATACHAR_UUID))
		{
			characteristic.value?.getBytes(&hdr, length: sizeof(NEB_PKTHDR))
			characteristic.value?.getBytes(&NebPkt, length: sizeof(NEB_PKTHDR) + 1)

			let id = Int32(hdr.Cmd) //FusionId(rawValue: hdr.Cmd)
			//print("\(characteristic)")
			var errflag = Bool(false)
			if ((hdr.SubSys  & 0x80) == 0x80)
			{
				errflag = true;
				hdr.SubSys &= 0x7F;
			}
			
			packetCnt++
			
			if (startTime == 0) {
				// first time use
				startTime = mach_absolute_time()
			}
			else {
				currTime = mach_absolute_time()
				let elapse = currTime - startTime
				if (elapse > 0) {
					dataRate = Float(UInt64(packetCnt) * 1000000000 * UInt64(timeBaseInfo.denom)) / Float((currTime - startTime) * UInt64(timeBaseInfo.numer))
				}
			}
			
			switch (Int32(hdr.SubSys))
			{
				case NEB_CTRL_SUBSYS_MOTION_ENG:	// Motion Engine
					//print("\(characteristic.value)")
					characteristic.value?.getBytes(&fp, range: NSMakeRange(sizeof(NEB_PKTHDR), sizeof(Fusion_DataPacket_t)))
					//print("\(characteristic.value)")
					//print("\(fp)")
					////print("\(fdata)")
					//characteristic.value?.getBytes(&fdata, range: NSMakeRange(sizeof(NEB_PKTHDR), sizeof(Fusion_DataPacket_t)))
					//characteristic.value?.getBytes(&fdata.Data[0], range: NSMakeRange(sizeof(NEB_PKTHDR) + 4, 12))
					
					//print("\(fdata)")
			//		let id = Int32(hdr.Cmd) //FusionId(rawValue: hdr.Cmd)
					delegate.didReceiveFusionData(id, data: fp, errFlag: errflag)
					//delegate.didReceiveFusionData(hdr.Cmd, data: fdata)
//					characteristic.value?.getBytes(&ppk, range: NSMakeRange(sizeof(NEB_PKTHDR), 16))
					break
				case NEB_CTRL_SUBSYS_DEBUG:
					var dd = [UInt8](count:16, repeatedValue:0)
					characteristic.value?.getBytes(&dd, range: NSMakeRange(sizeof(NEB_PKTHDR), Int(hdr.Len)))
					delegate.didReceiveDebugData(id, data: dd, errFlag: errflag)
					break
				case NEB_CTRL_SUBSYS_POWERMGMT:
					var dd = [UInt8](count:16, repeatedValue:0)
					characteristic.value?.getBytes(&dd, range: NSMakeRange(sizeof(NEB_PKTHDR), Int(hdr.Len)))
					delegate.didReceivePmgntData(id, data: dd, errFlag: errflag)
					break
				case NEB_CTRL_SUBSYS_STORAGE:
					var dd = [UInt8](count:16, repeatedValue:0)
					characteristic.value?.getBytes(&dd, range: NSMakeRange(sizeof(NEB_PKTHDR), Int(hdr.Len)))
					delegate.didReceiveStorageData(id, data: dd, errFlag: errflag)
					break
				case NEB_CTRL_SUBSYS_EEPROM:
					var dd = [UInt8](count:16, repeatedValue:0)
					characteristic.value?.getBytes(&dd, range: NSMakeRange(sizeof(NEB_PKTHDR), Int(hdr.Len)))
					delegate.didReceiveEepromData(id, data: dd, errFlag: errflag)
					break

				default:
					break
			}
			
		//	NebPkt!.Data = data;
	//		delegate.didReceiveData(NebPkt)
			//print("FusionPacket : \(fp)")
		}
	}
	func isDeviceReady()-> Bool {
		if (device == nil || ctrlChar == nil) {
			return false
		}
		
		if (device.state != CBPeripheralState.Connected) {
			return false
		}
		
		return true
	}
	
	func getPacketCount()-> UInt32 {
		return packetCnt
	}
	
	func getDataRate()->Float {
		return dataRate
	}
	
	// MARK : Fusion Engine Commands
	
	func SendCmdMotionStream(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(MotionState)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}

	func SendCmdSixAxisIMUStream(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(IMU_Data)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdQuaternionStream(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(Quaternion)	// Cmd
		
		if (Enable == true)
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdEulerAngleStream(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(EulerAngle)//FusionId.EulerAngle.rawValue	// Cmd
		
		if (Enable == true)
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdExternalForceStream(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(ExtForce)	// Cmd
		
		if (Enable == true)
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdPedometerStream(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(Pedometer)// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdTrajectoryRecord(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(TrajectoryRecStartStop)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdTrajectoryInfo(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(TrajectoryInfo)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdMagStream(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(MAG_Data)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdSittingStanding(Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(SittingStanding)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdLockHeading(Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(LockHeadingRef)	// Cmd
		
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdSetAccRange(Mode: UInt8) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = 16 //UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(SetAccRange)	// Cmd
		pkbuf[8] = Mode
		
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdDisableAllStreaming()
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG)
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(DisableAllStreaming)	// Cmd
		
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdResetTimeStamp() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG)
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(ResetTimeStamp)	// Cmd
		
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdRotationInfo(Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(RotationInfo)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	// MARK : Storage subsystem commands
	
	func SendCmdFlashErase(Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_STORAGE) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(FlashEraseAll) // FusionId.FlashEraseAll.rawValue // RecorderErase.rawValue	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
		
	}
	
	func SendCmdFlashRecord(Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_STORAGE) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(FlashRecordStartStop)//FusionId.FlashRecordStartStop.rawValue	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdFlashPlayback(Enable:Bool, sessionId : UInt16) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_STORAGE)
		pkbuf[1] = 16//UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(FlashPlaybackStartStop) //FusionId.FlashPlaybackStartStop.rawValue	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		
		pkbuf[9] = UInt8(sessionId & 0xff)
		pkbuf[10] = UInt8((sessionId >> 8) & 0xff)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdFlashGetNbSession() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_STORAGE)
		pkbuf[1] = 16//UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(FlashGetNbSessions) //FusionId.FlashPlaybackStartStop.rawValue	// Cmd
		
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdFlashGetSessionInfo(sessionId : UInt16) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_STORAGE)
		pkbuf[1] = 16//UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(FlashGetSessionInfo) //FusionId.FlashPlaybackStartStop.rawValue	// Cmd
		
		pkbuf[8] = UInt8(sessionId & 0xff)
		pkbuf[9] = UInt8((sessionId >> 8) & 0xff)
		
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdEepromRead(pageNo : UInt16) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_EEPROM)
		pkbuf[1] = 16//UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(EEPROM_Read) // Cmd
		
		pkbuf[4] = UInt8(pageNo & 0xff)
		pkbuf[5] = UInt8((pageNo >> 8) & 0xff)
		
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func SendCmdEepromWrite(pageNo : UInt16, data : UnsafePointer<UInt8>) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_EEPROM)
		pkbuf[1] = 16//UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(EEPROM_Write) // Cmd
		
		pkbuf[4] = UInt8(pageNo & 0xff)
		pkbuf[5] = UInt8((pageNo >> 8) & 0xff)
		
		for (var i = 0; i < 8; i++) {
			pkbuf[i + 6] = data[i]
		}
		
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	// MARK : Debug subsystem commands
	
	func SendCmdGetFirmwareVersions() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_DEBUG)
		pkbuf[1] = 16
		pkbuf[2] = 0
		pkbuf[3] = UInt8(DEBUG_CMD_GET_FW_VERSION)	// Cmd
		
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 4), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}

	func SendCmdControlInterface(Interf : Int) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_DEBUG) // 0x40
		pkbuf[1] = 16//UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = 1//FusionId.FlashPlaybackStartStop.rawValue	// Cmd
		
		// Interf = 0 : BLE
		// Interf = 1 : UART
		pkbuf[4] = UInt8(Interf)
		//pkbuf[9] = 0xff
		//pkbuf[10] = 0xff
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	
	func SendCmdEngineStatus() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_DEBUG)
		pkbuf[1] = 16//UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(DEBUG_CMD_MOTENGINE_RECORDER_STATUS)	// Cmd
		
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}

	// MARK : LED subsystem commands
	
	func SendCmdLedSetValue(LedNo : UInt8, Value:UInt8) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_LED)
		pkbuf[1] = 16//UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(LED_CMD_SET_VALUE)	// Cmd
		
		// Nb of LED to set
		pkbuf[4] = 1
		pkbuf[5] = LedNo
		pkbuf[6] = Value
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	// MARK : Power management sybsystem commands
	
	func SendCmdGetTemperature() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_POWERMGMT)
		pkbuf[1] = 0//UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(POWERMGMT_CMD_GET_TEMPERATURE)	// Cmd
		
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 4), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
}

protocol NeblinaDelegate {
	
	func didConnectNeblina()
	func didReceiveRSSI(rssi : NSNumber)
	func didReceiveFusionData(type : Int32, data : Fusion_DataPacket_t, errFlag : Bool)
	func didReceiveDebugData(type : Int32, data : UnsafePointer<UInt8>, errFlag : Bool)
	func didReceivePmgntData(type : Int32, data : UnsafePointer<UInt8>, errFlag : Bool)
	func didReceiveStorageData(type : Int32, data : UnsafePointer<UInt8>, errFlag : Bool)
	func didReceiveEepromData(type : Int32, data : UnsafePointer<UInt8>, errFlag : Bool)
}

//
//  File.swift
//  NeblinaCtrlPanel
//
//  Created by Hoan Hoang on 2015-10-07.
//  Copyright © 2015 Hoan Hoang. All rights reserved.
//

import Foundation
import CoreBluetooth

// BLE custom UUID
let NEB_SERVICE_UUID = CBUUID (string:"0df9f021-1532-11e5-8960-0002a5d5c51b")
let NEB_DATACHAR_UUID = CBUUID (string:"0df9f022-1532-11e5-8960-0002a5d5c51b")
let NEB_CTRLCHAR_UUID = CBUUID (string:"0df9f023-1532-11e5-8960-0002a5d5c51b")

class Neblina : NSObject, CBPeripheralDelegate {
	var id : UInt64 = 0
	var device : CBPeripheral!
	var dataChar : CBCharacteristic! = nil
	var ctrlChar : CBCharacteristic! = nil
	var NebPkt = NEB_PKT()
	var fp = Fusion_DataPacket_t()
	var delegate : NeblinaDelegate!
	var devid : UInt64 = 0
	var packetCnt : UInt32 = 0		// Data packet count
	var startTime : UInt64 = 0
	var currTime : UInt64 = 0
	var dataRate : Float = 0.0
	var timeBaseInfo = mach_timebase_info(numer: 0, denom:0)
	
	init(devid : UInt64, peripheral : CBPeripheral?) {
		super.init()
		if (peripheral != nil) {
			id = devid
			device = peripheral
			device.delegate = self
		}
		else {
			id = 0
			device = nil
		}
	}
	func setPeripheral(devid : UInt64, peripheral : CBPeripheral) {
		device = peripheral
		id = devid
		device.delegate = self
		device.discoverServices([NEB_SERVICE_UUID])
		_ = mach_timebase_info(numer: 0, denom:0)
		mach_timebase_info(&timeBaseInfo)
	}
	
	func connected(peripheral : CBPeripheral) {
		device.discoverServices([NEB_SERVICE_UUID])
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
					print("Data \(characteristic.UUID)");
					peripheral.setNotifyValue(true, forCharacteristic: dataChar);
					packetCnt = 0	// reset packet count
					startTime = 0	// reset timer
				}
			}
			if (characteristic.UUID .isEqual(NEB_CTRLCHAR_UUID))
			{
				print("Ctrl \(characteristic.UUID)");
				ctrlChar = characteristic;
			}
		}
	}
	
	func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?)
	{
		if (delegate != nil) {
			delegate.didConnectNeblina()
		}
	}
	
	func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?)
	{
		var hdr = NEB_PKTHDR()
		if (characteristic.UUID .isEqual(NEB_DATACHAR_UUID))
		{
			characteristic.value?.getBytes(&hdr, length: sizeof(NEB_PKTHDR))
			characteristic.value?.getBytes(&NebPkt, length: sizeof(NEB_PKTHDR) + 1)

			let id = Int32(hdr.Cmd)
			var errflag = Bool(false)
			

			if (Int32(hdr.PkType) == NEB_CTRL_PKTYPE_ACK) {
				//print("ACK : \(characteristic.value)")
				return
			}
			
		/*	if ((hdr.SubSys  & 0x80) == 0x80)
			{
				errflag = true;
				hdr.SubSys &= 0x7F;
			}*/
			if (Int32(hdr.PkType) == NEB_CTRL_PKTYPE_ERR)
			{
				errflag = true;
			}
			
			packetCnt += 1
			
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
					characteristic.value?.getBytes(&fp, range: NSMakeRange(sizeof(NEB_PKTHDR), sizeof(Fusion_DataPacket_t)))
					delegate.didReceiveFusionData(id, data: fp, errFlag: errflag)
					break
				case NEB_CTRL_SUBSYS_DEBUG:
					var dd = [UInt8](count:16, repeatedValue:0)
					characteristic.value?.getBytes(&dd, range: NSMakeRange(sizeof(NEB_PKTHDR), Int(hdr.Len)))
					delegate.didReceiveDebugData(id, data: dd, dataLen: Int(hdr.Len), errFlag: errflag)
					break
				case NEB_CTRL_SUBSYS_POWERMGMT:
					var dd = [UInt8](count:16, repeatedValue:0)
					characteristic.value?.getBytes(&dd, range: NSMakeRange(sizeof(NEB_PKTHDR), Int(hdr.Len)))
					delegate.didReceivePmgntData(id, data: dd, dataLen: Int(hdr.Len), errFlag: errflag)
					break
				case NEB_CTRL_SUBSYS_STORAGE:
					var dd = [UInt8](count:16, repeatedValue:0)
					characteristic.value?.getBytes(&dd, range: NSMakeRange(sizeof(NEB_PKTHDR), Int(hdr.Len)))
					delegate.didReceiveStorageData(id, data: dd, dataLen: Int(hdr.Len), errFlag: errflag)
					break
				case NEB_CTRL_SUBSYS_EEPROM:
					var dd = [UInt8](count:16, repeatedValue:0)
					characteristic.value?.getBytes(&dd, range: NSMakeRange(sizeof(NEB_PKTHDR), Int(hdr.Len)))
					delegate.didReceiveEepromData(id, data: dd, dataLen: Int(hdr.Len), errFlag: errflag)
					break
				case NEB_CTRL_SUBSYS_LED:
					var dd = [UInt8](count:16, repeatedValue:0)
					characteristic.value?.getBytes(&dd, range: NSMakeRange(sizeof(NEB_PKTHDR), Int(hdr.Len)))
					delegate.didReceiveLedData(id, data: dd, dataLen: Int(hdr.Len), errFlag: errflag)
					break

				default:
					break
			}
			
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
	
	// MARK : **** API
	func crc8(data : [UInt8], Len : Int) -> UInt8
	{
		var i = Int(0)
		var e = UInt8(0)
		var f = UInt8(0)
		var crc = UInt8(0)
		
		//for (i = 0; i < Len; i += 1)
		while i < Len {
			e = crc ^ data[i];
			f = e ^ (e >> 4) ^ (e >> 7);
			crc = (f << 1) ^ (f << 4);
			i += 1
		}
	
		return crc;
	}

	// Debug
	func getDataPortState() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_DEBUG) // 0x40
		pkbuf[1] = 0	// Data len
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(DEBUG_CMD_GET_DATAPORT)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 4), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func getFirmwareVersion() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_DEBUG)
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(DEBUG_CMD_GET_FW_VERSION)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 4), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func getMotionStatus() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_DEBUG)
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(DEBUG_CMD_MOTENGINE_RECORDER_STATUS)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func getRecorderStatus() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_DEBUG)
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(DEBUG_CMD_MOTENGINE_RECORDER_STATUS)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func setDataPort(PortIdx : Int, Ctrl : UInt8) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_DEBUG) // 0x40
		pkbuf[1] = 2
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(DEBUG_CMD_SET_DATAPORT)	// Cmd
		
		// Port = 0 : BLE
		// Port = 1 : UART
		pkbuf[4] = UInt8(PortIdx)
		pkbuf[5] = Ctrl		// 1 - Open, 0 - Close
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 6), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func setInterface(Interf : Int) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_DEBUG) // 0x40
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(DEBUG_CMD_SET_INTERFACE)	// Cmd
		
		// Interf = 0 : BLE
		// Interf = 1 : UART
		pkbuf[4] = UInt8(Interf)
		pkbuf[8] = 0
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	// *** EEPROM
	func eepromRead(pageNo : UInt16) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_EEPROM)
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(EEPROM_Read) // Cmd
		
		pkbuf[4] = UInt8(pageNo & 0xff)
		pkbuf[5] = UInt8((pageNo >> 8) & 0xff)
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func eepromWrite(pageNo : UInt16, data : UnsafePointer<UInt8>) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_EEPROM)
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(EEPROM_Write) // Cmd
		
		pkbuf[4] = UInt8(pageNo & 0xff)
		pkbuf[5] = UInt8((pageNo >> 8) & 0xff)
		
		for (var i = 0; i < 8; i += 1) {
			pkbuf[i + 6] = data[i]
		}
		
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	// *** LED subsystem commands
	func getLed() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_LED)
		pkbuf[1] = 0	// Data length
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(LED_CMD_GET_VALUE)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 4), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func setLed(LedNo : UInt8, Value:UInt8) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_LED)
		pkbuf[1] = 16 //UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(LED_CMD_SET_VALUE)	// Cmd
		
		// Nb of LED to set
		pkbuf[4] = 1
		pkbuf[5] = LedNo
		pkbuf[6] = Value
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	// *** Power management sybsystem commands
	func getTemperature() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_POWERMGMT)
		pkbuf[1] = 0	// Data length
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(POWERMGMT_CMD_GET_TEMPERATURE)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 4), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func setBatteryChargeCurrent(Current: UInt16) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_POWERMGMT)
		pkbuf[1] = 2	// Data length
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(POWERMGMT_CMD_SET_CHARGE_CURRENT)	// Cmd
		
		// Data
		pkbuf[4] = UInt8(Current & 0xFF)
		pkbuf[5] = UInt8((Current >> 8) & 0xFF)
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 6), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}

	// *** Motion Settings
	func setAccelerometerRange(Mode: UInt8) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(SetAccRange)	// Cmd
		pkbuf[8] = Mode
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func setFusionType(Mode:UInt8) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(SetFusionType)	// Cmd
		
		// Data
		pkbuf[8] = Mode
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func setLockHeadingReference(Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(LockHeadingRef)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	// *** Motion Streaming Send
	func streamDisableAll()
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG)
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(DisableAllStreaming)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func streamEulerAngle(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(EulerAngle)// Cmd
		
		if (Enable == true)
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func streamExternalForce(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(ExtForce)	// Cmd
		
		if (Enable == true)
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func streamIMU(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(IMU_Data)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func streamMAG(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(MAG_Data)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func streamMotionState(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(MotionState)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}

	func streamPedometer(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(Pedometer)// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func streamQuaternion(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(Quaternion)	// Cmd
		
		if (Enable == true)
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func streamRotationInfo(Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(RotationInfo)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func streamSittingStanding(Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(SittingStanding)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func streamTrajectoryInfo(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(TrajectoryInfo)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	// *** Motion utilities
	func resetTimeStamp() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG)
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(ResetTimeStamp)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func recordTrajectory(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(TrajectoryRecStartStop)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	// *** Storage subsystem commands
	func getSessionCount() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_STORAGE)
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(FlashGetNbSessions) // Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func getSessionInfo(sessionId : UInt16) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_STORAGE)
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(FlashGetSessionInfo) // Cmd
		
		pkbuf[8] = UInt8(sessionId & 0xff)
		pkbuf[9] = UInt8((sessionId >> 8) & 0xff)
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func eraseStorage(Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_STORAGE) //0x41
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(FlashEraseAll) // Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
		
	}
	
	func sessionPlayback(Enable:Bool, sessionId : UInt16) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_STORAGE)
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(FlashPlaybackStartStop) // Cmd
		
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
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func sessionRecord(Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_STORAGE) //0x41
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(FlashRecordStartStop)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func sessionRead(SessionId:UInt16, Len:UInt16, Offset:UInt32) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_STORAGE) //0x41
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(FlashSessionRead)	// Cmd

		// Command parameter
		pkbuf[4] = UInt8(SessionId & 0xFF)
		pkbuf[5] = UInt8((SessionId >> 8) & 0xFF)
		pkbuf[6] = UInt8(Len & 0xFF)
		pkbuf[7] = UInt8((Len >> 8) & 0xFF)
		pkbuf[8] = UInt8(Offset & 0xFF)
		pkbuf[9] = UInt8((Offset >> 8) & 0xFF)
		pkbuf[10] = UInt8((Offset >> 16) & 0xFF)
		pkbuf[11] = UInt8((Offset >> 24) & 0xFF)
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
}

protocol NeblinaDelegate {
	
	func didConnectNeblina()
	func didReceiveRSSI(rssi : NSNumber)
	func didReceiveFusionData(type : Int32, data : Fusion_DataPacket_t, errFlag : Bool)
	func didReceiveDebugData(type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceivePmgntData(type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveStorageData(type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveEepromData(type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveLedData(type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
}

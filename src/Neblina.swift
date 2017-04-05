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

let ACTUATOR_TYPE_SWITCH			= 1
let ACTUATOR_TYPE_BUTTON			= 2
let ACTUATOR_TYPE_TEXT_FIELD		= 3
let ACTUATOR_TYPE_TEXT_FILED_BUTTON	= 4

struct NebCmdItem {
	let SubSysId : Int32		// Neblina subsystem
	let	CmdId : Int32			// Neblina command ID
	let ActiveStatus : UInt32	// Match value to indicate on state
	let Name : String			// Command item name string
	let Actuator : Int			// ACTUATOR_TYPE
	let Text : String			// Text to display on actuator if avail
}

class Neblina : NSObject, CBPeripheralDelegate {
	var id = UInt64(0)
	var device : CBPeripheral!
	var dataChar : CBCharacteristic! = nil
	var ctrlChar : CBCharacteristic! = nil
	var NebPkt = NeblinaPacket_t()
	var fp = NeblinaFusionPacket()
	var delegate : NeblinaDelegate!
	//var devid : UInt64 = 0
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

	func crc8(_ data : [UInt8], Len : Int) -> UInt8
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
	
	func setPeripheral(_ devid : UInt64, peripheral : CBPeripheral) {
		device = peripheral
		id = devid
		device.delegate = self
		device.discoverServices([NEB_SERVICE_UUID])
		_ = mach_timebase_info(numer: 0, denom:0)
		mach_timebase_info(&timeBaseInfo)
	}
	
	func connected(_ peripheral : CBPeripheral) {
		device.discoverServices([NEB_SERVICE_UUID])
		
	}

	//
	// CBPeripheral stuffs
	//
	
	func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
		if (device.rssi != nil) {
			delegate.didReceiveRSSI(sender: self, rssi: device.rssi!)
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
	{
		for service in peripheral.services ?? []
		{
			if (service.uuid .isEqual(NEB_SERVICE_UUID))
			{
				peripheral.discoverCharacteristics(nil, for: service)
			}
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
	{
		for characteristic in service.characteristics ?? []
		{
			//print("car \(characteristic.UUID)");
			if (characteristic.uuid .isEqual(NEB_DATACHAR_UUID))
			{
				dataChar = characteristic;
				if ((dataChar.properties.rawValue & CBCharacteristicProperties.notify.rawValue) != 0)
				{
					print("Data \(characteristic.uuid)");
					peripheral.setNotifyValue(true, for: dataChar);
					packetCnt = 0	// reset packet count
					startTime = 0	// reset timer
				}
			}
			if (characteristic.uuid .isEqual(NEB_CTRLCHAR_UUID))
			{
				print("Ctrl \(characteristic.uuid)");
				ctrlChar = characteristic;
			}
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?)
	{
		if (delegate != nil) {
			delegate.didConnectNeblina(sender: self)
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
	{
		var hdr = NeblinaPacketHeader_t()
		if (characteristic.uuid .isEqual(NEB_DATACHAR_UUID) && characteristic.value != nil && (characteristic.value?.count)! > 0)
		{
			var ch = [UInt8](repeating: 0, count: 20)
			characteristic.value?.copyBytes(to: &ch, count: (characteristic.value?.count)!)//min(MemoryLayout<NeblinaPacketHeader_t>.size, (characteristic.value?.count)!))
			hdr = (characteristic.value?.withUnsafeBytes{ (ptr: UnsafePointer<NeblinaPacketHeader_t>) -> NeblinaPacketHeader_t in return ptr.pointee })!
			let respId = Int32(hdr.command)
			var errflag = Bool(false)
			
			let crc = ch[2]
			ch[2] = 0xFF
			let crc2 = crc8(ch, Len: Int(ch[1]) + 4)
			if crc != crc8(ch, Len: Int(ch[1]) + 4) {
				print("\(crc) CRC ERROR!!!  \(crc2)")
				print("\(ch) ")
				return
			}
			
			if (Int32(hdr.packetType) == NEBLINA_PACKET_TYPE_ACK) {
				//print("ACK : \(characteristic.value) \(hdr)")
				return
			}
			
			if (Int32(hdr.packetType) == NEBLINA_PACKET_TYPE_ERROR)
			{
				errflag = true;
				print("Error returned  \(hdr)")
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
			var pkdata = [UInt8](repeating: 0, count: 20)
			//print("\(characteristic.value) ")
			//(characteristic.value as Data).copyBytes(to: &dd, from:4)
			if (hdr.length > 0) {
				characteristic.value?.copyBytes (to: &pkdata, from: Range(MemoryLayout<NeblinaPacketHeader_t>.size..<(Int(hdr.length) + MemoryLayout<NeblinaPacketHeader_t>.size)))
			}
			//print("\(self) Receive : \(hdr) : \(pkdata) : \(ch)")
			
			if delegate == nil {
				return
			}
			
			switch (Int32(hdr.subSystem))
			{
				case NEBLINA_SUBSYSTEM_GENERAL:
					var dd = [UInt8](repeating: 0, count: 16)
					//(characteristic.value as Data).copyBytes(to: &dd, from:4)
					if (hdr.length > 0) {
						//print("Debug \(hdr.Len)")
						characteristic.value?.copyBytes (to: &dd, from: Range(MemoryLayout<NeblinaPacketHeader_t>.size..<Int(hdr.length) + MemoryLayout<NeblinaPacketHeader_t>.size))
					}

					delegate.didReceiveGeneralData(sender: self, respType: Int32(hdr.packetType), cmdRspId: respId, data: dd, dataLen: Int(hdr.length), errFlag: errflag)
					break
				case NEBLINA_SUBSYSTEM_FUSION:	// Motion Engine
					let dd = (characteristic.value?.subdata(in: Range(4..<Int(hdr.length)+MemoryLayout<NeblinaPacketHeader_t>.size)))!
					fp = (dd.withUnsafeBytes{ (ptr: UnsafePointer<NeblinaFusionPacket>) -> NeblinaFusionPacket in return ptr.pointee })
					delegate.didReceiveFusionData(sender: self, respType: Int32(hdr.packetType), cmdRspId: respId, data: fp, errFlag: errflag)
					break
				case NEBLINA_SUBSYSTEM_POWER:
					var dd = [UInt8](repeating: 0, count: 16)
					if (hdr.length > 0) {
						characteristic.value?.copyBytes (to: &dd, from: Range(MemoryLayout<NeblinaPacketHeader_t>.size..<Int(hdr.length) + MemoryLayout<NeblinaPacketHeader_t>.size))
					}
					delegate.didReceivePmgntData(sender: self, respType: Int32(hdr.packetType), cmdRspId: respId, data: dd, dataLen: Int(hdr.length), errFlag: errflag)
					break
				case NEBLINA_SUBSYSTEM_LED:
					var dd = [UInt8](repeating: 0, count: 16)
					if (hdr.length > 0) {
						characteristic.value?.copyBytes (to: &dd, from: Range(MemoryLayout<NeblinaPacketHeader_t>.size..<Int(hdr.length) + MemoryLayout<NeblinaPacketHeader_t>.size))
					}
					delegate.didReceiveLedData(sender: self, respType: Int32(hdr.packetType), cmdRspId: respId, data: dd, dataLen: Int(hdr.length), errFlag: errflag)
					break
				case NEBLINA_SUBSYSTEM_DEBUG:
					var dd = [UInt8](repeating: 0, count: 16)
					//(characteristic.value as Data).copyBytes(to: &dd, from:4)
					if (hdr.length > 0) {
						//print("Debug \(hdr.Len)")
						characteristic.value?.copyBytes (to: &dd, from: Range(MemoryLayout<NeblinaPacketHeader_t>.size..<Int(hdr.length) + MemoryLayout<NeblinaPacketHeader_t>.size))
					}
				
					delegate.didReceiveDebugData(sender: self, respType: Int32(hdr.packetType), cmdRspId: respId, data: dd, dataLen: Int(hdr.length), errFlag: errflag)
					break
				case NEBLINA_SUBSYSTEM_RECORDER:
					var dd = [UInt8](repeating: 0, count: 16)
					if (hdr.length > 0) {
						characteristic.value?.copyBytes (to: &dd, from: Range(MemoryLayout<NeblinaPacketHeader_t>.size..<Int(hdr.length) + MemoryLayout<NeblinaPacketHeader_t>.size))
					}
					delegate.didReceiveRecorderData(sender: self, respType: Int32(hdr.packetType), cmdRspId: respId, data: dd, dataLen: Int(hdr.length), errFlag: errflag)
					break
				case NEBLINA_SUBSYSTEM_EEPROM:
					var dd = [UInt8](repeating: 0, count: 16)
					if (hdr.length > 0) {
						characteristic.value?.copyBytes (to: &dd, from: Range(MemoryLayout<NeblinaPacketHeader_t>.size..<Int(hdr.length) + MemoryLayout<NeblinaPacketHeader_t>.size))
					}
					delegate.didReceiveEepromData(sender: self, respType : Int32(hdr.packetType), cmdRspId: respId, data: dd, dataLen: Int(hdr.length), errFlag: errflag)
					break
				case NEBLINA_SUBSYSTEM_SENSOR:
					var dd = [UInt8](repeating: 0, count: 16)
					if (hdr.length > 0) {
						characteristic.value?.copyBytes (to: &dd, from: Range(MemoryLayout<NeblinaPacketHeader_t>.size..<Int(hdr.length) + MemoryLayout<NeblinaPacketHeader_t>.size))
					}
					delegate.didReceiveSensorData(sender: self, respType : Int32(hdr.packetType), cmdRspId: respId, data: dd, dataLen: Int(hdr.length), errFlag: errflag)
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
		
		if (device.state != CBPeripheralState.connected) {
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
	
	//
	// MARK : **** API
	//
	func sendCommand(subSys : Int32, cmd : Int32, paramLen : Int, paramData : [UInt8] ) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | subSys)
		pkbuf[1] = UInt8(paramLen)		// Data length
		pkbuf[2] = 0xFF			// CRC
		pkbuf[3] = UInt8(cmd)	// Cmd
		
		for i in 0..<paramLen {
			pkbuf[4 + i] = paramData[i]
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	// ********************************
	// * Neblina Command API
	// ********************************
	//
	// ***
	// *** Subsystem General
	// ***
	func getSystemStatus() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_SYSTEM_STATUS, paramLen: 0, paramData: [0])
	}

	func getFusionStatus() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_FUSION_STATUS, paramLen: 0, paramData: [0])
	}
	
	func getRecorderStatus() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_RECORDER_STATUS, paramLen: 0, paramData: [0])
	}
	
	func getFirmwareVersion() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_FIRMWARE_VERSION, paramLen: 0, paramData: [0])
	}
	
	func getDataPortState() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_INTERFACE_STATUS, paramLen: 0, paramData: [0])
	}
	
	func setDataPort(_ PortIdx : Int, Ctrl : UInt8) {
		var param = [UInt8](repeating: 0, count: 2)

		param[0] = UInt8(PortIdx)
		param[1] = Ctrl		// 1 - Open, 0 - Close
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_INTERFACE_STATE, paramLen: 2, paramData: param)
	}
	
	func getPowerStatus() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_POWER_STATUS, paramLen: 0, paramData: [0])
	}

	func getSensorStatus() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_SENSOR_STATUS, paramLen: 0, paramData: [0])
	}
	
	func disableStreaming() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_DISABLE_STREAMING, paramLen: 0, paramData: [0])
	}

	func resetTimeStamp( Delayed : Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Delayed == true {
			param[0] = 1
		}
		else {
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_RESET_TIMESTAMP, paramLen: 1, paramData: param)
	}
	
	func firmwareUpdate() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_FIRMWARE_UPDATE, paramLen: 0, paramData: [0])
	}
	
	func getDeviceName() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_DEVICE_NAME_GET, paramLen: 0, paramData: [0])
	}
	
	func setDeviceName(name : String) {
		let param = [UInt8](name.utf8)
		
		var len = param.count
		if len > Int(NEBLINA_NAME_LENGTH_MAX) {
			len = Int(NEBLINA_NAME_LENGTH_MAX)
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_GENERAL, cmd: NEBLINA_COMMAND_GENERAL_DEVICE_NAME_SET, paramLen: len, paramData: param)
	}
	
	// ***
	// *** EEPROM
	// ***
	func eepromRead(_ pageNo : UInt16) {
		var param = [UInt8](repeating: 0, count: 2)

		param[0] = UInt8(pageNo & 0xff)
		param[1] = UInt8((pageNo >> 8) & 0xff)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_EEPROM, cmd: NEBLINA_COMMAND_EEPROM_READ, paramLen: param.count, paramData: param)
	}
	
	func eepromWrite(_ pageNo : UInt16, data : UnsafePointer<UInt8>) {
		var param = [UInt8](repeating: 0, count: 10)
		
		param[0] = UInt8(pageNo & 0xff)
		param[1] = UInt8((pageNo >> 8) & 0xff)
		for i in 0..<8 {
			param[i + 2] = data[i]
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_EEPROM, cmd: NEBLINA_COMMAND_EEPROM_WRITE, paramLen: param.count, paramData: param)
	}
	
	// *** LED subsystem commands
	func getLed() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_LED, cmd: NEBLINA_COMMAND_LED_STATUS, paramLen: 0, paramData: [0])
	}
	
	func setLed(_ LedNo : UInt8, Value:UInt8) {
		var param = [UInt8](repeating: 0, count: 2)
		
		param[0] = LedNo
		param[1] = Value
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_LED, cmd: NEBLINA_COMMAND_LED_STATE, paramLen: param.count, paramData: param)
	}
	
	// *** Power management sybsystem commands
	func getTemperature() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_POWER, cmd: NEBLINA_COMMAND_POWER_TEMPERATURE, paramLen: 0, paramData: [0])
	}
	
	func setBatteryChargeCurrent(_ Current: UInt16) {
		var param = [UInt8](repeating: 0, count: 2)
		
		param[0] = UInt8(Current & 0xFF)
		param[1] = UInt8((Current >> 8) & 0xFF)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_POWER, cmd: NEBLINA_COMMAND_POWER_CHARGE_CURRENT, paramLen: param.count, paramData: param)
	}

	// ***
	// *** Fusion subsystem commands
	// ***
	func setFusionRate(_ Rate: NeblinaRate_t) {
		var param = [UInt8](repeating: 0, count: 2)
		
		param[0] = UInt8(Rate.rawValue & 0xFF)
		param[1] = UInt8((Rate.rawValue >> 8) & 0xFF)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_RATE, paramLen: param.count, paramData: param)
	}

	func setFusionDownSample(_ Rate: UInt16) {
		var param = [UInt8](repeating: 0, count: 2)
		
		param[0] = UInt8(Rate & 0xFF)
		param[1] = UInt8((Rate >> 8) & 0xFF)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_DOWNSAMPLE, paramLen: param.count, paramData: param)
	}
	
	func streamMotionState(_ Enable:Bool)
	{
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_MOTION_STATE_STREAM, paramLen: param.count, paramData: param)
	}
	
	func streamQuaternion(_ Enable:Bool)
	{
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_QUATERNION_STREAM, paramLen: param.count, paramData: param)
	}
	
	func streamEulerAngle(_ Enable:Bool)
	{
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_EULER_ANGLE_STREAM, paramLen: param.count, paramData: param)
	}
	
	func streamExternalForce(_ Enable:Bool)
	{
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STREAM, paramLen: param.count, paramData: param)
	}

	func setFusionType(_ Mode:UInt8) {
		var param = [UInt8](repeating: 0, count: 1)
		
		param[0] = Mode
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_FUSION_TYPE, paramLen: param.count, paramData: param)
	}
	
	func recordTrajectory(_ Enable:Bool)
	{
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_TRAJECTORY_RECORD, paramLen: param.count, paramData: param)
	}
	
	func streamTrajectoryInfo(_ Enable:Bool)
	{
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_TRAJECTORY_INFO_STREAM, paramLen: param.count, paramData: param)
	}
	
	func streamPedometer(_ Enable:Bool)
	{
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM, paramLen: param.count, paramData: param)
	}

	func streamSittingStanding(_ Enable:Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_SITTING_STANDING_STREAM, paramLen: param.count, paramData: param)
	}
	
	func lockHeadingReference() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_LOCK_HEADING_REFERENCE, paramLen: 0, paramData: [0])
	}
	
	func streamFingerGesture(_ Enable:Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_FINGER_GESTURE_STREAM, paramLen: param.count, paramData: param)
	}
	
	func streamRotationInfo(_ Enable:Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ROTATION_INFO_STREAM, paramLen: param.count, paramData: param)
	}
	
	func externalHeadingCorrection(yaw : Int16, error : UInt16 ) {
		var param = [UInt8](repeating: 0, count: 4)
		
		param[0] = UInt8(yaw & 0xFF)
		param[1] = UInt8((yaw >> 8) & 0xFF)
		param[2] = UInt8(error & 0xFF)
		param[3] = UInt8((error >> 8) & 0xFF)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_EXTERNAL_HEADING_CORRECTION, paramLen: param.count, paramData: param)
	}
	
	func resetAnalysis() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ANALYSIS_RESET, paramLen: 0, paramData: [0])
	}

	func calibrateAnalysis() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ANALYSIS_CALIBRATE, paramLen: 0, paramData: [0])
	}
	
	func createPoseAnalysis(id : UInt8, qtf : [Int16]) {
		var param = [UInt8](repeating: 0, count: 2 + 8)
		
		param[0] = UInt8(id & 0xFF)
		
		for i in 0..<4 {
			param[1 + (i << 1)] = UInt8(qtf[i] & 0xFF)
			param[2 + (i << 1)] = UInt8((qtf[i] >> 8) & 0xFF)
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ANALYSIS_CREATE_POSE, paramLen: param.count, paramData: param)
	}
	
	func setActivePoseAnalysis(id : UInt8) {
		var param = [UInt8](repeating: 0, count: 1)
		
		param[0] = id
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ANALYSIS_SET_ACTIVE_POSE, paramLen: param.count, paramData: param)
	}

	func getActivePoseAnalysis() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ANALYSIS_GET_ACTIVE_POSE, paramLen: 0, paramData: [0])
	}

	func streamAnalysis(_ Enable:Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ANALYSIS_STREAM, paramLen: param.count, paramData: param)
	}
	
	func getPoseAnalysisInfo(_ id: UInt8) {
		var param = [UInt8](repeating: 0, count: 1)
		
		param[0] = id
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_ANALYSIS_POSE_INFO, paramLen: param.count, paramData: param)
	}

	func calibrateForwardPosition() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_CALIBRATE_FORWARD_POSITION, paramLen: 0, paramData: [0])
	}
	
	func calibrateDownPosition() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_CALIBRATE_DOWN_POSITION, paramLen: 0, paramData: [0])
	}
	
	func streamMotionDirection(_ Enable:Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_FUSION, cmd: NEBLINA_COMMAND_FUSION_MOTION_DIRECTION_STREAM, paramLen: param.count, paramData: param)
	}

	// ***
	// *** Storage subsystem commands
	// ***
	func getSessionCount() {
		sendCommand(subSys: NEBLINA_SUBSYSTEM_RECORDER, cmd: NEBLINA_COMMAND_RECORDER_SESSION_COUNT, paramLen: 0, paramData: [0])
	}
	
	func getSessionInfo(_ sessionId : UInt16) {
		var param = [UInt8](repeating: 0, count: 2)
		
		param[0] = UInt8(sessionId & 0xFF)
		param[1] = UInt8((sessionId >> 8) & 0xFF)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_RECORDER, cmd: NEBLINA_COMMAND_RECORDER_SESSION_INFO, paramLen: param.count, paramData: param)
	}
	
	func eraseStorage(_ quickErase:Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if quickErase == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		sendCommand(subSys: NEBLINA_SUBSYSTEM_RECORDER, cmd: NEBLINA_COMMAND_RECORDER_ERASE_ALL, paramLen: param.count, paramData: param)

	}
	
	func sessionPlayback(_ Enable:Bool, sessionId : UInt16) {
		var param = [UInt8](repeating: 0, count: 3)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		param[1] = UInt8(sessionId & 0xff)
		param[2] = UInt8((sessionId >> 8) & 0xff)

		sendCommand(subSys: NEBLINA_SUBSYSTEM_RECORDER, cmd: NEBLINA_COMMAND_RECORDER_PLAYBACK, paramLen: param.count, paramData: param)
	}
	
	func sessionRecord(_ Enable:Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_RECORDER, cmd: NEBLINA_COMMAND_RECORDER_RECORD, paramLen: param.count, paramData: param)
	}
	
	func sessionRead(_ SessionId:UInt16, Len:UInt16, Offset:UInt32) {
		var param = [UInt8](repeating: 0, count: 8)

		// Command parameter
		param[0] = UInt8(SessionId & 0xFF)
		param[1] = UInt8((SessionId >> 8) & 0xFF)
		param[2] = UInt8(Len & 0xFF)
		param[3] = UInt8((Len >> 8) & 0xFF)
		param[4] = UInt8(Offset & 0xFF)
		param[5] = UInt8((Offset >> 8) & 0xFF)
		param[6] = UInt8((Offset >> 16) & 0xFF)
		param[7] = UInt8((Offset >> 24) & 0xFF)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_RECORDER, cmd: NEBLINA_COMMAND_RECORDER_SESSION_READ, paramLen: param.count, paramData: param)
	}
	
	func sessionDownload(_ Start : Bool, SessionId:UInt16, Len:UInt16, Offset:UInt32) {
		var param = [UInt8](repeating: 0, count: 9)

		// Command parameter
		if Start == true {
			param[0] = 1
		}
		else {
			param[0] = 0
		}
		param[1] = UInt8(SessionId & 0xFF)
		param[2] = UInt8((SessionId >> 8) & 0xFF)
		param[3] = UInt8(Len & 0xFF)
		param[4] = UInt8((Len >> 8) & 0xFF)
		param[5] = UInt8(Offset & 0xFF)
		param[6] = UInt8((Offset >> 8) & 0xFF)
		param[7] = UInt8((Offset >> 16) & 0xFF)
		param[8] = UInt8((Offset >> 24) & 0xFF)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_RECORDER, cmd: NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD, paramLen: param.count, paramData: param)
	}
	
	// ***
	// *** Sensor subsystem commands
	// ***
	func sensorSetDownsample(stream : UInt16, factor : UInt16) {
		var param = [UInt8](repeating: 0, count: 4)
		
		param[0] = UInt8(stream & 0xFF)
		param[1] = UInt8(stream >> 8)
		param[2] = UInt8(factor & 0xFF)
		param[3] = UInt8(factor >> 8)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_SET_DOWNSAMPLE, paramLen: param.count, paramData: param)
	}
	
	func sensorSetRange(type : UInt16, range: UInt16) {
		var param = [UInt8](repeating: 0, count: 4)
		
		param[0] = UInt8(type & 0xFF)
		param[1] = UInt8(type >> 8)
		param[2] = UInt8(range & 0xFF)
		param[3] = UInt8(range >> 8)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_SET_RANGE, paramLen: param.count, paramData: param)
	}
	
	func sensorSetRate(type : UInt16, rate: UInt16) {
		var param = [UInt8](repeating: 0, count: 4)
		
		param[0] = UInt8(type & 0xFF)
		param[1] = UInt8(type >> 8)
		param[2] = UInt8(rate & 0xFF)
		param[3] = UInt8(rate >> 8)
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_SET_RATE, paramLen: param.count, paramData: param)
	}
	
	func sensorGetDownsample(stream : NeblinaSensorStream_t) {
		var param = [UInt8](repeating: 0, count: 1)
		
		param[0] = stream.rawValue
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_GET_DOWNSAMPLE, paramLen: param.count, paramData: param)
	}

	func sensorGetRange(type : NeblinaSensorType_t) {
		var param = [UInt8](repeating: 0, count: 1)
		
		param[0] = type.rawValue
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_GET_RANGE, paramLen: param.count, paramData: param)
	}

	func sensorGetRate(type : NeblinaSensorType_t) {
		var param = [UInt8](repeating: 0, count: 1)
		
		param[0] = type.rawValue
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_GET_RATE, paramLen: param.count, paramData: param)
	}

	func sensorStreamAccelData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_ACCELEROMETER_STREAM, paramLen: param.count, paramData: param)
	}
	
	func sensorStreamGyroData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_GYROSCOPE_STREAM, paramLen: param.count, paramData: param)
	}
	
	func sensorStreamHumidityData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_HUMIDITY_STREAM, paramLen: param.count, paramData: param)
	}
	
	func sensorStreamMagData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM, paramLen: param.count, paramData: param)
	}
	
	func sensorStreamPressureData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_PRESSURE_STREAM, paramLen: param.count, paramData: param)
	}
	
	func sensorStreamTemperatureData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_TEMPERATURE_STREAM, paramLen: param.count, paramData: param)
	}
	
	func sensorStreamAccelGyroData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE_STREAM, paramLen: param.count, paramData: param)
	}

	func sensorStreamAccelMagData(_ Enable: Bool) {
		var param = [UInt8](repeating: 0, count: 1)
		
		if Enable == true
		{
			param[0] = 1
		}
		else
		{
			param[0] = 0
		}
		
		sendCommand(subSys: NEBLINA_SUBSYSTEM_SENSOR, cmd: NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER_STREAM, paramLen: param.count, paramData: param)
	}
}

protocol NeblinaDelegate {
	
	func didConnectNeblina(sender : Neblina )
	func didReceiveRSSI(sender : Neblina , rssi : NSNumber)
	func didReceiveGeneralData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafeRawPointer, dataLen : Int, errFlag : Bool)
	func didReceiveFusionData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : NeblinaFusionPacket, errFlag : Bool)
	func didReceivePmgntData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveLedData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveDebugData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveRecorderData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveEepromData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveSensorData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
}

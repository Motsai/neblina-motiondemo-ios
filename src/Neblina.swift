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
let ACTUATOR_TYPE_TEXT_FIELD_BUTTON	= 4
let ACTUATOR_TYPE_TEXT_FIELD_SWITCH = 5

struct NebCmdItem {
	let SubSysId : Int32		// Neblina subsystem
	let	CmdId : Int32			// Neblina command ID
	let ActiveStatus : UInt32	// Match value to indicate on state
	let Name : String			// Command item name string
	let Actuator : Int			// ACTUATOR_TYPE
	let Text : String			// Text to display on actuator if avail
}

struct NebStreamInfo {
	let samplePeriod : UInt32
	let lastSampleTimestamp: UInt32
}

struct SessionInfo {
	let id : Int
	let name : String
}

class Neblina : NSObject, CBPeripheralDelegate {
	var name = String()
	var id = UInt64(0)
	var device : CBPeripheral!
	var dataChar : CBCharacteristic! = nil
	var ctrlChar : CBCharacteristic! = nil
	var NebPkt = NeblinaPacket_t()
	var fp = NeblinaFusionPacket_t()
	var delegate : NeblinaDelegate!
	//var devid : UInt64 = 0
	var packetCnt : UInt32 = 0		// Data packet count
	var startTime : UInt64 = 0
	var currTime : UInt64 = 0
	var dataRate : Float = 0.0
	var timeBaseInfo = mach_timebase_info(numer: 0, denom:0)
	
	init(devName : String, devid : UInt64, peripheral : CBPeripheral?) {
		super.init()
		if (peripheral != nil) {
			id = devid
			name = devName
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
	
	func setPeripheral(devName : String, devId : UInt64, peripheral : CBPeripheral) {
		device = peripheral
		id = devId
		name = devName
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
	func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
		if (delegate != nil) {
			delegate.didReceiveRSSI(sender: self, rssi: RSSI)
		}
	}
	
//	func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
//		if (device.rssi != nil) {
//			delegate.didReceiveRSSI(sender: self, rssi: device.rssi!)
//		}
//	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
	{
		for service in peripheral.services ?? []
		{
			if service.uuid .isEqual(NEB_SERVICE_UUID) || service.uuid .isEqual(CBUUID(string: "180F"))
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
			if characteristic.uuid .isEqual(CBUUID(string: "2A19")) {
				// Battery characteristic
				print("Notify battery level")
				peripheral.setNotifyValue(true, for: characteristic);
			}
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?)
	{
		if (delegate != nil) {
			if characteristic.uuid .isEqual(NEB_DATACHAR_UUID) {
				delegate.didConnectNeblina(sender: self)
			}
		}
	}
	func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
		print("\(peripheral)")
	}
	
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
	{
		var hdr = NeblinaPacketHeader_t()
		
		if characteristic.uuid .isEqual(CBUUID(string: "2A19")) {
			// Batttery level
			let level = characteristic.value?.hashValue
			
			//print("BATTERY LEVEL = \(level)")
			if delegate != nil {
				delegate.didReceiveBatteryLevel(sender: self, level: UInt8(UInt(level!)))
			}
		}
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
				print("Error returned  \(hdr.subSystem) \(hdr.command)")
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
			
			if Int32(hdr.packetType) == NEBLINA_PACKET_TYPE_RESPONSE {
				var dd = [UInt8](repeating: 0, count: 16)
				
				if (hdr.length > 0) {
					//print("Debug \(hdr.Len)")
					characteristic.value?.copyBytes (to: &dd, from: Range(MemoryLayout<NeblinaPacketHeader_t>.size..<Int(hdr.length) + MemoryLayout<NeblinaPacketHeader_t>.size))
				}
				delegate.didReceiveResponsePacket(sender : self, subsystem: Int32(hdr.subSystem), cmdRspId: respId, data: dd, dataLen: Int(hdr.length))
				
				return
			}
			
			if Int32(hdr.packetType) == NEBLINA_PACKET_TYPE_DATA {
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
					fp = (dd.withUnsafeBytes{ (ptr: UnsafePointer<NeblinaFusionPacket_t>) -> NeblinaFusionPacket_t in return ptr.pointee })
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
	
	func saveSession(filePath : String, sessionId: UInt8) {
		
	}
	
	//
	// MARK: **** API
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
		
		let len = min(paramLen, 16)
		for i in 0..<len {
			pkbuf[4 + i] = paramData[i]
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
}

protocol NeblinaDelegate {
	
	func didConnectNeblina(sender : Neblina )
	func didReceiveBatteryLevel(sender : Neblina, level : UInt8)
	func didReceiveResponsePacket(sender : Neblina, subsystem : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int)
	func didReceiveRSSI(sender : Neblina , rssi : NSNumber)
	func didReceiveGeneralData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafeRawPointer, dataLen : Int, errFlag : Bool)
	func didReceiveFusionData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : NeblinaFusionPacket_t, errFlag : Bool)
	func didReceivePmgntData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveLedData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveDebugData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveRecorderData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveEepromData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveSensorData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
}

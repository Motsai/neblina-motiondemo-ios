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

struct NebCmdItem {
	let SubSysId : Int32
	let	CmdId : Int32
	let ActiveStatus : UInt32
	let Name : String
	let Actuator : Int
	let Text : String
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
//print("Charact : \(characteristic.value)")
			characteristic.value?.copyBytes(to: &ch, count: min(MemoryLayout<NeblinaPacketHeader_t>.size, (characteristic.value?.count)!))
			hdr = (characteristic.value?.withUnsafeBytes{ (ptr: UnsafePointer<NeblinaPacketHeader_t>) -> NeblinaPacketHeader_t in return ptr.pointee })!
//print("packet : \(ch)")
			let respId = Int32(hdr.command)
			var errflag = Bool(false)
			

			if (Int32(hdr.packetType) == NEBLINA_PACKET_TYPE_ACK) {
				print("ACK : \(characteristic.value) \(hdr)")
				return
			}
			
/*			if ((hdr.SubSys  & 0x80) == 0x80)
			{
				print("ERR falg")
				errflag = true;
				hdr.SubSys &= 0x7F;
			}*/
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

					delegate.didReceiveGeneralData(sender: self, cmdRspId: respId, data: dd, dataLen: Int(hdr.length), errFlag: errflag)
					break
				case NEBLINA_SUBSYSTEM_FUSION:	// Motion Engine
					let dd = (characteristic.value?.subdata(in: Range(4..<Int(hdr.length)+MemoryLayout<NeblinaPacketHeader_t>.size)))!
					fp = (dd.withUnsafeBytes{ (ptr: UnsafePointer<NeblinaFusionPacket>) -> NeblinaFusionPacket in return ptr.pointee })
					delegate.didReceiveFusionData(sender: self, cmdRspId: respId
						, data: fp, errFlag: errflag)
					break
				case NEBLINA_SUBSYSTEM_POWER:
					var dd = [UInt8](repeating: 0, count: 16)
					if (hdr.length > 0) {
						characteristic.value?.copyBytes (to: &dd, from: Range(MemoryLayout<NeblinaPacketHeader_t>.size..<Int(hdr.length) + MemoryLayout<NeblinaPacketHeader_t>.size))
					}
					delegate.didReceivePmgntData(sender: self, cmdRspId: respId, data: dd, dataLen: Int(hdr.length), errFlag: errflag)
					break
				case NEBLINA_SUBSYSTEM_LED:
					var dd = [UInt8](repeating: 0, count: 16)
					if (hdr.length > 0) {
						characteristic.value?.copyBytes (to: &dd, from: Range(MemoryLayout<NeblinaPacketHeader_t>.size..<Int(hdr.length) + MemoryLayout<NeblinaPacketHeader_t>.size))
					}
					delegate.didReceiveLedData(sender: self, cmdRspId: respId, data: dd, dataLen: Int(hdr.length), errFlag: errflag)
					break
				case NEBLINA_SUBSYSTEM_DEBUG:
					var dd = [UInt8](repeating: 0, count: 16)
					//(characteristic.value as Data).copyBytes(to: &dd, from:4)
					if (hdr.length > 0) {
						//print("Debug \(hdr.Len)")
						characteristic.value?.copyBytes (to: &dd, from: Range(MemoryLayout<NeblinaPacketHeader_t>.size..<Int(hdr.length) + MemoryLayout<NeblinaPacketHeader_t>.size))
					}
				
					delegate.didReceiveDebugData(sender: self, cmdRspId: respId, data: dd, dataLen: Int(hdr.length), errFlag: errflag)
					break
				case NEBLINA_SUBSYSTEM_RECORDER:
					var dd = [UInt8](repeating: 0, count: 16)
					if (hdr.length > 0) {
						characteristic.value?.copyBytes (to: &dd, from: Range(MemoryLayout<NeblinaPacketHeader_t>.size..<Int(hdr.length) + MemoryLayout<NeblinaPacketHeader_t>.size))
					}
					delegate.didReceiveRecorderData(sender: self, cmdRspId: respId, data: dd, dataLen: Int(hdr.length), errFlag: errflag)
					break
				case NEBLINA_SUBSYSTEM_EEPROM:
					var dd = [UInt8](repeating: 0, count: 16)
					if (hdr.length > 0) {
						characteristic.value?.copyBytes (to: &dd, from: Range(MemoryLayout<NeblinaPacketHeader_t>.size..<Int(hdr.length) + MemoryLayout<NeblinaPacketHeader_t>.size))
					}
					delegate.didReceiveEepromData(sender: self, cmdRspId: respId, data: dd, dataLen: Int(hdr.length), errFlag: errflag)
					break
				case NEBLINA_SUBSYSTEM_SENSOR:
					var dd = [UInt8](repeating: 0, count: 16)
					if (hdr.length > 0) {
						characteristic.value?.copyBytes (to: &dd, from: Range(MemoryLayout<NeblinaPacketHeader_t>.size..<Int(hdr.length) + MemoryLayout<NeblinaPacketHeader_t>.size))
					}
					delegate.didReceiveSensorData(sender: self, cmdRspId: respId, data: dd, dataLen: Int(hdr.length), errFlag: errflag)
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

	// ***
	// *** Subsystem General
	// ***
	func getSystemStatus() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_GENERAL)
		pkbuf[1] = 0
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_GENERAL_SYSTEM_STATUS)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}

	func getFusionStatus() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_GENERAL)
		pkbuf[1] = 0
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_GENERAL_FUSION_STATUS)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func getRecorderStatus() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_GENERAL)
		pkbuf[1] = 0
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_GENERAL_RECORDER_STATUS)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func getFirmwareVersion() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_GENERAL)
		pkbuf[1] = 0
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_GENERAL_FIRMWARE)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func getDataPortState() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_GENERAL) // 0x40
		pkbuf[1] = 0	// Data len
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_GENERAL_INTERFACE_STATUS)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func setDataPort(_ PortIdx : Int, Ctrl : UInt8) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_GENERAL) // 0x40
		pkbuf[1] = 2
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_GENERAL_INTERFACE_STATE)	// Cmd
		
		// Port = 0 : BLE
		// Port = 1 : UART
		pkbuf[4] = UInt8(PortIdx)
		pkbuf[5] = Ctrl		// 1 - Open, 0 - Close
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
/*
	func setInterface(_ Interf : Int) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_GENERAL) // 0x40
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_GENERAL_INTERFACE_STATE)	// Cmd
		
		// Interf = 0 : BLE
		// Interf = 1 : UART
		pkbuf[4] = UInt8(Interf)
		pkbuf[8] = 0
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	*/
	
	func getPowerStatus() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_GENERAL)
		pkbuf[1] = 0
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_GENERAL_POWER_STATUS)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}

	func disableStreaming() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_GENERAL)
		pkbuf[1] = 0
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_GENERAL_DISABLE_STREAMING)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}

	func resetTimeStamp( Delayed : Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_GENERAL)
		pkbuf[1] = 1
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_GENERAL_RESET_TIMESTAMP)	// Cmd
		
		if Delayed == true {
			pkbuf[4] = 1
		}
		else {
			pkbuf[4] = 0
		}

		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func firmwareUpdate() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_GENERAL)
		pkbuf[1] = 0
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_GENERAL_FIRMWARE_UPDATE)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	// *** EEPROM
	func eepromRead(_ pageNo : UInt16) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_EEPROM)
		pkbuf[1] = 2
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_EEPROM_READ) // Cmd
		
		pkbuf[4] = UInt8(pageNo & 0xff)
		pkbuf[5] = UInt8((pageNo >> 8) & 0xff)
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func eepromWrite(_ pageNo : UInt16, data : UnsafePointer<UInt8>) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_EEPROM)
		pkbuf[1] = 8
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_EEPROM_WRITE) // Cmd
		
		pkbuf[4] = UInt8(pageNo & 0xff)
		pkbuf[5] = UInt8((pageNo >> 8) & 0xff)
		
		//for (i, 0 ..< 8, i++) {
		//	pkbuf[i + 6] = data[i]
		//}
		for i in 0..<8 {
			pkbuf[i + 6] = data[i]
		}
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	// *** LED subsystem commands
	func getLed() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_LED)
		pkbuf[1] = 0	// Data length
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_LED_STATUS)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func setLed(_ LedNo : UInt8, Value:UInt8) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_LED)
		pkbuf[1] = 2 //UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_LED_STATE)	// Cmd
		
		// Nb of LED to set
		pkbuf[4] = LedNo
		pkbuf[5] = Value
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	// *** Power management sybsystem commands
	func getTemperature() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_POWER)
		pkbuf[1] = 0	// Data length
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_POWER_TEMPERATURE)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func setBatteryChargeCurrent(_ Current: UInt16) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_POWER)
		pkbuf[1] = 2	// Data length
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_POWER_CHARGE_CURRENT)	// Cmd
		
		// Data
		pkbuf[4] = UInt8(Current & 0xFF)
		pkbuf[5] = UInt8((Current >> 8) & 0xFF)
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}

	// ***
	// *** Fusion subsystem commands
	// ***
	func setFusionSamplingRate(_ Rate: UInt8) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 1 //UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_SAMPLING_RATE)	// Cmd
		pkbuf[4] = Rate
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func setFusionDownSample(_ Rate: UInt16) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 2 //UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_DOWNSAMPLE)	// Cmd
		pkbuf[4] = UInt8(Rate)
		pkbuf[5] = UInt8(Rate >> 8)
		
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamMotionState(_ Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 1//UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_MOTION_STATE)	// Cmd
		
		if Enable == true
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamIMUState(_ Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 1//UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_IMU_STATE)	// Cmd
		
		if Enable == true
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamQuaternion(_ Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 1//UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_QUATERNION_STATE)	// Cmd
		
		if (Enable == true)
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamEulerAngle(_ Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 1 //UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_EULER_ANGLE_STATE)// Cmd
		
		if (Enable == true)
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamExternalForce(_ Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 1 //UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STATE)	// Cmd
		
		if (Enable == true)
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}

	func setFusionType(_ Mode:UInt8) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 1 //UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_FUSION_TYPE)	// Cmd
		
		// Data
		pkbuf[4] = Mode
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func recordTrajectory(_ Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 1 //UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_TRAJECTORY_RECORD)	// Cmd
		
		if Enable == true
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamTrajectoryInfo(_ Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 1 //UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_TRAJECTORY_INFO_STATE)	// Cmd
		
		if Enable == true
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamPedometer(_ Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 1 //UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_PEDOMETER_STATE)// Cmd
		
		if Enable == true
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamMAG(_ Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 1 //UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_MAG_STATE)	// Cmd
		
		if Enable == true
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamSittingStanding(_ Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 1 //UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_SITTING_STANDING_STATE)	// Cmd
		
		if Enable == true
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func setLockHeadingReference(_ Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 0//UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_LOCK_HEADING_REFERENCE)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func setAccelerometerRange(_ Mode: UInt8) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 1 //UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_ACCELEROMETER_RANGE)	// Cmd
		pkbuf[4] = Mode
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamFingerGesture(_ Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 1 //UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_FINGER_GESTURE_STATE)	// Cmd
		
		if Enable == true
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamRotationInfo(_ Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 1//UInt8(MemoryLayout<NeblinaFusionPacket>.size)
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_ROTATION_STATE)	// Cmd
		
		if Enable == true
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func calibrateForwardPosition() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 0
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_CALIBRATE_FORWARD_POSITION)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func calibrateDownPosition() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_FUSION) //0x41
		pkbuf[1] = 0
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_FUSION_CALIBRATE_DOWN_POSITION)	// Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	// *** Storage subsystem commands
	func getSessionCount() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_RECORDER)
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_RECORDER_SESSION_COUNT) // Cmd
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func getSessionInfo(_ sessionId : UInt16) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_RECORDER)
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_RECORDER_SESSION_INFO) // Cmd
		
		pkbuf[8] = UInt8(sessionId & 0xff)
		pkbuf[9] = UInt8((sessionId >> 8) & 0xff)
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func eraseStorage(_ quickErase:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_RECORDER) //0x41
		pkbuf[1] = 1
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_RECORDER_ERASE_ALL) // Cmd
		
		if quickErase == true
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
print("erase storage sent")
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
		
	}
	
	func sessionPlayback(_ Enable:Bool, sessionId : UInt16) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_RECORDER)
		pkbuf[1] = 3
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_RECORDER_PLAYBACK) // Cmd
		
		if Enable == true
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		
		pkbuf[5] = UInt8(sessionId & 0xff)
		pkbuf[6] = UInt8((sessionId >> 8) & 0xff)
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func sessionRecord(_ Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_RECORDER) //0x41
		pkbuf[1] = 1
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_RECORDER_RECORD)	// Cmd
		
		if Enable == true
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func sessionRead(_ SessionId:UInt16, Len:UInt16, Offset:UInt32) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_RECORDER) //0x41
		pkbuf[1] = 16
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_RECORDER_SESSION_READ)	// Cmd

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

		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func sessionDownload(_ Start : Bool, SessionId:UInt16, Len:UInt16, Offset:UInt32) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_RECORDER) //0x41
		pkbuf[1] = 13
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD)	// Cmd
		
		// Command parameter
		if Start == true {
			pkbuf[4] = 1
		}
		else {
			pkbuf[4] = 0
		}
		pkbuf[5] = UInt8(SessionId & 0xFF)
		pkbuf[6] = UInt8((SessionId >> 8) & 0xFF)
		pkbuf[7] = UInt8(Len & 0xFF)
		pkbuf[8] = UInt8((Len >> 8) & 0xFF)
		pkbuf[9] = UInt8(Offset & 0xFF)
		pkbuf[10] = UInt8((Offset >> 8) & 0xFF)
		pkbuf[11] = UInt8((Offset >> 16) & 0xFF)
		pkbuf[12] = UInt8((Offset >> 24) & 0xFF)
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	// ***
	// *** Sensor subsystem commands
	// ***
	func streamAccelSensorData(_ Enable: Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_SENSOR)
		pkbuf[1] = 1	// Length
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_SENSOR_ACCELEROMETER)	// Cmd
		if (Enable == true)
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamGyroSensorData(_ Enable: Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_SENSOR)
		pkbuf[1] = 1	// Length
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_SENSOR_GYROSCOPE)	// Cmd
		if (Enable == true)
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamHumiditySensorData(_ Enable: Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_SENSOR)
		pkbuf[1] = 1	// Length
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_SENSOR_HUMIDITY)	// Cmd
		if (Enable == true)
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamMagSensorData(_ Enable: Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_SENSOR)
		pkbuf[1] = 1	// Length
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_SENSOR_MAGNETOMETER)	// Cmd
		if (Enable == true)
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamPressureSensorData(_ Enable: Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_SENSOR)
		pkbuf[1] = 1	// Length
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_SENSOR_PRESSURE)	// Cmd
		if (Enable == true)
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamTempSensorData(_ Enable: Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_SENSOR)
		pkbuf[1] = 1	// Length
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_SENSOR_TEMPERATURE)	// Cmd
		if (Enable == true)
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	func streamAccelGyroSensorData(_ Enable: Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_SENSOR)
		pkbuf[1] = 1	// Length
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE)	// Cmd
		if (Enable == true)
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}

	func streamAccelMagSensorData(_ Enable: Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](repeating: 0, count: 20)
		
		pkbuf[0] = UInt8((NEBLINA_PACKET_TYPE_COMMAND << 5) | NEBLINA_SUBSYSTEM_SENSOR)
		pkbuf[1] = 1	// Length
		pkbuf[2] = 0xFF
		pkbuf[3] = UInt8(NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER)	// Cmd
		if (Enable == true)
		{
			pkbuf[4] = 1
		}
		else
		{
			pkbuf[4] = 0
		}
		
		pkbuf[2] = crc8(pkbuf, Len: Int(pkbuf[1]) + 4)
		
		device.writeValue(Data(bytes: pkbuf, count: 4 + Int(pkbuf[1])), for: ctrlChar, type: CBCharacteristicWriteType.withoutResponse)
	}
	
	
}

protocol NeblinaDelegate {
	
	func didConnectNeblina(sender : Neblina )
	func didReceiveRSSI(sender : Neblina , rssi : NSNumber)
	func didReceiveGeneralData(sender : Neblina, cmdRspId : Int32, data : UnsafeRawPointer, dataLen : Int, errFlag : Bool)
	func didReceiveFusionData(sender : Neblina, cmdRspId : Int32, data : NeblinaFusionPacket, errFlag : Bool)
	func didReceivePmgntData(sender : Neblina, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveLedData(sender : Neblina, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveDebugData(sender : Neblina, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveRecorderData(sender : Neblina, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveEepromData(sender : Neblina, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	func didReceiveSensorData(sender : Neblina, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
}

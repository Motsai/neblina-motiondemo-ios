//
//  File.swift
//  NeblinaCtrlPanel
//
//  Created by Hoan Hoang on 2015-10-07.
//  Copyright © 2015 Hoan Hoang. All rights reserved.
//

import Foundation
import CoreBluetooth

/*
struct NEB_PKTHDR {
	var SubSys : UInt8		// Subsystem type
	var Len : UInt8		// Data len = size in byte of following data
	var Crc : UInt8		// Crc on data
	var Cmd : UInt8
}

struct  NEB_PKT {
	var Hdr : NEB_PKTHDR
	var Data : [UInt8]//(count:17, repeatedValue:0)
	init() {
		Hdr = NEB_PKTHDR(SubSys: 0, Len: 0, Crc: 0, Cmd:0)
		Data = [UInt8](count:17, repeatedValue:0)
	}
}
*/
struct FusionPacket {
	//var cmd : uint8
	var TimeStamp : UInt32
	var Data = [Int16?](count:6, repeatedValue:0)
	init() {
		TimeStamp = 0
		Data = [0,0,0,0,0,0]
	}
}

/*
struct NebPacket {
	var SubSys : UInt8		// Subsystem type
	var Len : UInt8		// Data len = size in byte of following data
	var Crc : UInt8		// Crc on data
	var Cmd : UInt8
	var TimeStamp : UInt32
}
*/
struct FusionCmd {
	let	CmdId : UInt8
	let Name : String
}
/*#define Downsample 0x01
#define MotionState 0x02
#define IMU_Data 0x03
#define Quaternion 0x04
#define EulerAngle 0x05
#define ExtForce 0x06
#define SetFusionType 0x07
#define TrajectoryRecStart 0x08
#define TrajectoryRecStop 0x09
#define TrajectoryDistance 0x0A
#define Pedometer 0x0B
#define MAG_Data 0x0C
#define Erase_Recorder 0x0D
#define Start_Recorder 0x0E
#define Stop_Recorder 0x0F*/

let FusionCmdList = [FusionCmd](arrayLiteral:
	FusionCmd(CmdId:3, Name:"6 Axes IMU Stream"),
	FusionCmd(CmdId: 4, Name: "Quaternion Stream"), FusionCmd(CmdId: 5, Name: "Euler Angle Stream"),
	FusionCmd(CmdId: 6, Name: "External Force Stream"), FusionCmd(CmdId:7, Name:"Pedometer Stream"),
	FusionCmd(CmdId: 8, Name: "Trajectory Record"), FusionCmd(CmdId: 9, Name: "Trajectory Distance Stream"),
	FusionCmd(CmdId: 10, Name: "MAG Stream"), FusionCmd(CmdId: 2, Name: "Motion Data")
)

//let NebApiName = [String](arrayLiteral: "Motion Data Stream", "6AxisIMU Data", "Quaternion Data", "Euler Angle Data", "External Force Data", "Pedometer Data", "Trajectory Record", "Trajectory Distance Data", "MAG Data", "9Axis Mode", "6Axis Mode")



let NEB_SERVICE_UUID = CBUUID (string:"0df9f021-1532-11e5-8960-0002a5d5c51b")
let NEB_DATACHAR_UUID = CBUUID (string:"0df9f022-1532-11e5-8960-0002a5d5c51b")
let NEB_CTRLCHAR_UUID = CBUUID (string:"0df9f023-1532-11e5-8960-0002a5d5c51b")

class Neblina : NSObject, CBPeripheralDelegate {
	//let NORDIC_SERVICE_UUID = CBUUID (string:"6E400001-B5A3-F393-E0A9-E50E24DC9E9E")
	// Neblina UUID : 0df9f020-1532-11e5-8960-0002a5d5c51b
	//let aa = [UInt8](count:20, repeatedValue:0)
	var device : CBPeripheral!
	var dataChar : CBCharacteristic!
	var ctrlChar : CBCharacteristic!
	var NebPkt = NEB_PKT()//(SubSys: 0, Len: 0, Crc: 0, Data: [UInt8](count:17, repeatedValue:0)
//	var NebFusionPkt = FusionPacket(cmd: 0, TimeStamp: 0, data: [uint8](count: 12, repeatedValue:0))
	var fp = Fusion_DataPacket_t()
	var delegate : NeblinaDelegate!
	//var fdata = FusionPacket()//0, Data: [Int16](count:6, repeatedValue:0))
	
	//override init() {
	//}
	
	func setPeripheral(peripheral : CBPeripheral) {
		device = peripheral;
		device!.delegate = self;
		//while (device.state != CBPeripheralState.Connected) {}
		if (device.state == CBPeripheralState.Connected)
		{
			device!.discoverServices([NEB_SERVICE_UUID])
		}
		//print("Device : \(device)")
	}
	
	//
	// CBPeripheral stuffs
	//
	func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?)
	{
		for service in peripheral.services ?? []
		{
			if (service.UUID .isEqual(NEB_SERVICE_UUID))
			{
				peripheral.discoverCharacteristics(nil, forService: service)
			}
		}
		//NebPeripheral.discoverCharacteristics([NEB_CHAR_UUID], forService: <#T##CBService#>)
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
				}
			}
			if (characteristic.UUID .isEqual(NEB_CTRLCHAR_UUID))
			{
				ctrlChar = characteristic;
			}
		}
	}
	
	func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?)
	{
		//var textView : NSTextView
		//print("Value : \(characteristic.value)")
		
		//let pkt = unsafeBitCast(&NebPkt, UnsafePointer<uint8>.self)
		let NebPktt = unsafeBitCast(characteristic.value, UnsafePointer<NEB_PKT>.self) //
		//let pkk = UnsafePointer<NEB_PKTX>(characteristic.value)
		///var ppk = NebPacket(SubSys: 0, Len: 0, Crc: 0, Cmd:0, TimeStamp: 0)
		var hdr = NEB_PKTHDR(SubSys: 0, Len: 0, Crc: 0, Cmd: 0)
		if (characteristic.UUID .isEqual(NEB_DATACHAR_UUID))
		{
			characteristic.value?.getBytes(&hdr, length: sizeof(NEB_PKTHDR))
			characteristic.value?.getBytes(&NebPkt, length: sizeof(NEB_PKTHDR) + 1)
			switch (hdr.SubSys)
			{
				case 1:	// Motion Engine
					//print("\(characteristic.value)")
					characteristic.value?.getBytes(&fp, range: NSMakeRange(sizeof(NEB_PKTHDR), sizeof(Fusion_DataPacket_t)))
					//print("\(characteristic.value)")
					//print("\(fp)")
					////print("\(fdata)")
					//characteristic.value?.getBytes(&fdata, range: NSMakeRange(sizeof(NEB_PKTHDR), sizeof(Fusion_DataPacket_t)))
					//characteristic.value?.getBytes(&fdata.Data[0], range: NSMakeRange(sizeof(NEB_PKTHDR) + 4, 12))
					
					//print("\(fdata)")
					delegate.didReceiveFusionData(hdr.Cmd, data: fp)
					//delegate.didReceiveFusionData(hdr.Cmd, data: fdata)
//					characteristic.value?.getBytes(&ppk, range: NSMakeRange(sizeof(NEB_PKTHDR), 16))
					break;
				default:
					break;
			}
			
		//	NebPkt!.Data = data;
	//		delegate.didReceiveData(NebPkt)
			//print("FusionPacket : \(fp)")
		}
	}
	
	func MotionStream(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = 2	// Cmd
		
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

	func SixAxisIMU_Stream(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = 3	// Cmd
		
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
	
	func QuaternionStream(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = 4	// Cmd
		
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
	
	func EulerAngleStream(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = 5	// Cmd
		
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
	
	func ExternalForceStream(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = 6	// Cmd
		
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
	
	func PedometerStream(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = 8	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 11
		}
		else
		{
			pkbuf[8] = 0
		}
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
	}
	
	func TrajectoryRecord(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = 8	// Cmd
		
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
	
	func TrajectoryDistanceData(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = 10	// Cmd
		
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
	
	func MagStream(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = 0xC	// Cmd
		
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

	func NineAxisMode(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = 13	// Cmd
		
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
	
	func UpdateMotionFeatures() {
		
	}
}

protocol NeblinaDelegate {
	
	func didReceiveFusionData(type : UInt8, data : Fusion_DataPacket_t)
	//func didReceiveFusionData(type : UInt8, data : FusionPacket)
}

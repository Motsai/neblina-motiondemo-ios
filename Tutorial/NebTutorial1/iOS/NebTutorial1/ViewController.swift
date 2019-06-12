//
//  ViewController.swift
//  NebTutorial1
//
//  Created by Hoan Hoang on 2016-06-07.
//  Copyright © 2016 Hoan Hoang. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, NeblinaDelegate, UITableViewDataSource {
	
	var objects = [Neblina]()//[NebDevice]()
	var nebdev : Neblina!
	var bleCentralManager : CBCentralManager!
	var NebPeripheral : CBPeripheral!
	@IBOutlet weak var deviceView: UITableView!
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var switchButton:UISwitch!
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		bleCentralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func actionButton(_ sender:UISwitch) {
		if nebdev != nil {
			nebdev.streamEulerAngle(sender.isOn)
		}
	}
	
	// MARK: - Table View
		
	@objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return objects.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		let object = objects[(indexPath as NSIndexPath).row]
		cell.textLabel!.text = object.device.name// peripheral.name
		print("\(cell.textLabel!.text)")
		cell.textLabel!.text = object.device.name! + String(format: "_%lX", object.id)
		print("Cell Name : \(cell.textLabel!.text)")
		return cell
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			objects.remove(at: (indexPath as NSIndexPath).row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		} else if editingStyle == .insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
		nebdev = objects[(indexPath as NSIndexPath).row]
		nebdev.delegate = self
		
		bleCentralManager.cancelPeripheralConnection(nebdev.device)
		bleCentralManager.connect(nebdev.device, options: nil)
	}
	
	// MARK: - Bluetooth
	func centralManager(_ central: CBCentralManager,
	                    didDiscover peripheral: CBPeripheral,
						advertisementData : [String : Any],
						rssi RSSI: NSNumber) {
		print("PERIPHERAL NAME: \(peripheral.name)\n AdvertisementData: \(advertisementData)\n RSSI: \(RSSI)\n")
		
		print("UUID DESCRIPTION: \(peripheral.identifier.uuidString)\n")
		
		print("IDENTIFIER: \(peripheral.identifier)\n")
		
		if advertisementData[CBAdvertisementDataManufacturerDataKey] == nil {
			return
		}
		
		let mdata = advertisementData[CBAdvertisementDataManufacturerDataKey] as! NSData
		
		if mdata.length < 8 {
			return
		}
		
		//sensorData.text = sensorData.text + "FOUND PERIPHERALS: \(peripheral) AdvertisementData: \(advertisementData) RSSI: \(RSSI)\n"
		var id : UInt64 = 0
		(advertisementData[CBAdvertisementDataManufacturerDataKey] as! NSData).getBytes(&id, range: NSMakeRange(2, 8))
		if (id == 0) {
			return
		}
		
		for dev in objects
		{
			if (dev.id == id)
			{
				return;
			}
		}
		
		let name : String = advertisementData[CBAdvertisementDataLocalNameKey] as! String
		let device = Neblina(devName: name, devid: id, peripheral: peripheral)
		
		print("DEVICES: \(device)\n")
		
		objects.insert(device, at: 0)
		
		deviceView.reloadData();
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		
		peripheral.discoverServices(nil)
		print("Connected to peripheral")
		
		
	}
	
	func centralManager(_ central: CBCentralManager,
	                      didDisconnectPeripheral peripheral: CBPeripheral,
	                                              error: Error?) {
		print("disconnected from peripheral")
		
		
	}
	
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
	}
	
	func scanPeripheral(_ sender: CBCentralManager)
	{
		print("Scan for peripherals")
		bleCentralManager.scanForPeripherals(withServices: nil, options: nil)
	}
	
	@objc func centralManagerDidUpdateState(_ central: CBCentralManager) {
		
		switch central.state {
			
		case .poweredOff:
			print("CoreBluetooth BLE hardware is powered off")
			break
		case .poweredOn:
			print("CoreBluetooth BLE hardware is powered on and ready")
			//let lastPeripherals = central.retrieveConnectedPeripheralsWithServices([NEB_SERVICE_UUID])
			
			bleCentralManager.scanForPeripherals(withServices: [NEB_SERVICE_UUID], options: nil)
			break
		case .resetting:
			print("CoreBluetooth BLE hardware is resetting")
			break
		case .unauthorized:
			print("CoreBluetooth BLE state is unauthorized")
			
			break
		case .unknown:
			print("CoreBluetooth BLE state is unknown")
			break
		case .unsupported:
			print("CoreBluetooth BLE hardware is unsupported on this platform")
			break
			
		default:
			break
		}
	}
	
	// MARK: Neblina Delegate
	func didConnectNeblina(sender : Neblina) {
		nebdev.getSystemStatus()
	}
	
	func didReceiveResponsePacket(sender : Neblina, subsystem : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int)
	{
		switch subsystem {
		case NEBLINA_SUBSYSTEM_GENERAL:
			switch (cmdRspId) {
			case NEBLINA_COMMAND_GENERAL_SYSTEM_STATUS:
				let d = UnsafeMutableRawPointer(mutating: data).load(as: NeblinaSystemStatus_t.self)// UnsafeBufferPointer<NeblinaSystemStatus_t>(data))
				print(" \(d)")
				
				break
			case NEBLINA_COMMAND_GENERAL_FIRMWARE_VERSION:
				let vers = UnsafeMutableRawPointer(mutating: data).load(as: NeblinaFirmwareVersion_t.self)
				print("\(vers) ")
				//versionLabel.text = String(format: "API:%d, FEN:%d.%d.%d, BLE:%d.%d.%d", vers.apiVersion,
				//                           vers.coreVersion.major, vers.coreVersion.minor, vers.coreVersion.build,
				//                          vers.bleVersion.major, vers.bleVersion.minor, vers.bleVersion.build)
				break
			default:
				break
			}
			break
		default:
			break
		}
	}
	
	func didReceiveRSSI(sender : Neblina, rssi : NSNumber) {}
	func didReceiveBatteryLevel(sender: Neblina, level: UInt8) {
		
	}

	func didReceiveGeneralData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafeRawPointer, dataLen : Int, errFlag : Bool) {
		switch cmdRspId {
			case NEBLINA_COMMAND_GENERAL_SYSTEM_STATUS:
				let d = data.load(as: NeblinaSystemStatus_t.self)
				
				// Update button state
				if (d.fusion & UInt32(NEBLINA_FUSION_STATUS_EULER.rawValue)) == 0 {
					switchButton.setOn(false, animated: false)
				}
				else {
					switchButton.setOn(true, animated: true)
				}
				break
			default: break
		}
	}
	
	func didReceiveFusionData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : NeblinaFusionPacket_t, errFlag : Bool) {
	
		switch (cmdRspId) {
		case NEBLINA_COMMAND_FUSION_QUATERNION_STREAM:
			
			//
			// Process Quaternion
			//
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xq = Float(x) / 32768.0
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yq = Float(y) / 32768.0
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zq = Float(z) / 32768.0
			let w = (Int16(data.data.6) & 0xff) | (Int16(data.data.7) << 8)
			let wq = Float(w) / 32768.0
			label.text = String("Quat - x:\(xq), y:\(yq), z:\(zq), w:\(wq)")
			
			break
		case NEBLINA_COMMAND_FUSION_EULER_ANGLE_STREAM:
			//
			// Process Euler Angle
			//
				
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xrot = Float(x) / 10.0
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yrot = Float(y) / 10.0
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zrot = Float(z) / 10.0
				
			label.text = String("Euler - Yaw:\(xrot), Pitch:\(yrot), Roll:\(zrot)")
			break
		default:
			break
		}
	}
	func didReceivePmgntData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {}
	func didReceiveLedData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {}
	func didReceiveDebugData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {}
	func didReceiveRecorderData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {}
	func didReceiveEepromData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {}
	func didReceiveSensorData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {}
}



         

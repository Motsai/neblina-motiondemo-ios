//
//  ViewController.swift
//  NebTutorial1
//
//  Created by Hoan Hoang on 2016-06-07.
//  Copyright © 2016 Hoan Hoang. All rights reserved.
//

import UIKit
import CoreBluetooth

struct NebDevice {
	let id : UInt64
	let peripheral : CBPeripheral
}

class ViewController: UIViewController, CBCentralManagerDelegate, NeblinaDelegate {
	var objects = [NebDevice]()
	var nebdev = Neblina()
	var bleCentralManager : CBCentralManager!
	var NebPeripheral : CBPeripheral!
	@IBOutlet weak var deviceView: UITableView!
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var switchButton:UISwitch!
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		bleCentralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func quaternionStream(sender:UISwitch) {
		nebdev.streamQuaternion(sender.on);
	}
	
	// MARK: - Table View
		
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return objects.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
		
		let object = objects[indexPath.row]
		cell.textLabel!.text = object.peripheral.name
		print("\(cell.textLabel!.text)")
		cell.textLabel!.text = object.peripheral.name! + String(format: "_%lX", object.id)
		print("Cell Name : \(cell.textLabel!.text)")
		return cell
	}
	
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			objects.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		} else if editingStyle == .Insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let object = objects[indexPath.row]
		nebdev.setPeripheral(object.id, peripheral: object.peripheral)
		nebdev.delegate = self
		bleCentralManager.cancelPeripheralConnection(object.peripheral)
		bleCentralManager.connectPeripheral(object.peripheral, options: nil)
	}
	
	// MARK: - Bluetooth
	func centralManager(central: CBCentralManager,
	                    didDiscoverPeripheral peripheral: CBPeripheral,
	                                          advertisementData : [String : AnyObject],
	                                          RSSI: NSNumber) {
		print("PERIPHERAL NAME: \(peripheral.name)\n AdvertisementData: \(advertisementData)\n RSSI: \(RSSI)\n")
		
		print("UUID DESCRIPTION: \(peripheral.identifier.UUIDString)\n")
		
		print("IDENTIFIER: \(peripheral.identifier)\n")
		
		var id : UInt64 = 0
		advertisementData[CBAdvertisementDataManufacturerDataKey]?.getBytes(&id, range: NSMakeRange(2, 8))
		
		let device = NebDevice(id: id, peripheral: peripheral)
		
		for dev in objects
		{
			if (dev.id == id)
			{
				return;
			}
		}
		
		print("DEVICES: \(device)\n")
		
		objects.insert(device, atIndex: 0)
		
		deviceView.reloadData();
	}
	
	func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
		
		peripheral.discoverServices(nil)
		print("Connected to peripheral")
		
		
	}
	
	func centralManager(_ central: CBCentralManager,
	                      didDisconnectPeripheral peripheral: CBPeripheral,
	                                              error error: NSError?) {
		print("disconnected from peripheral")
		
		
	}
	
	func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
	}
	
	func scanPeripheral(sender: CBCentralManager)
	{
		print("Scan for peripherals")
		bleCentralManager.scanForPeripheralsWithServices(nil, options: nil)
	}
	
	@objc func centralManagerDidUpdateState(central: CBCentralManager) {
		
		switch central.state {
			
		case .PoweredOff:
			print("CoreBluetooth BLE hardware is powered off")
			break
		case .PoweredOn:
			print("CoreBluetooth BLE hardware is powered on and ready")
			//let lastPeripherals = central.retrieveConnectedPeripheralsWithServices([NEB_SERVICE_UUID])
			
			bleCentralManager.scanForPeripheralsWithServices([NEB_SERVICE_UUID], options: nil)
			break
		case .Resetting:
			print("CoreBluetooth BLE hardware is resetting")
			break
		case .Unauthorized:
			print("CoreBluetooth BLE state is unauthorized")
			
			break
		case .Unknown:
			print("CoreBluetooth BLE state is unknown")
			break
		case .Unsupported:
			print("CoreBluetooth BLE hardware is unsupported on this platform")
			break
			
		default:
			break
		}
	}
	
	// MARK : Neblina
	func didConnectNeblina() {
		nebdev.getMotionStatus()
	}
	
	func didReceiveRSSI(rssi : NSNumber) {}
	func didReceiveFusionData(type : Int32, data : Fusion_DataPacket_t, errFlag : Bool) {
		
		switch (type) {
		case Quaternion:
			
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
		default:
			break
		}
	}
	func didReceiveDebugData(type : Int32, data : UnsafePointer<UInt8>, errFlag : Bool) {
		switch (type) {
		case DEBUG_CMD_MOTENGINE_RECORDER_STATUS:
			switchButton.on = (Int(data[4] & 8) >> 3 != 0)
			
			break
		default:
			break
		}
	}
	func didReceivePmgntData(type : Int32, data : UnsafePointer<UInt8>, errFlag : Bool) {}
	func didReceiveStorageData(type : Int32, data : UnsafePointer<UInt8>, errFlag : Bool) {}
	func didReceiveEepromData(type : Int32, data : UnsafePointer<UInt8>, errFlag : Bool) {}
	func didReceiveLedData(type : Int32, data : UnsafePointer<UInt8>, errFlag : Bool) {}


}



         
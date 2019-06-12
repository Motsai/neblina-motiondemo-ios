//
//  ViewController.swift
//  SitStand
//
//  Created by Hoan Hoang on 2015-11-19.
//  Copyright © 2015 Hoan Hoang. All rights reserved.
//

import Cocoa
import CoreBluetooth
/*
struct NebDevice {
	let id : UInt64
	let peripheral : CBPeripheral
}
*/
class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, CBCentralManagerDelegate, NeblinaDelegate {
	

	var bleCentralManager : CBCentralManager!
	var objects = [Neblina]()
	var nebdev : Neblina!
	
	@IBOutlet weak var sitLabel : NSTextField!
	@IBOutlet weak var standLabel : NSTextField!
	@IBOutlet weak var tableView : NSTableView!

	var prevSitTime = UInt32(0)
	var prevStandTime = UInt32(0)
	var cadence = UInt8(0)
	var stepcnt = UInt16(0)
	
	override func viewDidLoad() {
		if #available(OSX 10.10, *) {
		    super.viewDidLoad()
		} else {
		    // Fallback on earlier versions
		}

		// Do any additional setup after loading the view.
		bleCentralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	// MARK: - Table View
	func numberOfRows(in aTableView: NSTableView) -> Int
	{
		return objects.count;
		
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
	{
		if (row < objects.count)
		{
			var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CellDevice"), owner: self) as! NSTableCellView
			//String
			if objects[row].device.name != nil {
			cellView.textField?.stringValue = objects[row].device.name! + String(format: "_%lX", objects[row].id)
				//objects[row].device.name! + String(format: "_%lX", objects[row].id) //objects[row].name;// "test"//"self.objects.objectAtIndex(row) as! String
			}
			return cellView;
		}
		
		return nil;
	}
	
	func tableViewSelectionDidChange(_ notification: Notification)
	{
		if (self.tableView.numberOfSelectedRows > 0)
		{
			//let peripheral = self.objects[self.tableView.selectedRow].device
			
			nebdev = self.objects[self.tableView.selectedRow]
			//device.setPeripheral(self.objects[self.tableView.selectedRow].id, peripheral: self.objects[self.tableView.selectedRow].peripheral)
			nebdev.delegate = self
			//print(peripheral)
			
			bleCentralManager.connect(nebdev.device, options: nil)
			bleCentralManager.stopScan()
			//self.tableView.deselectRow(self.tableView.selectedRow)
		}
		
	}
	
	func centralManager(_ central: CBCentralManager,
		didDiscover peripheral: CBPeripheral,
		advertisementData : [String : Any],
		rssi RSSI: NSNumber) {
			//NebPeripheral = peripheral
			//central.connectPeripheral(peripheral, options: nil)
			
			// We have to set the discoveredPeripheral var we declared earlier to reference the peripheral, otherwise we won't be able to interact with it in didConnectPeripheral. And you will get state = connecting> is being dealloc'ed while pending connection error.
			
			//self.discoveredPeripheral = peripheral
			
			//var curDevice = UIDevice.currentDevice()
			
			//iPad or iPhone
			// println("VENDOR ID: \(curDevice.identifierForVendor) BATTERY LEVEL: \(curDevice.batteryLevel)\n\n")
			//println("DEVICE DESCRIPTION: \(curDevice.description) MODEL: \(curDevice.model)\n\n")
			
			// Hardware beacon
			print("PERIPHERAL NAME: \(peripheral.name)\n AdvertisementData: \(advertisementData)\n RSSI: \(RSSI)\n")
			
		if #available(OSX 10.13, *) {
			print("UUID DESCRIPTION: \(peripheral.identifier.uuidString)\n")
		} else {
			// Fallback on earlier versions
		}
			
		if #available(OSX 10.13, *) {
			print("IDENTIFIER: \(peripheral.identifier)\n")
		} else {
			// Fallback on earlier versions
		}

			if advertisementData[CBAdvertisementDataManufacturerDataKey] == nil {
				return
			}
		
			//sensorData.text = sensorData.text + "FOUND PERIPHERALS: \(peripheral) AdvertisementData: \(advertisementData) RSSI: \(RSSI)\n"
			
			var id : UInt64 = 0
			(advertisementData[CBAdvertisementDataManufacturerDataKey] as! NSData).getBytes(&id, range: NSMakeRange(2, 8))
			if (id == 0) {
				return
			}
		
			//print("Peri : \(device)\n");
			
			for dev in objects
			{
				if (dev.id == id)
				{
					return;
				}
			}
		
			var name : String? = nil
			if advertisementData[CBAdvertisementDataLocalNameKey] == nil {
				print("bad, no name")
				name = peripheral.name
			}
			else {
				name = advertisementData[CBAdvertisementDataLocalNameKey] as! String
			}
			let device = Neblina(devName: name!, devid: id, peripheral: peripheral)
		
			objects.insert(device, at: 0)

			//objects.addObject(peripheral)
//			print("DEVICES: \(devices)\n")
			tableView.reloadData();
			// stop scanning, saves the battery
			//central.stopScan()
			
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		
		//peripheral.delegate = self
		peripheral.discoverServices(nil)
		//gameView.PeripheralConnected(peripheral)
		//		detailView.setPeripheral(NebDevice)
		//		NebDevice.setPeripheral(peripheral)
		print("Connected to peripheral")
		
		
	}
	
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		//        sensorData.text = "FAILED TO CONNECT \(error)"
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
			//self.sensorData.text = "CoreBluetooth BLE hardware is powered off\n"
			break
		case .poweredOn:
			print("CoreBluetooth BLE hardware is powered on and ready")
			//self.sensorData.text = "CoreBluetooth BLE hardware is powered on and ready\n"
			// We can now call scanForBeacons
			let lastPeripherals = central.retrieveConnectedPeripherals(withServices: [NEB_SERVICE_UUID])
			
			if lastPeripherals.count > 0 {
				// let device = lastPeripherals.last as CBPeripheral;
				//connectingPeripheral = device;
				//centralManager.connectPeripheral(connectingPeripheral, options: nil)
			}
			//scanPeripheral(central)
			bleCentralManager.scanForPeripherals(withServices: [NEB_SERVICE_UUID], options: nil)
			break
		case .resetting:
			print("CoreBluetooth BLE hardware is resetting")
			//self.sensorData.text = "CoreBluetooth BLE hardware is resetting\n"
			break
		case .unauthorized:
			print("CoreBluetooth BLE state is unauthorized")
			//self.sensorData.text = "CoreBluetooth BLE state is unauthorized\n"
			
			break
		case .unknown:
			print("CoreBluetooth BLE state is unknown")
			//self.sensorData.text = "CoreBluetooth BLE state is unknown\n"
			break
		case .unsupported:
			print("CoreBluetooth BLE hardware is unsupported on this platform")
			//self.sensorData.text = "CoreBluetooth BLE hardware is unsupported on this platform\n"
			break
			
		default:
			break
		}
	}

	// MARK: Neblina
	
	func didConnectNeblina(sender : Neblina) {
		nebdev.disableStreaming()
		nebdev.streamSittingStanding(false)	// Reset counts
		nebdev.streamPedometer(false)
		nebdev.streamSittingStanding(true)
		nebdev.streamPedometer(true)
	}

	func didReceiveBatteryLevel(sender: Neblina, level: UInt8) {
		
	}
	
	func didReceiveResponsePacket(sender: Neblina, subsystem: Int32, cmdRspId: Int32, data: UnsafePointer<UInt8>, dataLen: Int) {
		
	}
	
	func didReceiveRSSI(sender : Neblina, rssi : NSNumber) {
		
	}
	
	func didReceiveGeneralData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafeRawPointer, dataLen : Int, errFlag : Bool) {
		
	}

	func didReceiveFusionData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : NeblinaFusionPacket_t, errFlag : Bool) {
	//	let textview = self.view.viewWithTag(3) as! UITextView
		
		switch (cmdRspId) {
		case NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM:
			stepcnt = (UInt16(data.data.0) & 0xff) | (UInt16(data.data.1) << 8)
			cadence = data.data.2
			break
		case NEBLINA_COMMAND_FUSION_SITTING_STANDING_STREAM:
			let state = data.data.0
			let sitTime = (UInt32(data.data.1) & 0xff) | (UInt32(data.data.2) << 8)  | (UInt32(data.data.3) << 16) | (UInt32(data.data.4) << 24)
			let standTime = (UInt32(data.data.5) & 0xff) | (UInt32(data.data.6) << 8)  | (UInt32(data.data.7) << 16) | (UInt32(data.data.8) << 24)

			sitLabel.stringValue = "Siting time : \(sitTime)"
			standLabel.stringValue = "Standing time : \(standTime), \nCadence : \(cadence), Step : \(stepcnt)"
			
			if (sitTime != prevSitTime)
			{
				// Stitting
				sitLabel.backgroundColor = NSColor.green
				standLabel.backgroundColor = NSColor.gray
			}
			if (standTime != prevStandTime)
			{
				// Standing
				if (cadence == 0)
				{
					sitLabel.backgroundColor = NSColor.gray
					standLabel.backgroundColor = NSColor.green
				}
				else if (cadence < 120)
				{
					sitLabel.backgroundColor = NSColor.gray
					standLabel.backgroundColor = NSColor.cyan// blueColor()
				}
				else
				{
					sitLabel.backgroundColor = NSColor.gray
					standLabel.backgroundColor = NSColor.red
				}
			}
			prevSitTime = sitTime
			prevStandTime = standTime
			
			break;
		default: break
		}
	}
	
	func didReceivePmgntData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		
	}
	func didReceiveLedData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		
	}
	func didReceiveDebugData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		
	}
	func didReceiveRecorderData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		
	}
	func didReceiveEepromData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		
	}
	func didReceiveSensorData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		
	}

}



//
//  MasterViewController.swift
//  SitStand
//
//  Created by Hoan Hoang on 2015-11-18.
//  Copyright © 2015 Hoan Hoang. All rights reserved.
//

import UIKit
import CoreBluetooth

struct NebDevice {
	let id : UInt64
	let peripheral : CBPeripheral
}

class MasterViewController: UITableViewController, CBCentralManagerDelegate {
	
	var detailViewController: DetailViewController? = nil
	var objects = [NebDevice]()
	var bleCentralManager : CBCentralManager!
	//var NebPeripheral : CBPeripheral!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		//self.navigationItem.leftBarButtonItem = self.editButtonItem()
		
		bleCentralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
		
		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
		self.navigationItem.rightBarButtonItem = addButton
		if let split = self.splitViewController {
			let controllers = split.viewControllers
			self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
		super.viewWillAppear(animated)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func insertNewObject(sender: AnyObject) {
		//		objects.insert(NSDate(), atIndex: 0)
		let indexPath = NSIndexPath(forRow: 0, inSection: 0)
		self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
	}
	
	// MARK: - Segues
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
			if let indexPath = self.tableView.indexPathForSelectedRow {
				let object = objects[indexPath.row]
				bleCentralManager.connectPeripheral(object.peripheral, options: nil)
				let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
				//controller.NebDevice.setPeripheral(object)
				controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
				controller.navigationItem.leftItemsSupplementBackButton = true
				if (controller.detailItem != nil) {
					bleCentralManager.cancelPeripheralConnection(controller.detailItem!)
				}
				controller.detailItem = object.peripheral
			}
		}
	}
	
	// MARK: - Table View
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return objects.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
		
		let object = objects[indexPath.row]
		cell.textLabel!.text = object.peripheral.name
		print("\(cell.textLabel!.text)")
		cell.textLabel!.text = object.peripheral.name! + String(format: "_%lX", object.id)
		print("Cell Name : \(cell.textLabel!.text)")
		return cell
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			objects.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		} else if editingStyle == .Insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}
	
	// MARK: - Bluetooth
	func centralManager(central: CBCentralManager,
		didDiscoverPeripheral peripheral: CBPeripheral,
		advertisementData : [String : AnyObject],
		RSSI: NSNumber) {
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
			
			print("UUID DESCRIPTION: \(peripheral.identifier.UUIDString)\n")
			
			print("IDENTIFIER: \(peripheral.identifier)\n")
			
			//sensorData.text = sensorData.text + "FOUND PERIPHERALS: \(peripheral) AdvertisementData: \(advertisementData) RSSI: \(RSSI)\n"
			var id : UInt64 = 0
			advertisementData[CBAdvertisementDataManufacturerDataKey]?.getBytes(&id, range: NSMakeRange(2, 8))
			//			if (id == 0) {
			//				return
			//			}
			
			let device = NebDevice(id: id, peripheral: peripheral)
			
			/*for dev in objects
			{
			if (dev.id == id)
			{
			return;
			}
			}*/
			
			//print("Peri : \(peripheral)\n");
			//devices.addObject(peripheral)
			print("DEVICES: \(device)\n")
			//		peripheral.name = String("\(peripheral.name)_")
			
			objects.insert(device, atIndex: 0)
			
			tableView.reloadData();
			// stop scanning, saves the battery
			//central.stopScan()
			
	}
	
	func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
		
		//peripheral.delegate = self
		peripheral.discoverServices(nil)
		//gameView.PeripheralConnected(peripheral)
		//		detailView.setPeripheral(NebDevice)
		//NebDevice.setPeripheral(peripheral)
		print("Connected to peripheral")
		
		
	}
	
	func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		//        sensorData.text = "FAILED TO CONNECT \(error)"
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
			//self.sensorData.text = "CoreBluetooth BLE hardware is powered off\n"
			break
		case .PoweredOn:
			print("CoreBluetooth BLE hardware is powered on and ready")
			//self.sensorData.text = "CoreBluetooth BLE hardware is powered on and ready\n"
			// We can now call scanForBeacons
			let lastPeripherals = central.retrieveConnectedPeripheralsWithServices([NEB_SERVICE_UUID])
			
			if lastPeripherals.count > 0 {
				// let device = lastPeripherals.last as CBPeripheral;
				//connectingPeripheral = device;
				//centralManager.connectPeripheral(connectingPeripheral, options: nil)
			}
			//scanPeripheral(central)
			bleCentralManager.scanForPeripheralsWithServices([NEB_SERVICE_UUID], options: nil)
			break
		case .Resetting:
			print("CoreBluetooth BLE hardware is resetting")
			//self.sensorData.text = "CoreBluetooth BLE hardware is resetting\n"
			break
		case .Unauthorized:
			print("CoreBluetooth BLE state is unauthorized")
			//self.sensorData.text = "CoreBluetooth BLE state is unauthorized\n"
			
			break
		case .Unknown:
			print("CoreBluetooth BLE state is unknown")
			//self.sensorData.text = "CoreBluetooth BLE state is unknown\n"
			break
		case .Unsupported:
			print("CoreBluetooth BLE hardware is unsupported on this platform")
			//self.sensorData.text = "CoreBluetooth BLE hardware is unsupported on this platform\n"
			break
			
		default:
			break
		}
	}
	
	
}

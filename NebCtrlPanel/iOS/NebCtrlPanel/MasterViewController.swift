//
//  MasterViewController.swift
//  Nebblina Control Panel
//
//  Created by Hoan Hoang on 2015-10-22.
//  Copyright © 2015 Hoan Hoang. All rights reserved.
//

import UIKit
import CoreBluetooth
/*
struct NebDevice {
	let id : UInt64
	let peripheral : CBPeripheral
}
*/
var bleCentralManager : CBCentralManager!

class MasterViewController: UITableViewController, CBCentralManagerDelegate {

	var detailViewController: UIViewController? = nil
	var objects = [Neblina]()


	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view, typically from a nib.
		//self.navigationItem.leftBarButtonItem = self.editButtonItem()
		
		bleCentralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)

		let addButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(MasterViewController.insertRefreshScan(_:)))
		self.navigationItem.rightBarButtonItem = addButton
		if let split = self.splitViewController {
		    let controllers = split.viewControllers
			//if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad ) {
				self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
			/*}
			else {
				let splitController = controllers[controllers.count-1] as! UISplitViewController
				let controllers1 = splitController.viewControllers
				self.detailViewController = (controllers1[controllers1.count-1] as! UINavigationController).topViewController as? iPhoneCmdViewController
			}*/
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func insertRefreshScan(_ sender: AnyObject) {
		bleCentralManager.stopScan()
		objects.removeAll()
		bleCentralManager.scanForPeripherals(withServices: [NEB_SERVICE_UUID], options: nil)
//		objects.insert(NSDate(), atIndex: 0)
		//let indexPath = NSIndexPath(forRow: 0, inSection: 0)
		//self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
	}

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		print("Segue \(segue.identifier)")
		if segue.identifier == "showDetail" {
		    if let indexPath = self.tableView.indexPathForSelectedRow {
		        let object = objects[(indexPath as NSIndexPath).row]
				//if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad ) {
					let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
					controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
					controller.navigationItem.leftItemsSupplementBackButton = true
					if (controller.nebdev != nil) {
						bleCentralManager.cancelPeripheralConnection(controller.nebdev!.device)
					}
					controller.nebdev = object
				/*}
				else {
					let controller = (segue.destinationViewController as! UINavigationController).topViewController as! iPhoneCmdViewController
					controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
					controller.navigationItem.leftItemsSupplementBackButton = true
					if (controller.detailItem != nil) {
						bleCentralManager.cancelPeripheralConnection(controller.detailItem!.peripheral)
					}
					controller.detailItem = object
				}*/
				bleCentralManager.connect(object.device, options: nil)
				
				//controller.nebdev.setPeripheral(object)
		    }
		}
	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return objects.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

		let object = objects[(indexPath as NSIndexPath).row]
		cell.textLabel!.text = object.device.name
		print("\(cell.textLabel!.text)")
		cell.textLabel!.text = object.device.name! + String(format: "_%lX", object.id)
		print("Cell Name : \(cell.textLabel!.text)")
		return cell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
		    objects.remove(at: (indexPath as NSIndexPath).row)
		    tableView.deleteRows(at: [indexPath], with: .fade)
		} else if editingStyle == .insert {
		    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}

	// MARK: - Bluetooth
	func centralManager(_ central: CBCentralManager,
		didDiscover peripheral: CBPeripheral,
		advertisementData : [String : Any],
		rssi RSSI: NSNumber) {
			print("PERIPHERAL NAME: \(peripheral)\n AdvertisementData: \(advertisementData)\n RSSI: \(RSSI)\n")
			
			print("UUID DESCRIPTION: \(peripheral.identifier.uuidString)\n")
			
			print("IDENTIFIER: \(peripheral.identifier)\n")
		
			if advertisementData[CBAdvertisementDataManufacturerDataKey] == nil {
				return
			}
		
			var id : UInt64 = 0
			(advertisementData[CBAdvertisementDataManufacturerDataKey] as! NSData).getBytes(&id, range: NSMakeRange(2, 8))
			if (id == 0) {
				return
			}
			
			let name : String = advertisementData[CBAdvertisementDataLocalNameKey] as! String
			let device = Neblina(devName: name, devid: id, peripheral: peripheral)

			for dev in objects
			{
				if (dev.id == id)
				{
					return;
				}
			}
			
			objects.insert(device, at: 0)
			
			tableView.reloadData();
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {

		central.stopScan()
		peripheral.discoverServices(nil)
		print("Connected to peripheral")
		
		
	}
	
	func centralManager(_ central: CBCentralManager,
	                      didDisconnectPeripheral peripheral: CBPeripheral,
	                                              error: Error?) {
		print("disconnected from peripheral \(error)")
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


}


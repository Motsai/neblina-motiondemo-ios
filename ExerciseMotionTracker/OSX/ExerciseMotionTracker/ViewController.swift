//
//  ViewController.swift
//  ExerciseMotionTracker
//
//  Created by Hoan Hoang on 2015-11-23.
//  Copyright © 2015 Hoan Hoang. All rights reserved.
//

import Cocoa
import CoreBluetooth
import SceneKit

struct NebDevice {
	let id : UInt64
	let peripheral : CBPeripheral
}

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, CBCentralManagerDelegate, NeblinaDelegate {

	var bleCentralManager : CBCentralManager!
	var objects = [Neblina]()
	var nebdev : Neblina!
	let scene = SCNScene(named: "art.scnassets/C-3PO.obj")!
	var ship = SCNNode()
	@IBOutlet weak var tableView : NSTableView!
	@IBOutlet weak var label1 : NSTextField!
	@IBOutlet weak var label2 : NSTextField!
	@IBOutlet weak var level : NSLevelIndicator!
	
	override func viewDidLoad() {
		if #available(OSX 10.10, *) {
		    super.viewDidLoad()
		} else {
		    // Fallback on earlier versions
		}

		// Do any additional setup after loading the view.
		bleCentralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
		
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		scene.rootNode.addChildNode(cameraNode)
		
		// place the camera
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
		//cameraNode.position = SCNVector3(x: 0, y: 15, z: 0)
		//cameraNode.rotation = SCNVector4(0, 0, 1, GLKMathDegreesToRadians(-180))
		//cameraNode.rotation = SCNVector3(x:
		// create and add a light to the scene
		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light!.type = SCNLightTypeOmni
		lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
		scene.rootNode.addChildNode(lightNode)
		
		// create and add an ambient light to the scene
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = SCNLightTypeAmbient
		ambientLightNode.light!.color = NSColor.darkGrayColor()
		scene.rootNode.addChildNode(ambientLightNode)
		
		// retrieve the ship node
		ship = scene.rootNode.childNodeWithName("MDL Obj", recursively: true)!
		//ship.eulerAngles = SCNVector3Make(CGFloat(GLKMathDegreesToRadians(90)), 0, CGFloat(GLKMathDegreesToRadians(180)))
		//ship.rotation = SCNVector4(1, 0, 0, GLKMathDegreesToRadians(90))
		//print("1 - \(ship)")
		// animate the 3d object
		//ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
		//ship.runAction(SCNAction.rotateToX(CGFloat(eulerAngles.x), y: CGFloat(eulerAngles.y), z: CGFloat(eulerAngles.z), duration:1 ))// 10, y: 0.0, z: 0.0, duration: 1))
		
		// retrieve the SCNView
		let scnView = self.view.subviews[0] as! SCNView
		
		// set the scene to the view
		scnView.scene = scene
		
		// allows the user to manipulate the camera
		scnView.allowsCameraControl = true
		
		// show statistics such as fps and timing information
		scnView.showsStatistics = true
		
		// configure the view
		scnView.backgroundColor = NSColor.blackColor()
		
		// add a tap gesture recognizer
//		let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
//		scnView.addGestureRecognizer(tapGesture)
		
		level.minValue = 0
		level.maxValue = 100
		level.numberOfTickMarks = 10

	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	// MARK - Button
	@IBAction func buttonRefresh(button: NSButton)
	{
		bleCentralManager.stopScan()
		objects.removeAll()
		tableView.reloadData();
		bleCentralManager.scanForPeripheralsWithServices([NEB_SERVICE_UUID], options: nil)
	}

	@IBAction func buttonDisconnect(button: NSButton)
	{
		bleCentralManager.cancelPeripheralConnection(nebdev.device)
		nebdev.device = nil
		tableView.deselectAll(nil)
	}
	
	@IBAction func buttonTrajectRecord(button: NSButton)
	{
		nebdev.recordTrajectory(true)
	}
	
	// MARK: - Table View
	
	func numberOfRowsInTableView(aTableView: NSTableView) -> Int
	{
		return objects.count;
		
	}
	
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
	{
		if (row < objects.count)
		{
			let cellView = tableView.makeViewWithIdentifier("CellDevice", owner: self) as! NSTableCellView
			
			cellView.textField!.stringValue = objects[row].device.name! + String(format: "_%lX", objects[row].id) //objects[row].name;// "test"//"self.objects.objectAtIndex(row) as! String
			
			return cellView;
		}
		
		return nil;
	}
	
	func tableViewSelectionDidChange(notification: NSNotification)
	{
		if (self.tableView.numberOfSelectedRows > 0)
		{
			let peripheral = self.objects[self.tableView.selectedRow].device
			
			
			nebdev = self.objects[self.tableView.selectedRow]
			nebdev.delegate = self
			//print(peripheral)
			
			bleCentralManager.connectPeripheral(nebdev.device, options: nil)
			bleCentralManager.stopScan()
			//self.tableView.deselectRow(self.tableView.selectedRow)
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
			/*if (id == 0) {
				return
			}
			*/
			let device = Neblina(devid: id, peripheral: peripheral)
			
			for dev in objects
			{
				if (dev.id == id)
				{
					return;
				}
			}
			
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
	
	// MARK : Neblina
	
	func didConnectNeblina() {
		//device.SittingStanding(true)
		nebdev.streamQuaternion(true)
		nebdev.streamTrajectoryInfo(true)
	}
	func didReceiveRSSI(rssi : NSNumber) {
		
	}
	func didReceiveDebugData(type : Int32, data : UnsafePointer<UInt8>, dataLen: Int, errFlag : Bool) {
		
	}
	func didReceivePmgntData(type : Int32, data : UnsafePointer<UInt8>, dataLen: Int, errFlag : Bool) {
		
	}
	func didReceiveStorageData(type : Int32, data : UnsafePointer<UInt8>, dataLen: Int, errFlag : Bool) {
		
	}
	func didReceiveEepromData(type : Int32, data : UnsafePointer<UInt8>, dataLen: Int, errFlag : Bool) {
		
	}
	func didReceiveLedData(type : Int32, data : UnsafePointer<UInt8>, dataLen: Int, errFlag : Bool) {
		
	}

	func didReceiveFusionData(type : Int32, data : Fusion_DataPacket_t, errFlag : Bool) {
		//	let textview = self.view.viewWithTag(3) as! UITextView
		
		switch (type) {
			
		case MotionState:
			break
		case IMU_Data:
			break
		case EulerAngle:
			//
			// Process Euler Angle
			//
			/*			let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xrot = Float(x) / 10.0
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yrot = Float(y) / 10.0
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zrot = Float(z) / 10.0
			
			if (heading) {
			ship.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(90), 0, GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(xrot))
			}
			else {
			//				ship.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(90) - GLKMathDegreesToRadians(yrot), GLKMathDegreesToRadians(zrot), GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(xrot))
			ship.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(yrot), GLKMathDegreesToRadians(xrot), GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(zrot))
			}
			
			textview.text = String("Euler - Yaw:\(xrot), Pitch:\(yrot), Roll:\(zrot)")
			*/
			
			break
		case Quaternion:
			
			//
			// Process Quaternion
			//
			//let ship = scene.rootNode.childNodeWithName("MDL Obj", recursively: true)!
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xq = Float(x) / 32768.0
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yq = Float(y) / 32768.0
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zq = Float(z) / 32768.0
			let w = (Int16(data.data.6) & 0xff) | (Int16(data.data.7) << 8)
			let wq = Float(w) / 32768.0
			if #available(OSX 10.10, *) {
			    ship.orientation = SCNQuaternion(yq, xq, zq, wq)
			} else {
			    // Fallback on earlier versions
			}
			//textview.text = String("Quat - x:\(xq), y:\(yq), z:\(zq), w:\(wq)")
			print("Quat - x:\(xq), y:\(yq), z:\(zq), w:\(wq)")
			
			break
		case ExtForce:
			//
			// Process External Force
			//
			/*			let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xq = x / 1600
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yq = y / 1600
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zq = z / 1600
			
			cnt -= 1
			if (cnt <= 0) {
			cnt = max_count
			//if (xf != xq || yf != yq || zf != zq) {
			let pos = SCNVector3(CGFloat(xf/cnt), CGFloat(yf/cnt), CGFloat(zf/cnt))
			//let pos = SCNVector3(CGFloat(yf), CGFloat(xf), CGFloat(zf))
			//SCNTransaction.flush()
			//SCNTransaction.begin()
			//SCNTransaction.setAnimationDuration(0.1)
			//let action = SCNAction.moveTo(pos, duration: 0.1)
			ship.position = pos
			//SCNTransaction.commit()
			//ship.runAction(action)
			
			xf = xq
			yf = yq
			zf = zq
			//}
			}
			else {
			//if (abs(xf) <= abs(xq)) {
			xf += xq
			//}
			//if (abs(yf) <= abs(yq)) {
			yf += yq
			//}
			//if (abs(xf) <= abs(xq)) {
			zf += zq
			//}
			/*	if (xq == 0 && yq == 0 && zq == 0) {
			//cnt = 1
			xf = 0
			yf = 0
			zf = 0
			//if (cnt <= 1) {
			//ship.removeAllActions()
			//	ship.position = SCNVector3(CGFloat(yf), CGFloat(xf), CGFloat(zf))
			//}
			
			}*/
			}
			
			textview.text = String("Extrn Force - x:\(xq), y:\(yq), z:\(zq)")
			//print("Extrn Force - x:\(xq), y:\(yq), z:\(zq)")*/
			break
		case MAG_Data:
			//
			// Mag data
			//
			/*			let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xq = x / 10
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yq = y / 10
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zq = z / 10
			textview.text = String("Mag - x:\(xq), y:\(yq), z:\(zq)")
			//ship.rotation = SCNVector4(Float(xq), Float(yq), 0, GLKMathDegreesToRadians(90))*/
			break
		case TrajectoryInfo:
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let count = (Int16(data.data.6) & 0xff) | (Int16(data.data.7) << 8)
			let prval = Int(data.data.8)
			label1.stringValue = String("Error \(x),  \(y),  \(z)")
			label2.stringValue = String("Count \(count), Val \(prval)")
			level.integerValue =  prval
			break
		case SittingStanding:
/*			let state = data.data.0
			let sitTime = (Int32(data.data.1) & 0xff) | (Int32(data.data.2) << 8)  | (Int32(data.data.3) << 16) | (Int32(data.data.4) << 24)
			let standTime = (Int32(data.data.5) & 0xff) | (Int32(data.data.6) << 8)  | (Int32(data.data.7) << 16) | (Int32(data.data.8) << 24)
			
			sitLabel.stringValue = "Siting time : \(sitTime)"
			standLabel.stringValue = "Standing time : \(standTime)"
			
			if (state == 0)
			{
				// Stitting
				sitLabel.backgroundColor = NSColor.greenColor()
				standLabel.backgroundColor = NSColor.grayColor()
			}
			else
			{
				// Standing
				sitLabel.backgroundColor = NSColor.grayColor()
				standLabel.backgroundColor = NSColor.greenColor()
			}*/
			break;
		default: break
		}
		
		
	}

}


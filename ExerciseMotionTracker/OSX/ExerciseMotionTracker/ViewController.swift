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
		bleCentralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
		
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
		lightNode.light!.type = SCNLight.LightType.omni
		lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
		scene.rootNode.addChildNode(lightNode)
		
		// create and add an ambient light to the scene
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = SCNLight.LightType.ambient
		ambientLightNode.light!.color = NSColor.darkGray
		scene.rootNode.addChildNode(ambientLightNode)
		
		// retrieve the ship node
		ship = scene.rootNode.childNode(withName: "C3PO", recursively: true)!
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
		scnView.backgroundColor = NSColor.black
		
		// add a tap gesture recognizer
//		let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
//		scnView.addGestureRecognizer(tapGesture)
		
		level.minValue = 0
		level.maxValue = 100
		level.numberOfTickMarks = 10

	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	// MARK - Button
	@IBAction func buttonRefresh(_ button: NSButton)
	{
		bleCentralManager.stopScan()
		objects.removeAll()
		tableView.reloadData();
		bleCentralManager.scanForPeripherals(withServices: [NEB_SERVICE_UUID], options: nil)
	}

	@IBAction func buttonDisconnect(_ button: NSButton)
	{
		bleCentralManager.cancelPeripheralConnection(nebdev.device)
		nebdev.device = nil
		tableView.deselectAll(nil)
	}
	
	@IBAction func buttonTrajectRecord(_ button: NSButton)
	{
		nebdev.recordTrajectory(true)
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
			let cellView = tableView.make(withIdentifier: "CellDevice", owner: self) as! NSTableCellView
			
			cellView.textField!.stringValue = objects[row].device.name! + String(format: "_%lX", objects[row].id) //objects[row].name;// "test"//"self.objects.objectAtIndex(row) as! String
			
			return cellView;
		}
		
		return nil;
	}
	
	func tableViewSelectionDidChange(_ notification: Notification)
	{
		if (self.tableView.numberOfSelectedRows > 0)
		{
			let peripheral = self.objects[self.tableView.selectedRow].device
			
			
			nebdev = self.objects[self.tableView.selectedRow]
			nebdev.delegate = self
			//print(peripheral)
			
			bleCentralManager.connect(nebdev.device, options: nil)
			bleCentralManager.stopScan()
			//self.tableView.deselectRow(self.tableView.selectedRow)
		}
		
	}
	
	
	// MARK: - Bluetooth
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
			//print("Peri : \(peripheral)\n");
			//devices.addObject(peripheral)
			print("DEVICES: \(device)\n")
			//		peripheral.name = String("\(peripheral.name)_")
			
			objects.insert(device, at: 0)
			
			tableView.reloadData();
			// stop scanning, saves the battery
			//central.stopScan()
			
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		
		//peripheral.delegate = self
		peripheral.discoverServices(nil)
		//gameView.PeripheralConnected(peripheral)
		//		detailView.setPeripheral(NebDevice)
		//NebDevice.setPeripheral(peripheral)
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
		nebdev.streamQuaternion(true)
		nebdev.streamTrajectoryInfo(true)
	}

	func didReceiveResponsePacket(sender : Neblina, subsystem : Int32, cmdRspId : Int32, data : UnsafeRawPointer, dataLen : Int)
	{
		
	}
	
	func didReceiveRSSI(sender : Neblina , rssi : NSNumber) {
		
	}
	func didReceiveGeneralData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafeRawPointer, dataLen : Int, errFlag : Bool) {
		
	}
	func didReceiveFusionData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : NeblinaFusionPacket, errFlag : Bool) {
		//	let textview = self.view.viewWithTag(3) as! UITextView
		
		switch (cmdRspId) {
			
		case NEBLINA_COMMAND_FUSION_QUATERNION_STREAM:
			
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
		case NEBLINA_COMMAND_FUSION_TRAJECTORY_INFO_STREAM:
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let count = (Int16(data.data.6) & 0xff) | (Int16(data.data.7) << 8)
			let prval = Int(data.data.8)
			label1.stringValue = String("Error \(x),  \(y),  \(z)")
			label2.stringValue = String("Count \(count), Val \(prval)")
			level.integerValue =  prval
			break
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


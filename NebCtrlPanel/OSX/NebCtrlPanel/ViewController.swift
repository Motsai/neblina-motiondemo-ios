
//
//  ViewController.swift
//  NeblinaDashboard
//
//  Created by Hoan Hoang on 2016-05-06.
//  Copyright © 2016 Hoan Hoang. All rights reserved.
//

import Cocoa
import SceneKit
import AppKit//QuartzCore
import CoreBluetooth

/*
struct NebDevice {
	let id : UInt64
	let peripheral : CBPeripheral
}
*/

let MotionDataStream = Int32(1)
let Heading = Int32(2)

struct NebCmdItem {
	let SubSysId : Int32
	let	CmdId : Int32
	let Name : String
	let Actuator : Int
	let Text : String
}

let NebCmdList = [NebCmdItem] (arrayLiteral:
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_DEBUG, CmdId: DEBUG_CMD_SET_DATAPORT, Name: "BLE Data Port", Actuator : 1, Text:String(_sel: nil)),
                               NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_DEBUG, CmdId: DEBUG_CMD_SET_DATAPORT, Name: "UART Data Port", Actuator : 1, Text:String(_sel: nil)),
                               NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_MOTION_ENG, CmdId: Quaternion, Name: "Quaternion Stream", Actuator : 1, Text:String(_sel: nil)),
                               NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_MOTION_ENG, CmdId: MAG_Data, Name: "Mag Stream", Actuator : 1, Text:String(_sel: nil)),
                               NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_MOTION_ENG, CmdId: LockHeadingRef, Name: "Lock Heading Ref.", Actuator : 1, Text:String(_sel: nil)),
                               NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_STORAGE, CmdId: FlashEraseAll, Name: "Flash Erase All", Actuator : 1, Text:String(_sel: nil)),
                               NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_STORAGE, CmdId: FlashRecordStartStop, Name: "Flash Record", Actuator : 1, Text:String(_sel: nil)),
                               NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_STORAGE, CmdId: FlashPlaybackStartStop, Name: "Flash Playback", Actuator : 1, Text:String(_sel: nil)),
                               NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_STORAGE, CmdId: FlashSessionRead, Name: "Flash Download", Actuator : 1, Text:String(_sel: nil)),
                               NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_LED, CmdId: LED_CMD_SET_VALUE, Name: "Set LED0 level", Actuator : 3, Text:String(_sel: nil)),
                               NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_LED, CmdId: LED_CMD_SET_VALUE, Name: "Set LED1 level", Actuator : 3, Text:String(_sel: nil)),
                               NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_LED, CmdId: LED_CMD_SET_VALUE, Name: "Set LED2", Actuator : 1, Text:String(_sel: nil)),
                               NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_EEPROM, CmdId: EEPROM_Read, Name: "EEPROM Read", Actuator : 2, Text:String("Read")),
                               NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_POWERMGMT, CmdId: POWERMGMT_CMD_SET_CHARGE_CURRENT, Name: "Charge Current in mA", Actuator : 3, Text:String(_sel: nil)),
                               NebCmdItem(SubSysId: 0xf, CmdId: MotionDataStream, Name: "Motion data stream", Actuator : 1, Text:String(_sel: nil)),
                               NebCmdItem(SubSysId: 0xf, CmdId: Heading, Name: "Heading", Actuator : 1, Text:String(_sel: nil))
)

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, CBCentralManagerDelegate, NeblinaDelegate  {

	let scene = SCNScene(named: "art.scnassets/ship.scn")!
	var ship : SCNNode! //= scene.rootNode.childNodeWithName("ship", recursively: true)!
	var bleCentralManager : CBCentralManager!
	var objects = [Neblina]()
	var nebdev = Neblina(devid: 0, peripheral: nil)
	var prevTimeStamp = UInt32(0)
	var dropCnt = UInt32(0)
	let max_count = Int16(15)
	var cnt = Int16(15)
	var xf = Int16(0)
	var yf = Int16(0)
	var zf = Int16(0)
	var heading = Bool(false)
	var flashEraseProgress = Bool(false)
	var PaketCnt = UInt32(0)
	var startTime = NSDate()
	var rxCount = Int(0)
	var curSessionId = UInt16(0)
	var curSessionOffset = UInt32(0)
	var sessionCount = UInt8(0)
	var startDownload = Bool(false)
	
	@IBOutlet weak var devListView : NSTableView!
	@IBOutlet weak var cmdView : NSTableView!
	@IBOutlet weak var versionLabel: NSTextField!
	@IBOutlet weak var dataLabel: NSTextField!
	@IBOutlet weak var flashLabel: NSTextField!
	@IBOutlet weak var dumpLabel: NSTextField!
	@IBOutlet weak var scnView: SCNView!
	
	func getCmdIdx(subsysId : Int32, cmdId : Int32) -> Int {
		for (idx, item) in NebCmdList.enumerate() {
			if (item.SubSysId == subsysId && item.CmdId == cmdId) {
				return idx
			}
		}
		
		return -1
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		bleCentralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())

		// Do any additional setup after loading the view.

		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		scene.rootNode.addChildNode(cameraNode)
		
		// place the camera
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
		//cameraNode.position = SCNVector3(x: 0, y: 15, z: 0)
		//cameraNode.rotation = SCNVector4(0, 0, 1, GLKMathDegreesToRadians(-180))
		//cameraNode.rotation = SCNVector3(x:
		// create and add a light to the scene
		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light!.type = SCNLightTypeOmni
		lightNode.position = SCNVector3(x: 0, y: 10, z: 50)
		scene.rootNode.addChildNode(lightNode)
		
		// create and add an ambient light to the scene
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = SCNLightTypeAmbient
		ambientLightNode.light!.color = NSColor.darkGrayColor()
		scene.rootNode.addChildNode(ambientLightNode)
		
		
		// retrieve the ship node
		
		//		ship = scene.rootNode.childNodeWithName("MillenniumFalconTop", recursively: true)!
		//		ship = scene.rootNode.childNodeWithName("ARC_170_LEE_RAY_polySurface1394376_2_2", recursively: true)!
		ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
		//		ship = scene.rootNode.childNodeWithName("MDL Obj", recursively: true)!
		ship.eulerAngles = SCNVector3Make(CGFloat(GLKMathDegreesToRadians(90)), 0, CGFloat(GLKMathDegreesToRadians(180)))
		//ship.rotation = SCNVector4(1, 0, 0, GLKMathDegreesToRadians(90))
		//print("1 - \(ship)")
		// animate the 3d object
		//ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
		//ship.runAction(SCNAction.rotateToX(CGFloat(eulerAngles.x), y: CGFloat(eulerAngles.y), z: CGFloat(eulerAngles.z), duration:1 ))// 10, y: 0.0, z: 0.0, duration: 1))
		
		// retrieve the SCNView
		
		// set the scene to the view
		scnView.scene = scene
		
		// allows the user to manipulate the camera
		scnView.allowsCameraControl = true
		
		// show statistics such as fps and timing information
		scnView.showsStatistics = true
		
		// configure the view
		scnView.backgroundColor = NSColor.blackColor()
		
		//scnView.preferredFramesPerSecond = 60
		//nebdev.delegate = self
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	@IBAction func buttonAction(sender:NSButton)
	{
		
		let row = cmdView.rowForView(sender.superview!.superview!)
		//let row = (idx?.row)! as Int
		
		if (row < NebCmdList.count) {
			switch (NebCmdList[row].SubSysId)
			{
			case NEB_CTRL_SUBSYS_EEPROM:
				switch (NebCmdList[row].CmdId)
				{
				case EEPROM_Read:
					nebdev.eepromRead(0)
					break
				case EEPROM_Write:
					//UInt8_t eepdata[8]
					//nebdev.SendCmdEepromWrite(0, eepdata)
					break
				default:
					break
				}
				break
			default:
				break
			}
		}
	}
	
	@IBAction func textAction(sender:NSTextField)
	{
		let row = cmdView.rowForView((sender.superview!.superview)!)// as! NSTableCellView)
		let value = sender.integerValue
		switch (NebCmdList[row].SubSysId)
		{
			case NEB_CTRL_SUBSYS_LED:
				let i = getCmdIdx(NEB_CTRL_SUBSYS_LED,  cmdId: LED_CMD_SET_VALUE)
				nebdev.setLed(UInt8(row - i), Value: UInt8(value))
				
				break
			case NEB_CTRL_SUBSYS_POWERMGMT:
				nebdev.setBatteryChargeCurrent(UInt16(value))
				break
			default:
				break
		}
//		print("textAction \(value)")
	}
	
	@IBAction func switchAction(sender:NSSegmentedControl)
	{
		//let tableView = sender.superview?.superview?.superview?.superview as! UITableView
		let row = cmdView.rowForView((sender.superview!.superview)!)// as! NSTableCellView)
		
		
		if (row < NebCmdList.count) {
			switch (NebCmdList[row].SubSysId)
			{
			case NEB_CTRL_SUBSYS_DEBUG:
				switch (NebCmdList[row].CmdId)
				{
				case DEBUG_CMD_SET_INTERFACE:
					nebdev.setInterface(sender.selectedSegment)
					break
				case DEBUG_CMD_DUMP_DATA:
					break;
				case DEBUG_CMD_SET_DATAPORT:
					nebdev.setDataPort(row, Ctrl:UInt8(sender.selectedSegment))
					break;
				default:
					break
				}
				break
				
			case NEB_CTRL_SUBSYS_MOTION_ENG:
				switch (NebCmdList[row].CmdId)
				{
				case MotionState:
					nebdev.streamMotionState(sender.selectedSegment == 1)
					break
				case IMU_Data:
					nebdev.streamIMU(sender.selectedSegment == 1)
					break
				case Quaternion:
					nebdev.streamEulerAngle(false)
					heading = false
					prevTimeStamp = 0
					nebdev.streamQuaternion(sender.selectedSegment == 1)
					let i = getCmdIdx(0xf,  cmdId: 1)
					let cell = cmdView.viewAtColumn(0, row: i, makeIfNecessary: false)! as NSView
					let control = cell.viewWithTag(1) as! NSSegmentedControl

					control.selectedSegment = 0
					break
				case EulerAngle:
					nebdev.streamQuaternion(false)
					nebdev.streamEulerAngle(sender.selectedSegment == 1)
					break
				case ExtForce:
					nebdev.streamExternalForce(sender.selectedSegment == 1)
					break
				case Pedometer:
					nebdev.streamPedometer(sender.selectedSegment == 1)
					break;
				case TrajectoryRecStartStop:
					nebdev.recordTrajectory(sender.selectedSegment == 1)
					break;
				case TrajectoryDistance:
					nebdev.streamTrajectoryInfo(sender.selectedSegment == 1)
					break;
				case MAG_Data:
					nebdev.streamMAG(sender.selectedSegment == 1)
					break;
				case LockHeadingRef:
					nebdev.setLockHeadingReference(sender.selectedSegment == 1)
					let cell = cmdView.rowViewAtRow(row, makeIfNecessary: false)
					let sw = cell!.viewWithTag(1) as! NSSegmentedControl
					sw.selectedSegment = 0
					break
				default:
					break
				}
			case NEB_CTRL_SUBSYS_LED:
				let i = getCmdIdx(NEB_CTRL_SUBSYS_LED,  cmdId: LED_CMD_SET_VALUE)
				nebdev.setLed(UInt8(row - i), Value: UInt8(sender.selectedSegment))
				break
			case NEB_CTRL_SUBSYS_STORAGE:
				switch (NebCmdList[row].CmdId)
				{
					
				case FlashEraseAll:
					if (sender.selectedSegment == 1) {
						flashEraseProgress = true;
					}
					nebdev.eraseStorage(sender.selectedSegment == 1)
					break
				case FlashRecordStartStop:
					nebdev.sessionRecord(sender.selectedSegment == 1)
					break
				case FlashPlaybackStartStop:
					
					nebdev.sessionPlayback(sender.selectedSegment == 1, sessionId : 0xffff)
					if (sender.selectedSegment == 1) {
						PaketCnt = 0
					}
					prevTimeStamp = 0;
					break
				case FlashSessionRead:
					nebdev.getSessionCount()
					startDownload = true
					curSessionId = 0
					curSessionOffset = 0
//					nebdev.sessionRead(curSessionId, Len: 16, Offset: curSessionOffset)
//					curSessionOffset += 16
					break
				default:
					break
				}
				break
			case NEB_CTRL_SUBSYS_EEPROM:
				switch (NebCmdList[row].CmdId)
				{
				case EEPROM_Read:
					nebdev.eepromRead(0)
					break
				case EEPROM_Write:
					//UInt8_t eepdata[8]
					//nebdev.SendCmdEepromWrite(0, eepdata)
					break
				default:
					break
				}
				break
			case 0xF:
				switch (NebCmdList[row].CmdId) {
					case Heading:	// Heading
						nebdev.streamQuaternion(false)
						nebdev.streamEulerAngle(true)
						heading = sender.selectedSegment == 1
						var i = getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: Quaternion)
						var cell = cmdView.rowViewAtRow(i, makeIfNecessary: false)
						var control = cell!.viewWithTag(1) as! NSSegmentedControl
						control.selectedSegment = 0
						i = getCmdIdx(0xF,  cmdId: MotionDataStream)
						cell = cmdView.rowViewAtRow(i, makeIfNecessary: false)
						control = cell!.viewWithTag(1) as! NSSegmentedControl
						control.selectedSegment = 0
						break
					case MotionDataStream:
						nebdev.streamQuaternion(sender.selectedSegment == 1)
						var i = getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: Quaternion)
						var cell = cmdView.rowViewAtRow(i, makeIfNecessary: false)
						if (cell != nil) {
							let control = cell!.viewWithTag(1) as! NSSegmentedControl
							control.selectedSegment = sender.selectedSegment
						}
						nebdev.streamIMU(sender.selectedSegment == 1)
						i = getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: IMU_Data)
						cell = cmdView.rowViewAtRow(i, makeIfNecessary: false)
						if (cell != nil) {
							let control = cell!.viewWithTag(1) as! NSSegmentedControl
							control.selectedSegment = sender.selectedSegment
						}
						nebdev.streamMAG(sender.selectedSegment == 1)
						i = getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: MAG_Data)
						cell = cmdView.rowViewAtRow(i, makeIfNecessary: false)
						if (cell != nil) {
							let control = cell!.viewWithTag(1) as! NSSegmentedControl
							control.selectedSegment = sender.selectedSegment
						}
						nebdev.streamExternalForce(sender.selectedSegment == 1)
						i = getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: ExtForce)
						cell = cmdView.rowViewAtRow(i, makeIfNecessary: false)
						if (cell != nil) {
							let control = cell!.viewWithTag(1) as! NSSegmentedControl
							control.selectedSegment = sender.selectedSegment
						}
						nebdev.streamPedometer(sender.selectedSegment == 1)
						i = getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: Pedometer)
						cell = cmdView.rowViewAtRow(i, makeIfNecessary: false)
						if (cell != nil) {
							let control = cell!.viewWithTag(1) as! NSSegmentedControl
							control.selectedSegment = sender.selectedSegment
						}
						nebdev.streamRotationInfo(sender.selectedSegment == 1)
						i = getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: RotationInfo)
						cell = cmdView.rowViewAtRow(i, makeIfNecessary: false)
						if (cell != nil) {
							let control = cell!.viewWithTag(1) as! NSSegmentedControl
							control.selectedSegment = sender.selectedSegment
						}
						i = getCmdIdx(0xF,  cmdId: Heading)
						cell = cmdView.rowViewAtRow(i, makeIfNecessary: false)
						if (cell != nil) {
							let control = cell!.viewWithTag(1) as! NSSegmentedControl
							control.selectedSegment = 0
						}
						break

					default:
						break
				}
				break
			default:
				break
			}
			
		}
		else {
			switch (row - NebCmdList.count) {
			case 0:
				nebdev.streamQuaternion(false)
				nebdev.streamEulerAngle(true)
				heading = sender.selectedSegment == 1
				let i = getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: Quaternion)
				let cell = cmdView.rowViewAtRow(i, makeIfNecessary: false)
				let sw = cell!.viewWithTag(1) as! NSSegmentedControl
				sw.selectedSegment = 0
				break
			default:
				break
			}
		}
	}
	
	// MARK: - Table View
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int
	//func numberOfRowsInSection(aTableView: NSTableView) -> Int
	{
		if (tableView == devListView) {
			return objects.count
		}
		else if (tableView == cmdView) {
			return NebCmdList.count
		}
		
		return 0
	}
	
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
	{
		if (tableView == devListView) {
			if (row < objects.count) {
				let cellView = tableView.makeViewWithIdentifier("CellDevice", owner: self) as! NSTableCellView
			
				cellView.textField!.stringValue = objects[row].device.name! + String(format: "_%lX", objects[row].id) //objects[row].name;// "test"//"self.objects.objectAtIndex(row) as! String
			
				return cellView;
			}
		}
		if (tableView == cmdView) {
			if (row < NebCmdList.count)
			{
				
				let cellView = tableView.makeViewWithIdentifier("CellCmd", owner: self) as! NSTableCellView
				cellView.textField!.stringValue = NebCmdList[row].Name
				if (NebCmdList[row].Actuator == 2)
				{
					let ctrl = cellView.viewWithTag(NebCmdList[row].Actuator) as! NSButton
					ctrl.hidden = false
					if (NebCmdList[row].Text != String(_sel: nil))
					{
						ctrl.title = NebCmdList[row].Text
					}
					
				}
				else
				{
					let ctrl = cellView.viewWithTag(NebCmdList[row].Actuator) as! NSControl
					ctrl.hidden = false
					if (NebCmdList[row].Text != String(_sel: nil))
					{
						ctrl.stringValue = NebCmdList[row].Text
					}
					
				}
				

				return cellView
			}
		}
		
		return nil;
	}
	
	/*func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?
	{
	//        var string:String = "row " + String(row) + ", Col" + String(tableColumn.identifier)
	//        return string
	//let newString = getDataArray().objectAtIndex(row).objectForKey(tableColumn!.identifier)
	if (row < devices.count)
	{
	//let peripheral = devices[row];
	//let newString = peripheral.name;
	
	return devices[row];
	}
	return nil;
	}*/
	
	/*	func getDataArray () -> NSArray{
	let dataArray:[NSDictionary] = [["FirstName": "Debasis", "LastName": "Das"],
	["FirstName": "Nishant", "LastName": "Singh"],
	["FirstName": "John", "LastName": "Doe"],
	["FirstName": "Jane", "LastName": "Doe"],
	["FirstName": "Mary", "LastName": "Jane"]];
	print(dataArray);
	return dataArray;
	}*/
	
	func tableViewSelectionDidChange(notification: NSNotification)
	{
		let t = notification.object as! NSTableView
		if (t == devListView) {
			if (self.devListView.numberOfSelectedRows > 0)
			{
				bleCentralManager.stopScan()
				bleCentralManager.connectPeripheral(self.objects[self.devListView.selectedRow].device, options: nil)
			//self.tableView.deselectRow(self.tableView.selectedRow)
			}
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
		if (id == 0) {
			return
		}
		
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
		
		devListView.reloadData();
		// stop scanning, saves the battery
		//central.stopScan()
		
	}
	
	func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
		//peripheral.delegate = self
		//peripheral.discoverServices(nil)
		//gameView.PeripheralConnected(peripheral)
		//		detailView.setPeripheral(NebDevice)
		//nebdev.setPeripheral(peripheral)
		if (self.devListView.numberOfSelectedRows > 0)
		{
			//let peripheral = self.objects[self.devListView.selectedRow].peripheral
			//nebdev.setPeripheral(objects[self.devListView.selectedRow].id, peripheral: objects[self.devListView.selectedRow].peripheral)
			nebdev = objects[self.devListView.selectedRow]
			nebdev.delegate = self
			nebdev.device.discoverServices(nil)
		}
		//nebdev.connected(peripheral)
		print("Connected to peripheral")
		
		
	}
	
	func centralManager(central: CBCentralManager,
	                      didDisconnectPeripheral peripheral: CBPeripheral,
	                                              error: NSError?) {
		//peripheral.delegate = self
		//peripheral.discoverServices(nil)
		//gameView.PeripheralConnected(peripheral)
		//		detailView.setPeripheral(NebDevice)
		//NebDevice.setPeripheral(peripheral)
		print("disconnected from peripheral")
		
		
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
		prevTimeStamp = 0;
		nebdev.getFirmwareVersion()
		nebdev.getMotionStatus()
		nebdev.getDataPortState()
		nebdev.getLed ()
	}
	
	func didReceiveRSSI(rssi : NSNumber) {
		
	}
	
	func didReceivePmgntData(type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		let value = UInt16(data[0]) | (UInt16(data[1]) << 8)
		if (type == POWERMGMT_CMD_SET_CHARGE_CURRENT)
		{
			//print("**V*** \(value) : \(data)")
			let i = getCmdIdx(NEB_CTRL_SUBSYS_POWERMGMT,  cmdId: POWERMGMT_CMD_SET_CHARGE_CURRENT)
			let cell = cmdView.viewAtColumn(0, row: i, makeIfNecessary: false)! as NSView
			let control = cell.viewWithTag(3) as! NSTextField
			control.stringValue = String(value)
		}
		cmdView.setNeedsDisplay()
	}
	
	func didReceiveFusionData(type : Int32, data : Fusion_DataPacket_t, errFlag : Bool) {
		
		//let errflag = Bool(type.rawValue & 0x80 == 0x80)
		
		//let id = FusionId(rawValue: type.rawValue & 0x7F)! as FusionId
//		flashLabel.text = String(format: "Total packet %u @ %0.2f pps", nebdev.getPacketCount(), nebdev.getDataRate())
		
		switch (type) {
			
		case MotionState:
			break
		case IMU_Data:
			break
		case EulerAngle:
			//
			// Process Euler Angle
			//
			//let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xrot = Float(x) / 10.0
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yrot = Float(y) / 10.0
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zrot = Float(z) / 10.0
			
			if (heading) {
				ship.eulerAngles = SCNVector3Make(CGFloat(GLKMathDegreesToRadians(90)),
				                                  0,
				                                  CGFloat(GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(xrot)))
			}
			else {
				ship.eulerAngles = SCNVector3Make(CGFloat(GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(yrot)),
				                                  CGFloat(GLKMathDegreesToRadians(xrot)),
				                                  CGFloat(GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(zrot)))
			}
			
			dataLabel.stringValue = String("Euler - Yaw:\(xrot), Pitch:\(yrot), Roll:\(zrot)")
			
			
			break
		case Quaternion:
			
			//
			// Process Quaternion
			//
			//let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xq = Float(x) / 32768.0
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yq = Float(y) / 32768.0
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zq = Float(z) / 32768.0
			let w = (Int16(data.data.6) & 0xff) | (Int16(data.data.7) << 8)
			let wq = Float(w) / 32768.0
			if (prevTimeStamp == 0 || data.TimeStamp <= prevTimeStamp)
			{
				prevTimeStamp = data.TimeStamp;
				startTime = NSDate()
				rxCount = 0
			}
			else
			{
				let tdiff = data.TimeStamp - prevTimeStamp;
				if (tdiff > 49000)
				{
					dropCnt += 1
					dumpLabel.stringValue = String("\(dropCnt) Drop : \(tdiff)")
				}
				rxCount += 1
				prevTimeStamp = data.TimeStamp
				let curDate =  NSDate()
				let rate = (Double(rxCount) * 20.0) / curDate.timeIntervalSinceDate(startTime)
				print("\(rate)")
			}
			ship.orientation = SCNQuaternion(yq, xq, zq, wq)
			dataLabel.stringValue = String("Quat - x:\(xq), y:\(yq), z:\(zq), w:\(wq)")
			
			break
		case ExtForce:
			//
			// Process External Force
			//
			//let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
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
			
			dataLabel.stringValue = String("Extrn Force - x:\(xq), y:\(yq), z:\(zq)")
			//print("Extrn Force - x:\(xq), y:\(yq), z:\(zq)")
			break
		case MAG_Data:
			//
			// Mag data
			//
			//let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xq = x
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yq = y
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zq = z
			dataLabel.stringValue = String("Mag - x:\(xq), y:\(yq), z:\(zq)")
			rxCount += 1
			//ship.rotation = SCNVector4(Float(xq), Float(yq), 0, GLKMathDegreesToRadians(90))
			break
			/*		case FlashEraseAll:
			//let session = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			flashrec.text = String("Flash Erased")
			flashEraseProgress = false
			let i = nebdev.getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG, cmdId : FlashEraseAll)
			let cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
			let sw = cell!.viewWithTag(2) as! UISegmentedControl
			sw.selectedSegmentIndex = 0
			break;
			case FlashRecordStartStop:
			if (errFlag) {
			flashrec.text = String("Unable to start recording")
			let i = nebdev.getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG, cmdId : FlashRecordStartStop)
			let cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
			let sw = cell!.viewWithTag(2) as! UISegmentedControl
			sw.selectedSegmentIndex = 0
			}
			else {
			let onoff = Int8(data.data.0)
			let session = (Int16(data.data.1) & 0xff) | (Int16(data.data.2) << 8)
			if (onoff == 0) {
			flashrec.text = String("Flash Recording Finished \(session)")
			let i = nebdev.getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG, cmdId : FlashRecordStartStop)
			let cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
			let sw = cell!.viewWithTag(2) as! UISegmentedControl
			sw.selectedSegmentIndex = 0
			}
			else {
			flashrec.text = String("Flash Recording Session \(session)")
			
			}
			}
			break;
			case FlashPlaybackStartStop:
			if (errFlag) {
			flashrec.text = String("Flash record session not found")
			let i = nebdev.getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG, cmdId : FlashPlaybackStartStop)
			let cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
			let sw = cell!.viewWithTag(2) as! UISegmentedControl
			sw.selectedSegmentIndex = 0
			}
			else {
			let onoff = Int8(data.data.0)
			let session = (Int16(data.data.1) & 0xff) | (Int16(data.data.2) << 8)
			if (onoff == 0) {
			flashrec.text = String("Flash Playback Finished")
			let i = nebdev.getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG, cmdId : FlashPlaybackStartStop)
			let cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
			let sw = cell!.viewWithTag(2) as! UISegmentedControl
			sw.selectedSegmentIndex = 0
			}
			else {
			flashrec.text = String("Flash Playback Session \(session)")
			}
			}
			break*/
			
		default: break
		}
		
		
	}
	
	func didReceiveDebugData(type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	{
		//print("Debug \(type) data \(data)")
		switch (type) {
		case DEBUG_CMD_MOTENGINE_RECORDER_STATUS:
			//print("DEBUG_CMD_MOTENGINE_RECORDER_STATUS \(data)")
			switch (data[8]) {
			case 1:	// Playback
				var i = getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashRecordStartStop)
				var cell = cmdView.viewAtColumn(0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				var sw = cell.viewWithTag(1) as! NSSegmentedControl
				sw.selectedSegment = 0
				i = getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashPlaybackStartStop)
				cell = cmdView.viewAtColumn(0, row:i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				sw = cell.viewWithTag(1) as! NSSegmentedControl
				sw.selectedSegment = 1
				
				break
			case 2:	// Recording
				var i = getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashPlaybackStartStop)
				var cell = cmdView.viewAtColumn(0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				var sw = cell.viewWithTag(1) as! NSSegmentedControl
				sw.selectedSegment = 0
				i = getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashRecordStartStop)
				cell = cmdView.viewAtColumn(0, row:i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				sw = cell.viewWithTag(1) as! NSSegmentedControl
				sw.selectedSegment = 1
				break
			default:
				var i = getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashPlaybackStartStop)
				var cell = cmdView.viewAtColumn(0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				var sw = cell.viewWithTag(1) as! NSSegmentedControl
				sw.selectedSegment = 0
				i = getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashRecordStartStop)
				cell = cmdView.viewAtColumn(0, row:i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				sw = cell.viewWithTag(1) as! NSSegmentedControl
				sw.selectedSegment = 0
				break
			}
			var i = getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: Quaternion)
			var cell = cmdView.viewAtColumn(0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
			var sw = cell.viewWithTag(1) as! NSSegmentedControl
			sw.selectedSegment = Int(data[4] & 8) >> 3
			
			i = getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: MAG_Data)
			cell = cmdView.viewAtColumn(0, row:i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
			sw = cell.viewWithTag(1) as! NSSegmentedControl
			sw.selectedSegment = 1
			sw.selectedSegment = Int(data[4] & 0x80) >> 7
			
			//				i = nebdev.getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: EulerAngle)
			/*				cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: NebCmdList.count, inSection: 0))
			sw = cell!.viewWithTag(2) as! UISegmentedControl
			sw.selectedSegmentIndex = Int(data[4] & 0x4) >> 2*/
			//print("\(d)")
			nebdev.getFirmwareVersion()
			
			break
		case DEBUG_CMD_GET_FW_VERSION:
			versionLabel.stringValue = String(format: "API:%d, FEN:%d.%d.%d, BLE:%d.%d.%d", data[0], data[1], data[2], data[3], data[4], data[5], data[6])
			//versionLabel.setNeedsDisplay()
			//print("**")
			break
		case DEBUG_CMD_DUMP_DATA:
			dumpLabel.stringValue = String(format: "%02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x",
			                        data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9],
			                        data[10], data[11], data[12], data[13], data[14], data[15])
			break
		case DEBUG_CMD_GET_DATAPORT:
			let i = getCmdIdx(NEB_CTRL_SUBSYS_DEBUG,  cmdId: DEBUG_CMD_SET_DATAPORT)
			var cell = cmdView.viewAtColumn(0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
			var control = cell.viewWithTag(1) as! NSSegmentedControl
			
			control.selectedSegment = Int(data[0])
			
			cell = cmdView.viewAtColumn(0, row: i + 1, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
			control = cell.viewWithTag(1) as! NSSegmentedControl
			
			control.selectedSegment = Int(data[1])
			break
		default:
			break
		}
		
		cmdView.setNeedsDisplay()
	}
	
	func didReceiveStorageData(type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		switch (type) {
		case FlashEraseAll:
			flashLabel.stringValue = "Flash erased"
			break
		case FlashRecordStartStop:
			let session = Int16(data[5]) | (Int16(data[6]) << 8)
			if (data[4] != 0) {
				flashLabel.stringValue = String(format: "Recording session %d", session)
			}
			else {
				flashLabel.stringValue = String(format: "Recorded session %d", session)
			}
			break
		case FlashPlaybackStartStop:
			let session = Int16(data[5]) | (Int16(data[6]) << 8)
			if (data[4] != 0) {
				flashLabel.stringValue = String(format: "Playing session %d", session)
			}
			else {
				flashLabel.stringValue = String(format: "End session %d, %u", session, nebdev.getPacketCount())
				
				let i = getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashPlaybackStartStop)
				let cell = cmdView.viewAtColumn(0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				let sw = cell.viewWithTag(1) as! NSSegmentedControl
				
				sw.selectedSegment = 0
			}
			break
		case FlashSessionRead:
			if (errFlag == false && dataLen > 0) {
				nebdev.sessionRead(curSessionId, Len: 16, Offset: curSessionOffset)
				curSessionOffset += 16
				print("\(curSessionOffset), \(data)")
			}
			else {
				let i = getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashSessionRead)
				let cell = cmdView.viewAtColumn(0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				let sw = cell.viewWithTag(1) as! NSSegmentedControl
				
				sw.selectedSegment = 0
			}
			break
		case FlashGetNbSessions:
			sessionCount = data[0]
			break
		default:
			break
		}
	}
	
	func didReceiveEepromData(type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		switch (type) {
		case EEPROM_Read:
			let pageno = UInt16(data[0]) | (UInt16(data[1]) << 8)
			dumpLabel.stringValue = String(format: "EEP page [%d] : %02x %02x %02x %02x %02x %02x %02x %02x",
			                        pageno, data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9])
			break
		case EEPROM_Write:
			break;
		default:
			break
		}
	}
	func didReceiveLedData(type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		switch (type) {
		case LED_CMD_GET_VALUE:
			let i = getCmdIdx(NEB_CTRL_SUBSYS_LED,  cmdId: LED_CMD_SET_VALUE)
			var cell = cmdView.viewAtColumn(0, row: i, makeIfNecessary: false)
			var tf = cell!.viewWithTag(3) as! NSTextField
			tf.intValue = Int32(data[0])
			cell = cmdView.viewAtColumn(0, row: i + 1, makeIfNecessary: false)
			tf = cell!.viewWithTag(3) as! NSTextField
			tf.intValue = Int32(data[1])
			
			cell = cmdView.viewAtColumn(0, row: i + 2, makeIfNecessary: false)
			var sw = cell!.viewWithTag(1) as! NSSegmentedControl
			if (data[2] != 0) {
				sw.selectedSegment = 1
			}
			else {
				sw.selectedSegment = 0
			}
			break
		default:
			break
		}
		cmdView.setNeedsDisplay()
	}

}


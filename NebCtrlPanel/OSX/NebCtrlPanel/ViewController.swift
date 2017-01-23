
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

let NebCmdList = [NebCmdItem] (arrayLiteral:
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_INTERFACE_STATE, Name: "BLE Data Port", Actuator : 1, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_INTERFACE_STATE, Name: "UART Data Port", Actuator : 1, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_CALIBRATE_FORWARD_POSITION, Name: "Calibrate Forward Pos", Actuator : 2, Text: "Calib Fwrd"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_CALIBRATE_DOWN_POSITION, Name: "Calibrate Down Pos", Actuator : 2, Text: "Calib Dwn"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STATE, Name: "Quaternion Stream", Actuator : 1, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_ACCELEROMETER, Name: "Accelerometer Sensor Stream", Actuator : 1, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_GYROSCOPE, Name: "Gyroscope Sensor Stream", Actuator : 1, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_MAGNETOMETER, Name: "Magnetometer Sensor Stream", Actuator : 1, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE, Name: "Accel & Gyro Stream", Actuator : 1, Text:""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_HUMIDITY, Name: "Humidity Sensor Stream", Actuator : 1, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_LOCK_HEADING_REFERENCE, Name: "Lock Heading Ref.", Actuator : 1, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_RECORD, Name: "Flash Record", Actuator : 2, Text: "ON"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_RECORD, Name: "Flash Record", Actuator : 2, Text: "OFF"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_PLAYBACK, Name: "Flash Playback", Actuator : 1, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_SESSION_READ, Name: "Flash Download Session ", Actuator : 4, Text: "Start"),
//	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_LED, CmdId: NEBLINA_COMMAND_LED_STATE, Name: "Set LED0 level", Actuator : 3, Text: ""),
//	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_LED, CmdId: NEBLINA_COMMAND_LED_STATE, Name: "Set LED1 level", Actuator : 3, Text: ""),
//	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_LED, CmdId: NEBLINA_COMMAND_LED_STATE, Name: "Set LED2", Actuator : 1, Text: ""),
//	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_EEPROM, CmdId: NEBLINA_COMMAND_EEPROM_READ, Name: "EEPROM Read", Actuator : 2, Text: "Read"),
//	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_POWER, CmdId: NEBLINA_COMMAND_POWER_CHARGE_CURRENT, Name: "Charge Current in mA", Actuator : 3, Text: ""),
	NebCmdItem(SubSysId: 0xf, CmdId: MotionDataStream, Name: "Motion data stream", Actuator : 1, Text: ""),
	NebCmdItem(SubSysId: 0xf, CmdId: Heading, Name: "Heading", Actuator : 1, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_FIRMWARE_UPDATE, Name: "Firmware Update", Actuator : 2, Text: "DFU"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_ERASE_ALL, Name: "Flash Erase All", Actuator : 1, Text: "")
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
	var startTime = Date()
	var rxCount = Int(0)
	var curSessionId = UInt16(0)
	var curSessionOffset = UInt32(0)
	var sessionCount = UInt8(0)
	var startDownload = Bool(false)
	var filepath = String()
	var file : FileHandle?

	@IBOutlet weak var devListView : NSTableView!
	@IBOutlet weak var cmdView : NSTableView!
	@IBOutlet weak var versionLabel: NSTextField!
	@IBOutlet weak var dataLabel: NSTextField!
	@IBOutlet weak var flashLabel: NSTextField!
	@IBOutlet weak var dumpLabel: NSTextField!
	@IBOutlet weak var scnView: SCNView!
	
	func getCmdIdx(_ subsysId : Int32, cmdId : Int32) -> Int {
		for (idx, item) in NebCmdList.enumerated() {
			if (item.SubSysId == subsysId && item.CmdId == cmdId) {
				return idx
			}
		}
		
		return -1
	}
	
	override func viewDidLoad() {
		if #available(OSX 10.10, *) {
			super.viewDidLoad()
		} else {
			// Fallback on earlier versions
		}

		bleCentralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)

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
		lightNode.light!.type = SCNLight.LightType.omni
		lightNode.position = SCNVector3(x: 0, y: 10, z: 50)
		scene.rootNode.addChildNode(lightNode)
		
		// create and add an ambient light to the scene
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = SCNLight.LightType.ambient
		ambientLightNode.light!.color = NSColor.darkGray
		scene.rootNode.addChildNode(ambientLightNode)
		
		
		// retrieve the ship node
		
		//		ship = scene.rootNode.childNodeWithName("MillenniumFalconTop", recursively: true)!
		//		ship = scene.rootNode.childNodeWithName("ARC_170_LEE_RAY_polySurface1394376_2_2", recursively: true)!
		ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
		//		ship = scene.rootNode.childNodeWithName("MDL Obj", recursively: true)!
		if #available(OSX 10.10, *) {
			ship.eulerAngles = SCNVector3Make(CGFloat(GLKMathDegreesToRadians(90)), 0, CGFloat(GLKMathDegreesToRadians(180)))
		} else {
			// Fallback on earlier versions
		}
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
		scnView.backgroundColor = NSColor.black
		
		//scnView.preferredFramesPerSecond = 60
		//nebdev.delegate = self
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	@IBAction func buttonAction(_ sender:NSButton)
	{
		
		let row = cmdView.row(for: sender.superview!.superview!)
		//let row = (idx?.row)! as Int
		
		if (row < NebCmdList.count) {
			switch (NebCmdList[row].SubSysId)
			{
			case NEBLINA_SUBSYSTEM_GENERAL:
				switch (NebCmdList[row].CmdId)
				{
				case NEBLINA_COMMAND_GENERAL_FIRMWARE_UPDATE:
					nebdev.firmwareUpdate()
					break
				default:
					break
				}
				break
			case NEBLINA_SUBSYSTEM_EEPROM:
				switch (NebCmdList[row].CmdId)
				{
				case NEBLINA_COMMAND_EEPROM_READ:
					nebdev.eepromRead(0)
					break
				case NEBLINA_COMMAND_EEPROM_WRITE:
					//UInt8_t eepdata[8]
					//nebdev.SendCmdEepromWrite(0, eepdata)
					break
				default:
					break
				}
				break
			case NEBLINA_SUBSYSTEM_RECORDER:
				switch (NebCmdList[row].CmdId)
				{
					case NEBLINA_COMMAND_RECORDER_RECORD:
						var i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_RECORD)
						if row - i > 0 {
							nebdev.sessionRecord(false)
						}
						else {
							nebdev.sessionRecord(true)
						}
						break
					case NEBLINA_COMMAND_RECORDER_SESSION_READ:
						let i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_SESSION_READ)
						if i >= 0 {
							let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
							if (cell != nil) {
								let control = cell!.viewWithTag(4) as! NSTextField
								let but = cell!.viewWithTag(2) as! NSButton
								but.isEnabled = false
								curSessionId = UInt16(control.integerValue)
								startDownload = true
								curSessionOffset = 0
								//let filename = String(format:"NeblinaRecord_%d.dat", curSessionId)
								let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
								                                                   .userDomainMask, true)
								if dirPaths != nil {
									filepath = dirPaths[0]// as! String
									filepath.append(String(format:"/%@/", nebdev.device.name!))
									do {
										try FileManager.default.createDirectory(atPath: filepath, withIntermediateDirectories: false, attributes: nil)
										
									} catch let error as NSError {
										print(error.localizedDescription);
									}
									filepath.append(String(format:"%@_%d.dat", nebdev.device.name!, curSessionId))
									FileManager.default.createFile(atPath: filepath, contents: nil, attributes: nil)
									do {
										try file = FileHandle(forWritingAtPath: filepath)
									} catch { print("file failed \(filepath)")}
									nebdev.sessionRead(curSessionId, Len: 16, Offset: 0)
								}
								//}
							}
						}

						
					break
				default:
					break
				}
			case NEBLINA_SUBSYSTEM_FUSION:
				switch (NebCmdList[row].CmdId) {
				case NEBLINA_COMMAND_FUSION_CALIBRATE_FORWARD_POSITION:
					nebdev.calibrateForwardPosition()
					break
				case NEBLINA_COMMAND_FUSION_CALIBRATE_DOWN_POSITION:
					nebdev.calibrateDownPosition()
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
	
	@IBAction func textAction(_ sender:NSTextField)
	{
		let row = cmdView.row(for: (sender.superview!.superview)!)// as! NSTableCellView)
		let value = sender.integerValue
		switch (NebCmdList[row].SubSysId)
		{
			case NEBLINA_SUBSYSTEM_LED:
				let i = getCmdIdx(NEBLINA_SUBSYSTEM_LED,  cmdId: NEBLINA_COMMAND_LED_STATE)
				if i >= 0 {
					nebdev.setLed(UInt8(row - i), Value: UInt8(value))
				}
				break
			case NEBLINA_SUBSYSTEM_POWER:
				nebdev.setBatteryChargeCurrent(UInt16(value))
				break
			case NEBLINA_SUBSYSTEM_RECORDER:
				switch (NebCmdList[row].CmdId)
				{
					default:
						break
				}
			default:
				break
		}
//		print("textAction \(value)")
	}
	
	@IBAction func switchAction(_ sender:NSSegmentedControl)
	{
		//let tableView = sender.superview?.superview?.superview?.superview as! UITableView
		let row = cmdView.row(for: (sender.superview!.superview)!)// as! NSTableCellView)
		
		
		if (row < NebCmdList.count) {
			switch (NebCmdList[row].SubSysId)
			{
			case NEBLINA_SUBSYSTEM_GENERAL:
				switch (NebCmdList[row].CmdId)
				{
				case NEBLINA_COMMAND_GENERAL_INTERFACE_STATUS:
					//nebdev.getDataPort(sender.selectedSegment)
					break
				case NEBLINA_COMMAND_GENERAL_INTERFACE_STATE:
					nebdev.setDataPort(row, Ctrl:UInt8(sender.selectedSegment))
					break;
				default:
					break
				}
				break
				
			case NEBLINA_SUBSYSTEM_FUSION:
				switch (NebCmdList[row].CmdId)
				{
				case NEBLINA_COMMAND_FUSION_MOTION_STATE:
					nebdev.streamMotionState(sender.selectedSegment == 1)
					break
//				case NEBLINA_COMMAND_FUSION_IMU_STATE:
//					nebdev.streamIMU(sender.selectedSegment == 1)
					break
				case NEBLINA_COMMAND_FUSION_QUATERNION_STATE:
					nebdev.streamEulerAngle(false)
					heading = false
					prevTimeStamp = 0
					nebdev.streamQuaternion(sender.selectedSegment == 1)
					let i = getCmdIdx(0xf,  cmdId: 1)
					if i < 0 {
						break
					}
					let cell = cmdView.view(atColumn: 0, row: i, makeIfNecessary: false)! as NSView
					let control = cell.viewWithTag(1) as! NSSegmentedControl

					control.selectedSegment = 0
					break
				case NEBLINA_COMMAND_FUSION_EULER_ANGLE_STATE:
					nebdev.streamQuaternion(false)
					nebdev.streamEulerAngle(sender.selectedSegment == 1)
					break
				case NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STATE:
					nebdev.streamExternalForce(sender.selectedSegment == 1)
					break
				case NEBLINA_COMMAND_FUSION_PEDOMETER_STATE:
					nebdev.streamPedometer(sender.selectedSegment == 1)
					break;
				case NEBLINA_COMMAND_FUSION_TRAJECTORY_RECORD:
					nebdev.recordTrajectory(sender.selectedSegment == 1)
					break;
				case NEBLINA_COMMAND_FUSION_TRAJECTORY_INFO_STATE:
					nebdev.streamTrajectoryInfo(sender.selectedSegment == 1)
					break;
				case NEBLINA_COMMAND_FUSION_MAG_STATE:
					nebdev.streamMAG(sender.selectedSegment == 1)
					break;
				case NEBLINA_COMMAND_FUSION_LOCK_HEADING_REFERENCE:
					nebdev.setLockHeadingReference(sender.selectedSegment == 1)
					let cell = cmdView.rowView(atRow: row, makeIfNecessary: false)
					let sw = cell!.viewWithTag(1) as! NSSegmentedControl
					sw.selectedSegment = 0
					break
				default:
					break
				}
			case NEBLINA_SUBSYSTEM_LED:
				let i = getCmdIdx(NEBLINA_SUBSYSTEM_LED,  cmdId: NEBLINA_COMMAND_LED_STATE)
				if i >= 0 {
					nebdev.setLed(UInt8(row - i), Value: UInt8(sender.selectedSegment))
				}
				break
			case NEBLINA_SUBSYSTEM_RECORDER:
				switch (NebCmdList[row].CmdId)
				{
					
				case NEBLINA_COMMAND_RECORDER_ERASE_ALL:
					if (sender.selectedSegment == 1) {
						flashEraseProgress = true;
					}
					nebdev.eraseStorage(sender.selectedSegment == 1)
					break
				case NEBLINA_COMMAND_RECORDER_RECORD:
					nebdev.sessionRecord(sender.selectedSegment == 1)
					break
				case NEBLINA_COMMAND_RECORDER_PLAYBACK:
					
					nebdev.sessionPlayback(sender.selectedSegment == 1, sessionId : 0xFFFF)
					if (sender.selectedSegment == 1) {
						PaketCnt = 0
					}
					prevTimeStamp = 0;
					break
				case NEBLINA_COMMAND_RECORDER_SESSION_READ:
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
			case NEBLINA_SUBSYSTEM_EEPROM:
				switch (NebCmdList[row].CmdId)
				{
				case NEBLINA_COMMAND_EEPROM_READ:
					nebdev.eepromRead(0)
					break
				case NEBLINA_COMMAND_EEPROM_WRITE:
					//UInt8_t eepdata[8]
					//nebdev.SendCmdEepromWrite(0, eepdata)
					break
				default:
					break
				}
				break
			case NEBLINA_SUBSYSTEM_SENSOR:
				switch (NebCmdList[row].CmdId)
				{
					case NEBLINA_COMMAND_SENSOR_ACCELEROMETER:
						nebdev.streamAccelSensorData(sender.selectedSegment == 1)
						break
					case NEBLINA_COMMAND_SENSOR_GYROSCOPE:
						nebdev.streamGyroSensorData(sender.selectedSegment == 1)
						break
					case NEBLINA_COMMAND_SENSOR_HUMIDITY:
						nebdev.streamHumiditySensorData(sender.selectedSegment == 1)
						break
					case NEBLINA_COMMAND_SENSOR_MAGNETOMETER:
						nebdev.streamMagSensorData(sender.selectedSegment == 1)
						break
					case NEBLINA_COMMAND_SENSOR_PRESSURE:
						nebdev.streamPressureSensorData(sender.selectedSegment == 1)
						break
					case NEBLINA_COMMAND_SENSOR_TEMPERATURE:
						nebdev.streamTempSensorData(sender.selectedSegment == 1)
						break
					case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE:
						nebdev.streamAccelGyroSensorData(sender.selectedSegment == 1)
						break
					case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER:
						nebdev.streamAccelMagSensorData(sender.selectedSegment == 1)
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
						var i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STATE)
						if i >= 0 {
							let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
							let control = cell!.viewWithTag(1) as! NSSegmentedControl
							control.selectedSegment = 0
						}
						i = getCmdIdx(0xF,  cmdId: MotionDataStream)
						if i >= 0 {
							let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
							let control = cell!.viewWithTag(1) as! NSSegmentedControl
							control.selectedSegment = 0
						}
						break
					case MotionDataStream:
						nebdev.streamQuaternion(sender.selectedSegment == 1)
						var i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STATE)
						if i >= 0 {
							let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! NSSegmentedControl
								control.selectedSegment = sender.selectedSegment
							}
						}
//						nebdev.streamIMU(sender.selectedSegment == 1)
//						i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_IMU_STATE)
//						if i >= 0 {
//							let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
//							if (cell != nil) {
//								let control = cell!.viewWithTag(1) as! NSSegmentedControl
//								control.selectedSegment = sender.selectedSegment
//							}
//						}
						nebdev.streamMAG(sender.selectedSegment == 1)
						i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_MAG_STATE)
						if i >= 0 {
							let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! NSSegmentedControl
								control.selectedSegment = sender.selectedSegment
							}
						}
						nebdev.streamExternalForce(sender.selectedSegment == 1)
						i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STATE)
						if i >= 0 {
							let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! NSSegmentedControl
								control.selectedSegment = sender.selectedSegment
							}
						}
						nebdev.streamPedometer(sender.selectedSegment == 1)
						i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_PEDOMETER_STATE)
						if i >= 0 {
							let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! NSSegmentedControl
								control.selectedSegment = sender.selectedSegment
							}
						}
						nebdev.streamRotationInfo(sender.selectedSegment == 1)
						i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_ROTATION_STATE)
						if i >= 0 {
							let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! NSSegmentedControl
								control.selectedSegment = sender.selectedSegment
							}
						}
						i = getCmdIdx(0xF,  cmdId: Heading)
						if i >= 0 {
							let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! NSSegmentedControl
								control.selectedSegment = 0
							}
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
				let i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STATE)
				if i < 0 {
					break
				}
				let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
				let sw = cell!.viewWithTag(1) as! NSSegmentedControl
				sw.selectedSegment = 0
				break
			default:
				break
			}
		}
	}
	
	// MARK: - Table View
	
	func numberOfRows(in tableView: NSTableView) -> Int
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
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
	{
		if (tableView == devListView) {
			if (row < objects.count) {
				let cellView = tableView.make(withIdentifier: "CellDevice", owner: self) as! NSTableCellView
			
				if objects[row].device.name != nil {
					cellView.textField!.stringValue = objects[row].device.name!
				}
				else {
					cellView.textField!.stringValue = String("NoName")
				}
				cellView.textField!.stringValue += String(format: "_%lX", objects[row].id)
				
				return cellView;
			}
		}
		if (tableView == cmdView) {
			if (row < NebCmdList.count)
			{
				
				let cellView = tableView.make(withIdentifier: "CellCmd", owner: self) as! NSTableCellView
				cellView.textField!.stringValue = NebCmdList[row].Name
				switch (NebCmdList[row].Actuator) {
					case 4:
						let txtctrl = cellView.viewWithTag(NebCmdList[row].Actuator) as! NSControl
						txtctrl.isHidden = false
						let ctrl = cellView.viewWithTag(2) as! NSButton
						ctrl.isHidden = false
						if !NebCmdList[row].Text.isEmpty
						{
							ctrl.title = NebCmdList[row].Text
						}
						break
						
					case 2:
						let ctrl = cellView.viewWithTag(NebCmdList[row].Actuator) as! NSButton
						ctrl.isHidden = false
						if !NebCmdList[row].Text.isEmpty
						{
							ctrl.title = NebCmdList[row].Text
						}
						break
					default:
						let ctrl = cellView.viewWithTag(NebCmdList[row].Actuator) as! NSControl
						ctrl.isHidden = false
						if !NebCmdList[row].Text.isEmpty
						{
							ctrl.stringValue = NebCmdList[row].Text
						}
						break
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
	
	func tableViewSelectionDidChange(_ notification: Notification)
	{
		let t = notification.object as! NSTableView
		if (t == devListView) {
			if (self.devListView.numberOfSelectedRows > 0)
			{
				bleCentralManager.stopScan()
				bleCentralManager.connect(self.objects[self.devListView.selectedRow].device, options: nil)
			//self.tableView.deselectRow(self.tableView.selectedRow)
			}
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
		
		var id = UInt64 (0)
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
		
		let device = Neblina(devid: id, peripheral: peripheral)
		objects.insert(device, at: 0)
		
		devListView.reloadData();
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		central.stopScan()

		if (self.devListView.numberOfSelectedRows > 0)
		{
			if nebdev.device != nil {
				central.cancelPeripheralConnection(nebdev.device)
			}
			dataLabel.stringValue = String(" ")
			flashLabel.stringValue = String(" ")
			nebdev = objects[self.devListView.selectedRow]
			nebdev.delegate = self
			nebdev.device.discoverServices(nil)
		}
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

	// MARK : Neblina
	
	func didConnectNeblina() {
		prevTimeStamp = 0;
		nebdev.getFirmwareVersion()
		nebdev.getFusionStatus()
		nebdev.getDataPortState()
		nebdev.getLed ()
	}
	
	func didReceiveRSSI(_ rssi : NSNumber) {
		
	}

	//
	// General data
	//
	func didReceiveGeneralData(_ type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		switch (type) {
		case NEBLINA_COMMAND_GENERAL_SYSTEM_STATUS:
			break
		case NEBLINA_COMMAND_GENERAL_RECORDER_STATUS:
			//print("DEBUG_CMD_MOTENGINE_RECORDER_STATUS \(data)")
			switch (data[8]) {
			case 1:	// Playback
				var i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_RECORD)
				if i >= 0 {
					let cell = cmdView.view(atColumn: 0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
					let sw = cell.viewWithTag(1) as! NSSegmentedControl
					sw.selectedSegment = 0
				}
				i = getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: NEBLINA_COMMAND_RECORDER_PLAYBACK)
				if i >= 0 {
					let cell = cmdView.view(atColumn: 0, row:i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
					let sw = cell.viewWithTag(1) as! NSSegmentedControl
					sw.selectedSegment = 1
				}
				break
			case 2:	// Recording
				var i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_PLAYBACK)
				if i >= 0 {
					let cell = cmdView.view(atColumn: 0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
					let sw = cell.viewWithTag(1) as! NSSegmentedControl
					sw.selectedSegment = 0
				}
				i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: FlashRecordStartStop)
				if i >= 0 {
					let cell = cmdView.view(atColumn: 0, row:i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
					let sw = cell.viewWithTag(1) as! NSSegmentedControl
					sw.selectedSegment = 1
				}
				break
			default:
				var i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: FlashPlaybackStartStop)
				if i >= 0 {
					let cell = cmdView.view(atColumn: 0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
					let sw = cell.viewWithTag(1) as! NSSegmentedControl
					sw.selectedSegment = 0
				}
				i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: FlashRecordStartStop)
				if i >= 0 {
					let cell = cmdView.view(atColumn: 0, row:i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
					let sw = cell.viewWithTag(1) as! NSSegmentedControl
					sw.selectedSegment = 0
				}
				break
			}
			var i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STATE)
			if i >= 0 {
				let cell = cmdView.view(atColumn: 0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				let sw = cell.viewWithTag(1) as! NSSegmentedControl
				sw.selectedSegment = Int(data[4] & 8) >> 3
			}
			i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_MAG_STATE)
			if i >= 0 {
				let cell = cmdView.view(atColumn: 0, row:i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				let sw = cell.viewWithTag(1) as! NSSegmentedControl
				sw.selectedSegment = 1
				sw.selectedSegment = Int(data[4] & 0x80) >> 7
			}
			
			//				i = nebdev.getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: EulerAngle)
			/*				cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: NebCmdList.count, inSection: 0))
			sw = cell!.viewWithTag(2) as! UISegmentedControl
			sw.selectedSegmentIndex = Int(data[4] & 0x4) >> 2*/
			//print("\(d)")
			//nebdev.getFirmwareVersion()
			
				break
			case NEBLINA_COMMAND_GENERAL_FIRMWARE:
				versionLabel.stringValue = String(format: "API:%d, FEN:%d.%d.%d, BLE:%d.%d.%d", data[0], data[1], data[2], data[3], data[4], data[5], data[6])
				//versionLabel.setNeedsDisplay()
				//print("**")
				print("\(versionLabel.stringValue)")
			
				break
			case NEBLINA_COMMAND_GENERAL_INTERFACE_STATUS:
				let i = getCmdIdx(NEBLINA_SUBSYSTEM_GENERAL,  cmdId: NEBLINA_COMMAND_GENERAL_INTERFACE_STATE)
				if i < 0 {
					break
				}
				var cell = cmdView.view(atColumn: 0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				var control = cell.viewWithTag(1) as! NSSegmentedControl
			
				control.selectedSegment = Int(data[0])
			
				cell = cmdView.view(atColumn: 0, row: i + 1, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				control = cell.viewWithTag(1) as! NSSegmentedControl
			
				control.selectedSegment = Int(data[1])
				break
			default:
				break
		}
	}
	
	//
	// Fusion data
	//
	func didReceiveFusionData(_ type : Int32, data : NeblinaFusionPacket, errFlag : Bool) {
		
		//let errflag = Bool(type.rawValue & 0x80 == 0x80)
		
		//let id = FusionId(rawValue: type.rawValue & 0x7F)! as FusionId
//		flashLabel.text = String(format: "Total packet %u @ %0.2f pps", nebdev.getPacketCount(), nebdev.getDataRate())
		
		switch (type) {
			
		case NEBLINA_COMMAND_FUSION_MOTION_STATE:
			break
		case NEBLINA_COMMAND_FUSION_IMU_STATE:
			break
		case NEBLINA_COMMAND_FUSION_EULER_ANGLE_STATE:
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
				if #available(OSX 10.10, *) {
					ship.eulerAngles = SCNVector3Make(CGFloat(GLKMathDegreesToRadians(90)),
					                                  0,
					                                  CGFloat(GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(xrot)))
				} else {
					// Fallback on earlier versions
				}
			}
			else {
				if #available(OSX 10.10, *) {
					ship.eulerAngles = SCNVector3Make(CGFloat(GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(yrot)),
					                                  CGFloat(GLKMathDegreesToRadians(xrot)),
					                                  CGFloat(GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(zrot)))
				} else {
					// Fallback on earlier versions
				}
			}
			
			dataLabel.stringValue = String("Euler - Yaw:\(xrot), Pitch:\(yrot), Roll:\(zrot)")
			
			
			break
		case NEBLINA_COMMAND_FUSION_QUATERNION_STATE:
			
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
			//print("\(data.TimeStamp)")
			if (prevTimeStamp == 0 || data.timestamp <= prevTimeStamp)
			{
				prevTimeStamp = data.timestamp;
				startTime = Date()
				rxCount = 0
			}
			else
			{
				let tdiff = data.timestamp - prevTimeStamp;
				if (tdiff > 49000)
				{
					dropCnt += 1
					dumpLabel.stringValue = String("\(dropCnt) Drop : \(tdiff)")
				}
				rxCount += 1
				prevTimeStamp = data.timestamp
				let curDate =  Date()
				let rate = (Double(rxCount) * 20.0) / curDate.timeIntervalSince(startTime)
				//print("\(data.TimeStamp), \(tdiff)")
			}
			if #available(OSX 10.10, *) {
				ship.orientation = SCNQuaternion(yq, xq, zq, wq)
			} else {
				// Fallback on earlier versions
			}
			dataLabel.stringValue = String("Quat - x:\(xq), y:\(yq), z:\(zq), w:\(wq)")
			
			break
		case NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STATE:
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
		case NEBLINA_COMMAND_FUSION_MAG_STATE:
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
	
	//
	// Power management data
	//
	func didReceivePmgntData(_ type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		let value = UInt16(data[0]) | (UInt16(data[1]) << 8)
		if (type == NEBLINA_COMMAND_POWER_CHARGE_CURRENT)
		{
			//print("**V*** \(value) : \(data)")
			let i = getCmdIdx(NEBLINA_SUBSYSTEM_POWER,  cmdId: NEBLINA_COMMAND_POWER_CHARGE_CURRENT)
			if i >= 0 {
				let cell = cmdView.view(atColumn: 0, row: i, makeIfNecessary: false)! as NSView
				let control = cell.viewWithTag(3) as! NSTextField
				control.stringValue = String(value)
			}
		}
		cmdView.setNeedsDisplay()
	}
	
	//
	// LED
	//
	func didReceiveLedData(_ type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		switch (type) {
		case NEBLINA_COMMAND_LED_STATUS:
			let i = getCmdIdx(NEBLINA_SUBSYSTEM_LED,  cmdId: NEBLINA_COMMAND_LED_STATUS)
			if i < 0 {
				break
			}
			var cell = cmdView.view(atColumn: 0, row: i, makeIfNecessary: false)
			var tf = cell!.viewWithTag(3) as! NSTextField
			tf.intValue = Int32(data[0])
			cell = cmdView.view(atColumn: 0, row: i + 1, makeIfNecessary: false)
			tf = cell!.viewWithTag(3) as! NSTextField
			tf.intValue = Int32(data[1])
			
			cell = cmdView.view(atColumn: 0, row: i + 2, makeIfNecessary: false)
			let sw = cell!.viewWithTag(1) as! NSSegmentedControl
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
	
	//
	// Debug
	//
	func didReceiveDebugData(_ type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	{
		//print("Debug \(type) data \(data)")
		switch (type) {
		case NEBLINA_COMMAND_DEBUG_DUMP_DATA:
			dumpLabel.stringValue = String(format: "%02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x",
			                        data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9],
			                        data[10], data[11], data[12], data[13], data[14], data[15])
						break
		default:
			break
		}
		
		cmdView.setNeedsDisplay()
	}
	
	//
	// Storage
	//
	func didReceiveStorageData(_ type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {

		switch (type) {
		case NEBLINA_COMMAND_RECORDER_ERASE_ALL:
			flashLabel.stringValue = "Flash erased"
			let i = getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashEraseAll)
			if i < 0 {
				break
			}
			let cell = cmdView.view(atColumn: 0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
			let sw = cell.viewWithTag(1) as! NSSegmentedControl
			
			sw.selectedSegment = 0
			break
		case NEBLINA_COMMAND_RECORDER_RECORD:
			let session = Int16(data[1]) | (Int16(data[2]) << 8)
			if (data[0] != 0) {
				flashLabel.stringValue = String(format: "Recording session %d", session)
			}
			else {
				flashLabel.stringValue = String(format: "Recorded session %d", session)
			}
			break
		case NEBLINA_COMMAND_RECORDER_PLAYBACK:
			print("FlashPlaybackStartStop : \(data[0]) \(data[1]) \(data[2])")
			let session = Int16(data[1]) | (Int16(data[2]) << 8)
			if (data[0] != 0) {
				flashLabel.stringValue = String(format: "Playing session %d", session)
			}
			else {
				flashLabel.stringValue = String(format: "End session %d, %u", session, nebdev.getPacketCount())
				
				let i = getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashPlaybackStartStop)
				if i < 0 {
					break
				}
				let cell = cmdView.view(atColumn: 0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				let sw = cell.viewWithTag(1) as! NSSegmentedControl
				
				sw.selectedSegment = 0
			}
			break
		case NEBLINA_COMMAND_RECORDER_SESSION_READ:
			//print("SessionRead \(curSessionOffset), \(data) \(dataLen)")
			if (errFlag == true) {
				print(" End session errflag")
				flashLabel.stringValue = String(format: "Downloaded session %d : %u", curSessionId, curSessionOffset)
			}
			
			if (errFlag == false && dataLen > 0) {
				let d = NSData(bytes: data, length: dataLen)
				//writing
				if file != nil {
					file?.write(d as Data)
				}
				curSessionOffset += 16
				flashLabel.stringValue = String(format: "Downloading session %d : %u", curSessionId, curSessionOffset)
				nebdev.sessionRead(curSessionId, Len: 16, Offset: curSessionOffset)
				//print("\(curSessionOffset), \(data)")
			}
			else {
				print("End session \(filepath)")
				
				if (dataLen > 0) {
					let d = NSData(bytes: data, length: dataLen)
					//writing
					if file != nil {
						file?.write(d as Data)
					}
				}
				file?.closeFile()
				let i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_SESSION_READ)
				if i < 0 {
					break
				}
				let cell = cmdView.view(atColumn: 0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				let sw = cell.viewWithTag(2) as! NSButton
				
				sw.isEnabled = true
			}
			break
		case NEBLINA_COMMAND_RECORDER_SESSION_COUNT:
			sessionCount = data[0]
			break
		default:
			break
		}
	}
	
	//
	// Eeprom
	//
	func didReceiveEepromData(_ type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		switch (type) {
		case NEBLINA_COMMAND_EEPROM_READ:
			let pageno = UInt16(data[0]) | (UInt16(data[1]) << 8)
			dumpLabel.stringValue = String(format: "EEP page [%d] : %02x %02x %02x %02x %02x %02x %02x %02x",
			                        pageno, data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9])
			break
		case NEBLINA_COMMAND_EEPROM_WRITE:
			break;
		default:
			break
		}
	}
	
	//
	// Sensor data
	//
	func didReceiveSensorData(_ type : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		switch (type) {
		case NEBLINA_COMMAND_SENSOR_ACCELEROMETER:
			let x = (Int16(data[4]) & 0xff) | (Int16(data[5]) << 8)
			let xq = x
			let y = (Int16(data[6]) & 0xff) | (Int16(data[7]) << 8)
			let yq = y
			let z = (Int16(data[8]) & 0xff) | (Int16(data[9]) << 8)
			let zq = z
			dataLabel.stringValue = String("Accel - x:\(xq), y:\(yq), z:\(zq)")
			rxCount += 1
			break
		case NEBLINA_COMMAND_SENSOR_GYROSCOPE:
			let x = (Int16(data[4]) & 0xff) | (Int16(data[5]) << 8)
			let xq = x
			let y = (Int16(data[6]) & 0xff) | (Int16(data[7]) << 8)
			let yq = y
			let z = (Int16(data[8]) & 0xff) | (Int16(data[9]) << 8)
			let zq = z
			dataLabel.stringValue = String("Gyro - x:\(xq), y:\(yq), z:\(zq)")
			rxCount += 1
			break
		case NEBLINA_COMMAND_SENSOR_HUMIDITY:
			break
		case NEBLINA_COMMAND_SENSOR_MAGNETOMETER:
			//
			// Mag data
			//
			//let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			let x = (Int16(data[4]) & 0xff) | (Int16(data[5]) << 8)
			let xq = x
			let y = (Int16(data[6]) & 0xff) | (Int16(data[7]) << 8)
			let yq = y
			let z = (Int16(data[8]) & 0xff) | (Int16(data[9]) << 8)
			let zq = z
			dataLabel.stringValue = String("Mag - x:\(xq), y:\(yq), z:\(zq)")
			rxCount += 1
			//ship.rotation = SCNVector4(Float(xq), Float(yq), 0, GLKMathDegreesToRadians(90))
			break
		case NEBLINA_COMMAND_SENSOR_PRESSURE:
			break
		case NEBLINA_COMMAND_SENSOR_TEMPERATURE:
			break
		case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE:
			let x = (Int16(data[4]) & 0xff) | (Int16(data[5]) << 8)
			let xq = x
			let y = (Int16(data[6]) & 0xff) | (Int16(data[7]) << 8)
			let yq = y
			let z = (Int16(data[8]) & 0xff) | (Int16(data[9]) << 8)
			let zq = z
			dataLabel.stringValue = String("IMU - x:\(xq), y:\(yq), z:\(zq)")
			rxCount += 1
			break
		case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER:
			break
		default:
			break
		}
		cmdView.setNeedsDisplay()
	}
	
}


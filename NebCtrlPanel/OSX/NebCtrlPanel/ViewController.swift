
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
import SceneKit.ModelIO

/*
struct NebDevice {
	let id : UInt64
	let peripheral : CBPeripheral
}
*/

let MotionDataStream = Int32(1)
let Heading = Int32(2)

let NebCmdList = [NebCmdItem] (arrayLiteral:
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_INTERFACE_STATE, ActiveStatus: UInt32(NEBLINA_INTERFACE_STATUS_BLE.rawValue),
	           Name: "BLE Data Port", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_INTERFACE_STATE, ActiveStatus: UInt32(NEBLINA_INTERFACE_STATUS_UART.rawValue),
	           Name: "UART Data Port", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_DEVICE_NAME_SET, ActiveStatus: 0,
	           Name: "Change Device Name", Actuator : ACTUATOR_TYPE_TEXT_FIELD_BUTTON, Text: "Change"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_CALIBRATE_FORWARD_POSITION, ActiveStatus: 0,
	           Name: "Calibrate Forward Pos", Actuator : ACTUATOR_TYPE_BUTTON, Text: "Calib Fwrd"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_CALIBRATE_DOWN_POSITION, ActiveStatus: 0,
	           Name: "Calibrate Down Pos", Actuator : ACTUATOR_TYPE_BUTTON, Text: "Calib Dwn"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STREAM, ActiveStatus: UInt32(NEBLINA_FUSION_STATUS_QUATERNION.rawValue),
	           Name: "Quaternion Stream", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_EULER_ANGLE_STREAM, ActiveStatus: UInt32(NEBLINA_FUSION_STATUS_EULER.rawValue),
			   Name: "Euler Stream", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_ACCELEROMETER_STREAM, ActiveStatus: UInt32(NEBLINA_SENSOR_STATUS_ACCELEROMETER.rawValue),
	           Name: "Accelerometer Sensor Stream", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_GYROSCOPE_STREAM, ActiveStatus: UInt32(NEBLINA_SENSOR_STATUS_GYROSCOPE.rawValue),
	           Name: "Gyroscope Sensor Stream", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM, ActiveStatus: UInt32(NEBLINA_SENSOR_STATUS_MAGNETOMETER.rawValue),
	           Name: "Magnetometer Sensor Stream", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE_STREAM, ActiveStatus: UInt32(NEBLINA_SENSOR_STATUS_ACCELEROMETER_GYROSCOPE.rawValue),
	           Name: "Accel & Gyro Stream", Actuator : ACTUATOR_TYPE_SWITCH, Text:""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_HUMIDITY_STREAM, ActiveStatus: UInt32(NEBLINA_SENSOR_STATUS_HUMIDITY.rawValue),
	           Name: "Humidity Sensor Stream", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_LOCK_HEADING_REFERENCE, ActiveStatus: 0,
	           Name: "Lock Heading Ref.", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_RECORD, ActiveStatus: UInt32(NEBLINA_RECORDER_STATUS_RECORD.rawValue),
	           Name: "Flash Record", Actuator : ACTUATOR_TYPE_BUTTON, Text: "ON"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_RECORD, ActiveStatus: 0,
	           Name: "Flash Record", Actuator : ACTUATOR_TYPE_BUTTON, Text: "OFF"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_PLAYBACK, ActiveStatus: UInt32(NEBLINA_RECORDER_STATUS_READ.rawValue),
	           Name: "Flash Playback", Actuator : ACTUATOR_TYPE_TEXT_FIELD_BUTTON, Text: "Play"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD, ActiveStatus: 0,
	           Name: "Flash Download Session ", Actuator : ACTUATOR_TYPE_TEXT_FIELD_BUTTON, Text: "Start"),
	NebCmdItem(SubSysId: 0xf, CmdId: MotionDataStream, ActiveStatus: 0, Name: "Motion data stream", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: 0xf, CmdId: Heading, ActiveStatus: 0, Name: "Heading", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_FIRMWARE_UPDATE, ActiveStatus: 0,
	           Name: "Firmware Update", Actuator : ACTUATOR_TYPE_BUTTON, Text: "DFU"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_ERASE_ALL, ActiveStatus: 0,
	           Name: "Flash Erase All", Actuator : ACTUATOR_TYPE_BUTTON, Text: "Erase")
)

@available(OSX 10.11, *)
class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, CBCentralManagerDelegate, NeblinaDelegate  {

	let sceneShip = SCNScene(named: "art.scnassets/ship.scn")!
	let sceneCube = SCNScene(named: "art.scnassets/neblina_calibration.dae")!
//	let scene = SCNScene(named: "art.scnassets/Iron_Man/Iron_Man.dae")!
	//let scene = SCNScene(named: "art.scnassets/AstonMartinRapide/rapide.scn")!
	//let scene = SCNScene(named: "art.scnassets/Body_Mesh_Rigged.dae")!
	var ship : SCNNode! //= scene.rootNode.childNodeWithName("ship", recursively: true)!
	var cube : SCNNode!
//	var ship = scene.rootNode.childNodeWithName("Mesh1", recursively: true)!
	var bleCentralManager : CBCentralManager!
//	var objects = [Neblina]()
	var foundDevices = [Neblina]()
	var selectedDevices = [Neblina]()
	var nebdev : Neblina? = nil	// Neblina(devName: nil, devid: 0, peripheral: nil)
	var prevTimeStamp = UInt32(0)
	var timeStamp = UInt32(0)
	var diffTime = UInt32(0)
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
	var downloadRecovering = Bool(false)
	var sysStatusReceived = Bool(false)
	var playback = Bool(false)
	
	@IBOutlet weak var devListView : NSTableView!
	@IBOutlet weak var selectedView : NSTableView!
	@IBOutlet weak var cmdView : NSTableView!
	@IBOutlet weak var versionLabel: NSTextField!
	@IBOutlet weak var dataLabel: NSTextField!
	@IBOutlet weak var flashLabel: NSTextField!
	@IBOutlet weak var dumpLabel: NSTextField!
	@IBOutlet weak var shipScnView: SCNView!
	@IBOutlet weak var cubeScnView: SCNView!
	
	func getCmdIdx(_ subsysId : Int32, cmdId : Int32) -> Int {
		for (idx, item) in NebCmdList.enumerated() {
			if (item.SubSysId == subsysId && item.CmdId == cmdId) {
				return idx
			}
		}
		
		return -1
	}

	func crc16_ansi(_ data : [UInt8], Len : Int, seedVal : UInt16) -> UInt16
	{
		var i = Int(0)
		var s = UInt16(0)
		var t = UInt16(0)
		var crc = UInt16(0)
	
		crc = seedVal

		while i < Len {
			s = UInt16(data[i]) ^ (crc >> 8);
			t = s ^ (s >> 4);
			t ^= (t >> 2);
			t ^= (t >> 1);
			t &= 1;
			t |= (s << 1);
			crc = (crc << 8) ^ t ^ (t << 1) ^ (t << 15);
			i += 1
		}
	
		return crc;
	}
	
	func crc16r_ansi(_ data : [UInt8], Len : Int, seedVal : UInt16) -> UInt16
	{
		var e = UInt16(0)
		var p = UInt16(0)
		var f = UInt16(0)
		var crc = UInt16(0)
		var i = Int(0)
	
		crc = seedVal
		while i < Len {
			e = UInt16(data[i]) ^ crc
			p = e ^ (e >> 4);
			p ^= (p >> 2);
			p ^= (p >> 1);
			p &= 1;
			f = e | (p << 8);
			crc = (crc << 8) ^ (f << 6) ^ (f << 7) ^ (f >> 8);
			i += 1
		}
	
		return crc;
	}
	
	func crc16_ccitt(_ data : [UInt8], Len : Int, seedVal : UInt16) -> UInt16
	{
		var i = Int(0)
		var s = UInt16(0)
		var t = UInt16(0)
		var crc = UInt16(0)
		
		//for (i = 0; i < Len; i += 1)
		while i < Len {
			s = (crc >> 8) ^ UInt16(data[i])
			t = s ^ (s >> 4)
			crc = (crc << 8) ^ t ^ (t << 5) ^ (t << 12)
			i += 1
		}
		
		return crc;
	}
	
	override func viewDidLoad() {
		if #available(OSX 10.10, *) {
			super.viewDidLoad()
		} else {
			// Fallback on earlier versions
		}
		var d : [UInt8] = [0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30]
		
		let crc = crc16_ccitt(d, Len: d.count, seedVal: 0)
		let crc2 = crc16_ansi(d, Len: d.count, seedVal: 0)
		let crc3 = crc16r_ansi(d, Len: d.count, seedVal: 0)
		
		bleCentralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)

		selectedView.target = self
		selectedView.doubleAction = #selector(tableViewDoubleClick(_:))
		
		// Do any additional setup after loading the view.

		let shipCameraNode = SCNNode()
		shipCameraNode.camera = SCNCamera()
		let cubeCameraNode = SCNNode()
		cubeCameraNode.camera = SCNCamera()
		sceneShip.rootNode.addChildNode(shipCameraNode)
		sceneCube.rootNode.addChildNode(cubeCameraNode)

		// place the camera
		//cameraNode.position = SCNVector3(x: 0, y: 1.5, z: 4)
		shipCameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
		cubeCameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
		//cameraNode.rotation = SCNVector4(0, 0, 1, GLKMathDegreesToRadians(-180))
		//cameraNode.rotation = SCNVector3(x:
		// create and add a light to the scene
		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light!.type = SCNLight.LightType.omni
		lightNode.position = SCNVector3(x: 3, y: 10, z: 50)
		sceneShip.rootNode.addChildNode(lightNode)
		sceneCube.rootNode.addChildNode(lightNode)

		// create and add an ambient light to the scene
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = SCNLight.LightType.ambient
		ambientLightNode.light!.color = NSColor.darkGray
		sceneShip.rootNode.addChildNode(ambientLightNode)
		sceneCube.rootNode.addChildNode(ambientLightNode)

		
		// retrieve the ship node
		
		//		ship = scene.rootNode.childNodeWithName("MillenniumFalconTop", recursively: true)!
		//ship = scene.rootNode.childNode(withName :"Low_Poly_Characte_000_Mesh_001", recursively: true)!
		//ship = scene.rootNode.childNode(withName :"Armature", recursively: true)!
		ship = sceneShip.rootNode.childNode(withName: "ship", recursively: true)!
		cube = sceneCube.rootNode.childNode(withName: "node", recursively: true)!
		//		ship = scene.rootNode.childNode(withName: "MDL_OBJ", recursively: true)!
		//		ship = scene.rootNode.childNode(withName: "Generic_Character_BlendShapesSet", recursively: true)!
		//scene.rootNode.childNodes[1]
		print("\(ship.childNodes)")
		if #available(OSX 10.10, *) {
		//	ship.eulerAngles = SCNVector3Make(CGFloat(GLKMathDegreesToRadians(90)), 0, CGFloat(GLKMathDegreesToRadians(180)))
		//	ship.eulerAngles = SCNVector3Make(0, CGFloat(GLKMathDegreesToRadians(90)), 0)

		} else {
			// Fallback on earlier versions
		}
		//ship.physicsBody = nil
		//cube.physicsBody = nil
		//ship.rotation = SCNVector4(1, 0, 0, GLKMathDegreesToRadians(90))
		//print("1 - \(ship)")
		// animate the 3d object
		//ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
		//ship.runAction(SCNAction.rotateToX(CGFloat(eulerAngles.x), y: CGFloat(eulerAngles.y), z: CGFloat(eulerAngles.z), duration:1 ))// 10, y: 0.0, z: 0.0, duration: 1))

		//let armature = scene.rootNode.childNode(withName :"Armature", recursively: true)!

		//In some Blender output DAE, animation is child of armature, in others it has no child. Not sure what causes this. Hence:
		//armature.removeAllAnimations()

		//ship.addChildNode(armature)
		
		// retrieve the SCNView
		
		// set the scene to the view
		shipScnView.scene = sceneShip
		cubeScnView.scene = sceneCube

		// allows the user to manipulate the camera
		shipScnView.allowsCameraControl = true
		cubeScnView.allowsCameraControl = true

		// show statistics such as fps and timing information
		shipScnView.showsStatistics = true
		cubeScnView.showsStatistics = true
		
		// configure the view
		shipScnView.backgroundColor = NSColor.black
		cubeScnView.backgroundColor = NSColor.black
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
		flashLabel.stringValue = " "
		let row = cmdView.row(for: sender.superview!.superview!)
		//let row = (idx?.row)! as Int
		
		if (row < NebCmdList.count) {
			switch (NebCmdList[row].SubSysId)
			{
			case NEBLINA_SUBSYSTEM_GENERAL:
				switch (NebCmdList[row].CmdId)
				{
				case NEBLINA_COMMAND_GENERAL_FIRMWARE_UPDATE:
					nebdev?.firmwareUpdate()
					break
				case NEBLINA_COMMAND_GENERAL_DEVICE_NAME_SET:
					let cell = cmdView.rowView(atRow: row, makeIfNecessary: false)
					if (cell != nil) {
						let control = cell!.viewWithTag(4) as! NSTextField
						nebdev?.setDeviceName(name: control.stringValue);
					}

					break
				default:
					break
				}
				break
			case NEBLINA_SUBSYSTEM_EEPROM:
				switch (NebCmdList[row].CmdId)
				{
				case NEBLINA_COMMAND_EEPROM_READ:
					nebdev?.eepromRead(0)
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
					case NEBLINA_COMMAND_RECORDER_ERASE_ALL:
						flashEraseProgress = true;
						nebdev?.eraseStorage(false)
						break
					case NEBLINA_COMMAND_RECORDER_RECORD:
						var i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_RECORD)
						if row - i > 0 {
							nebdev?.sessionRecord(false, info: "")
						}
						else {
							nebdev?.sessionRecord(true, info: "")
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
									filepath.append(String(format:"/%@/", (nebdev?.device.name!)!))
									do {
										try FileManager.default.createDirectory(atPath: filepath, withIntermediateDirectories: false, attributes: nil)
										
									} catch let error as NSError {
										print(error.localizedDescription);
									}
									filepath.append(String(format:"%@_%d.dat", (nebdev?.device.name!)!, curSessionId))
									FileManager.default.createFile(atPath: filepath, contents: nil, attributes: nil)
									do {
										try file = FileHandle(forWritingAtPath: filepath)
									} catch { print("file failed \(filepath)")}
									nebdev?.sessionRead(curSessionId, Len: 16, Offset: 0)
								}
								//}
							}
						}

						
					break
				case NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD:
					let i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD)
					if i >= 0 {
						let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
						if (cell != nil) {
							let control = cell!.viewWithTag(4) as! NSTextField
							let but = cell!.viewWithTag(2) as! NSButton
							if (nebdev?.isDeviceReady())! {
								but.isEnabled = false
			
								curSessionId = UInt16(control.integerValue)
								startDownload = true
								curSessionOffset = 0
								//let filename = String(format:"NeblinaRecord_%d.dat", curSessionId)
								let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
																				   .userDomainMask, true)
								if dirPaths != nil {
									filepath = dirPaths[0]// as! String
									filepath.append(String(format:"/%@/", (nebdev?.device.name!)!))
									do {
										try FileManager.default.createDirectory(atPath: filepath, withIntermediateDirectories: false, attributes: nil)
										
									} catch let error as NSError {
										print(error.localizedDescription);
									}
									filepath.append(String(format:"%@_%d.dat", (nebdev?.device.name!)!, curSessionId))
									FileManager.default.createFile(atPath: filepath, contents: nil, attributes: nil)
									do {
										try file = FileHandle(forWritingAtPath: filepath)
									} catch { print("file failed \(filepath)")}
									nebdev?.sessionDownload(true, SessionId : curSessionId, Len: 16, Offset: 0)
								}
							}
						}
					}
					
					
					break
				case NEBLINA_COMMAND_RECORDER_PLAYBACK:
					let i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_PLAYBACK)
					if i >= 0 {
						let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
						if (cell != nil) {
							let control = cell!.viewWithTag(4) as! NSTextField
							let but = cell!.viewWithTag(2) as! NSButton
							if playback {
								nebdev?.sessionPlayback(false, sessionId : UInt16(control.integerValue))
								playback = false
								but.title = "Play"
							}
							else {
								if (nebdev?.isDeviceReady())! {
									//but.isEnabled = false
									but.title = "Stop"
									nebdev?.sessionPlayback(true, sessionId : UInt16(control.integerValue))
									PaketCnt = 0
									prevTimeStamp = 0;
									playback = true
								}
							}
						}
					}
					
					
					break
				default:
					break
				}
			case NEBLINA_SUBSYSTEM_FUSION:
				switch (NebCmdList[row].CmdId) {
				case NEBLINA_COMMAND_FUSION_CALIBRATE_FORWARD_POSITION:
					nebdev?.calibrateForwardPosition()
					break
				case NEBLINA_COMMAND_FUSION_CALIBRATE_DOWN_POSITION:
					nebdev?.calibrateDownPosition()
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
					nebdev?.setLed(UInt8(row - i), Value: UInt8(value))
				}
				break
			case NEBLINA_SUBSYSTEM_POWER:
				nebdev?.setBatteryChargeCurrent(UInt16(value))
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
					nebdev?.setDataPort(row, Ctrl:UInt8(sender.selectedSegment))
					break;
				default:
					break
				}
				break
				
			case NEBLINA_SUBSYSTEM_FUSION:
				switch (NebCmdList[row].CmdId)
				{
				case NEBLINA_COMMAND_FUSION_MOTION_STATE_STREAM:
					nebdev?.streamMotionState(sender.selectedSegment == 1)
					break
//				case NEBLINA_COMMAND_FUSION_IMU_STATE:
//					nebdev.streamIMU(sender.selectedSegment == 1)
					break
				case NEBLINA_COMMAND_FUSION_QUATERNION_STREAM:
					nebdev?.streamEulerAngle(false)
					heading = false
					prevTimeStamp = 0
					nebdev?.streamQuaternion(sender.selectedSegment == 1)
					let i = getCmdIdx(0xf,  cmdId: 1)
					if i < 0 {
						break
					}
					let cell = cmdView.view(atColumn: 0, row: i, makeIfNecessary: false)! as NSView
					let control = cell.viewWithTag(1) as! NSSegmentedControl

					control.selectedSegment = 0
					break
				case NEBLINA_COMMAND_FUSION_EULER_ANGLE_STREAM:
					nebdev?.streamQuaternion(false)
					nebdev?.streamEulerAngle(sender.selectedSegment == 1)
					break
				case NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STREAM:
					nebdev?.streamExternalForce(sender.selectedSegment == 1)
					break
				case NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM:
					nebdev?.streamPedometer(sender.selectedSegment == 1)
					break;
				case NEBLINA_COMMAND_FUSION_TRAJECTORY_RECORD:
					nebdev?.recordTrajectory(sender.selectedSegment == 1)
					break;
				case NEBLINA_COMMAND_FUSION_TRAJECTORY_INFO_STREAM:
					nebdev?.streamTrajectoryInfo(sender.selectedSegment == 1)
					break;
//				case NEBLINA_COMMAND_FUSION_MAG_STATE:
//					nebdev.streamMAG(sender.selectedSegment == 1)
					break;
				case NEBLINA_COMMAND_FUSION_LOCK_HEADING_REFERENCE:
					nebdev?.lockHeadingReference()
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
					nebdev?.setLed(UInt8(row - i), Value: UInt8(sender.selectedSegment))
				}
				break
			case NEBLINA_SUBSYSTEM_RECORDER:
				switch (NebCmdList[row].CmdId)
				{
					
				case NEBLINA_COMMAND_RECORDER_ERASE_ALL:
					if (sender.selectedSegment == 1) {
						flashEraseProgress = true;
					}
					nebdev?.eraseStorage(sender.selectedSegment == 1)
					break
				case NEBLINA_COMMAND_RECORDER_RECORD:
					nebdev?.sessionRecord(sender.selectedSegment == 1, info: "")
					break
				case NEBLINA_COMMAND_RECORDER_PLAYBACK:
					
					nebdev?.sessionPlayback(sender.selectedSegment == 1, sessionId : 0xFFFF)
					if (sender.selectedSegment == 1) {
						PaketCnt = 0
					}
					prevTimeStamp = 0;
					break
				case NEBLINA_COMMAND_RECORDER_SESSION_READ:
					nebdev?.getSessionCount()
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
					nebdev?.eepromRead(0)
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
					case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_STREAM:
						nebdev?.sensorStreamAccelData(sender.selectedSegment == 1)
						break
					case NEBLINA_COMMAND_SENSOR_GYROSCOPE_STREAM:
						nebdev?.sensorStreamGyroData(sender.selectedSegment == 1)
						break
					case NEBLINA_COMMAND_SENSOR_HUMIDITY_STREAM:
						nebdev?.sensorStreamHumidityData(sender.selectedSegment == 1)
						break
					case NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM:
						nebdev?.sensorStreamMagData(sender.selectedSegment == 1)
						break
					case NEBLINA_COMMAND_SENSOR_PRESSURE_STREAM:
						nebdev?.sensorStreamPressureData(sender.selectedSegment == 1)
						break
					case NEBLINA_COMMAND_SENSOR_TEMPERATURE_STREAM:
						nebdev?.sensorStreamTemperatureData(sender.selectedSegment == 1)
						break
					case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE_STREAM:
						nebdev?.sensorStreamAccelGyroData(sender.selectedSegment == 1)
						break
					case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER_STREAM:
						nebdev?.sensorStreamAccelMagData(sender.selectedSegment == 1)
						break
					default:
						break
				}
				break
			case 0xF:
				switch (NebCmdList[row].CmdId) {
					case Heading:	// Heading
						nebdev?.streamQuaternion(false)
						nebdev?.streamEulerAngle(true)
						heading = sender.selectedSegment == 1
						var i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STREAM)
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
						nebdev?.streamQuaternion(sender.selectedSegment == 1)
						var i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STREAM)
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
/*						nebdev.streamMAG(sender.selectedSegment == 1)
						i = getCmdIdx(NEBLINA_SUBSYSTEM_SENSOR,  cmdId: NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM)
						if i >= 0 {
							let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! NSSegmentedControl
								control.selectedSegment = sender.selectedSegment
							}
						}*/
						nebdev?.streamExternalForce(sender.selectedSegment == 1)
						i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STREAM)
						if i >= 0 {
							let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! NSSegmentedControl
								control.selectedSegment = sender.selectedSegment
							}
						}
						nebdev?.streamPedometer(sender.selectedSegment == 1)
						i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM)
						if i >= 0 {
							let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! NSSegmentedControl
								control.selectedSegment = sender.selectedSegment
							}
						}
						nebdev?.streamRotationInfo(sender.selectedSegment == 1, Type: 2)
						i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_ROTATION_INFO_STREAM)
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
				nebdev?.streamQuaternion(false)
				nebdev?.streamEulerAngle(true)
				heading = sender.selectedSegment == 1
				let i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STREAM)
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
	
	@objc func tableViewDoubleClick(_ sender:AnyObject) {
		let dev = selectedDevices.remove(at: self.selectedView.selectedRow)
		
		devListView.reloadData()
		selectedView.reloadData()
		
		bleCentralManager.cancelPeripheralConnection(dev.device)
		bleCentralManager.scanForPeripherals(withServices: [NEB_SERVICE_UUID], options: nil)		
	}
	
	func numberOfRows(in tableView: NSTableView) -> Int
	//func numberOfRowsInSection(aTableView: NSTableView) -> Int
	{
		if tableView == devListView {
			return foundDevices.count
		}
		else if tableView == cmdView {
			return NebCmdList.count
		}
		else if tableView == selectedView {
			return selectedDevices.count
		}
		
		return 0
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
	{
		if (tableView == devListView) {
			if (row < foundDevices.count) {
				let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CellDevice"), owner: self) as! NSTableCellView
			
				if foundDevices[row].device.name != nil {
					cellView.textField!.stringValue = foundDevices[row].device.name!
				}
				else {
					cellView.textField!.stringValue = String("NoName")
				}
				cellView.textField!.stringValue += String(format: "_%lX", foundDevices[row].id)
				
				return cellView;
			}
		}
		if (tableView == selectedView) {
			if (row < selectedDevices.count) {
				let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CellDevice"), owner: self) as! NSTableCellView
				
				if selectedDevices[row].device.name != nil {
					cellView.textField!.stringValue = selectedDevices[row].device.name!
				}
				else {
					cellView.textField!.stringValue = String("NoName")
				}
				cellView.textField!.stringValue += String(format: "_%lX", selectedDevices[row].id)
				
				return cellView;
			}
		}
		if (tableView == cmdView) {
			if (row < NebCmdList.count)
			{
				
				let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CellCmd"), owner: self) as! NSTableCellView
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
						let ctrl1 = cellView.viewWithTag(1) as! NSSegmentedControl
						ctrl1.isHidden = true
						
						break
						
					case 2:
						let ctrl = cellView.viewWithTag(NebCmdList[row].Actuator) as! NSButton
						ctrl.isHidden = false
						if !NebCmdList[row].Text.isEmpty
						{
							ctrl.title = NebCmdList[row].Text
						}
						let ctrl1 = cellView.viewWithTag(1) as! NSSegmentedControl
						ctrl1.isHidden = true
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
	
	func tableViewSelectionDidChange(_ notification: Notification)
	{
		let t = notification.object as! NSTableView
		if (t == devListView) {
			if (self.devListView.numberOfSelectedRows > 0)
			{
//				bleCentralManager.stopScan()
				bleCentralManager.connect(self.foundDevices[self.devListView.selectedRow].device, options: nil)

//				bleCentralManager.connect(dev.device, options: nil)
//				selectedDevices.append(dev)
				
				
			//self.tableView.deselectRow(self.tableView.selectedRow)
			}
		}
		if t == selectedView {
		}
	}

/*	func scrollViewDidScroll(_ scrollView: UIScrollView)
	{
		if (nebdev == nil) {
			return
		}
		
		nebdev!.getSystemStatus()
		//nebdev!.getFusionStatus()
		//nebdev!.getDataPortState()
		//nebdev!.getLed()
	}
*/
	func updateUI(status : NeblinaSystemStatus_t) {
		for idx in 0...NebCmdList.count - 1 {
			switch (NebCmdList[idx].SubSysId) {
				case NEBLINA_SUBSYSTEM_GENERAL:
					switch (NebCmdList[idx].CmdId) {
						case NEBLINA_COMMAND_GENERAL_INTERFACE_STATE:
							let cell = cmdView.view(atColumn: 0, row: idx, makeIfNecessary: false)! as NSView
							let control = cell.viewWithTag(1) as! NSSegmentedControl
							if NebCmdList[idx].ActiveStatus & UInt32(status.interface) == 0 {
								control.selectedSegment = 0
							}
							else {
								control.selectedSegment = 1
							}
						default:
							break
					}
				case NEBLINA_SUBSYSTEM_FUSION:
					let cell = cmdView.view(atColumn: 0, row: idx, makeIfNecessary: false)! as NSView
					let control = cell.viewWithTag(1) as! NSSegmentedControl
					print("\(idx) \(NebCmdList[idx].ActiveStatus) \(status.fusion)")
					if NebCmdList[idx].ActiveStatus & status.fusion == 0 {
						control.selectedSegment = 0
					}
					else {
						control.selectedSegment = 1
					}
				case NEBLINA_SUBSYSTEM_SENSOR:
					let cell = cmdView.view(atColumn: 0, row: idx, makeIfNecessary: false)! as NSView
					let control = cell.viewWithTag(1) as! NSSegmentedControl
					if (NebCmdList[idx].ActiveStatus & UInt32(status.sensor)) == 0 {
						control.selectedSegment = 0
					}
					else {
						control.selectedSegment = 1
				}
				case NEBLINA_SUBSYSTEM_RECORDER:
					if NebCmdList[idx].CmdId == NEBLINA_COMMAND_RECORDER_PLAYBACK {
						let cell = cmdView.view(atColumn: 0, row: idx, makeIfNecessary: false)! as NSView
						let control = cell.viewWithTag(1) as! NSSegmentedControl
						if status.recorder == NEBLINA_RECORDER_STATUS_READ.rawValue {
							control.selectedSegment = 1
						}
						else {
							control.selectedSegment = 0
						}
					}
				default:
					break
			}
		}
			/*
		 idx = getCmdIdx(NEBLINA_SUBSYSTEM_GENERAL,  cmdId: NEBLINA_COMMAND_GENERAL_INTERFACE_STATE)
		if idx >= 0 {
			let cell = cmdView.view(atColumn: 0, row: idx, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
			let sw = cell.viewWithTag(1) as! NSSegmentedControl
			if (status.interface & UInt8(NEBLINA_INTERFACE_STATUS_BLE.rawValue)) == 0 {
				sw.selectedSegment = 0
			}
			else {
				sw.selectedSegment = 1
			}
		}
		idx = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STATE)
		if idx >= 0 {
			let cell = cmdView.view(atColumn: 0, row: idx, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
			let sw = cell.viewWithTag(1) as! NSSegmentedControl
			if (status.fusion & UInt32(NEBLINA_FUSION_STATUS_QUATERNION.rawValue)) == 0 {
				sw.selectedSegment = 0
			}
			else {
				sw.selectedSegment = 1
			}
		}
		}*/
	}
	// MARK: - Bluetooth
	func centralManager(_ central: CBCentralManager,
	                    didDiscover peripheral: CBPeripheral,
						advertisementData : [String : Any],
						rssi RSSI: NSNumber) {
		print("PERIPHERAL NAME: \(peripheral)\n AdvertisementData: \(advertisementData)\n RSSI: \(RSSI)\n")
		
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

		if peripheral.name == nil {
			return
		}
		
		if advertisementData[CBAdvertisementDataManufacturerDataKey] == nil {
			return
		}

		print("CBAdvertisementDataManufacturerDataKey")
		if (advertisementData[CBAdvertisementDataManufacturerDataKey] as! NSData).length < 10 {
			return
		}
		
		var id = UInt64 (0)

		(advertisementData[CBAdvertisementDataManufacturerDataKey] as! NSData).getBytes(&id, range: NSMakeRange(2, 8))
		if (id == 0) {
			return
		}

		
		for dev in foundDevices
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
		foundDevices.insert(device, at: 0)
		
		devListView.reloadData();
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		central.stopScan()

		if (self.devListView.numberOfSelectedRows > 0)
		{
			//if nebdev.device != nil {
			//	central.cancelPeripheralConnection(nebdev.device)
			//}
			dataLabel.stringValue = String(" ")
			flashLabel.stringValue = String(" ")
			
			let dev = foundDevices.remove(at: self.devListView.selectedRow)
			dev.device.delegate = dev
			
			selectedDevices.append(dev)
			//nebdev.delegate = nil
			nebdev = dev
			nebdev?.delegate = self
			nebdev?.device.discoverServices(nil)
			devListView.reloadData()
			selectedView.reloadData()
			
			//nebdev = foundDevices[self.devListView.selectedRow - 1]
			//nebdev.delegate = self
			//nebdev.device.discoverServices(nil)
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
			scanPeripheral(central)
			//bleCentralManager.scanForPeripherals(withServices: [NEB_SERVICE_UUID], options: nil)
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
		prevTimeStamp = 0;
		nebdev?.getSystemStatus()
		nebdev?.getFirmwareVersion()
		//nebdev.getFusionStatus()
		//nebdev.getDataPortState()
		//nebdev.getLed ()
	}
	
	func didReceiveResponsePacket(sender: Neblina, subsystem: Int32, cmdRspId: Int32, data: UnsafePointer<UInt8>, dataLen: Int) {
		switch subsystem {
		case NEBLINA_SUBSYSTEM_GENERAL:
			switch (cmdRspId) {
			case NEBLINA_COMMAND_GENERAL_SYSTEM_STATUS:
				sysStatusReceived = true;
				var myStruct = NeblinaSystemStatus_t()
				let status = withUnsafeMutablePointer(to: &myStruct) {_ in UnsafeMutableRawPointer(mutating: data)}
				print("Status \(status)")
				//let d = data.load(as: NeblinaSystemStatus_t.self)// UnsafeBufferPointer<NeblinaSystemStatus_t>(data)
				let d = UnsafeMutableRawPointer(mutating: data).load(as: NeblinaSystemStatus_t.self)			//print(" \(d)")
				updateUI(status: d)
			//	MemoryLayout<yLayout<\(d)")
			case NEBLINA_COMMAND_GENERAL_FIRMWARE_VERSION:
				let vers = UnsafeMutableRawPointer(mutating: data).load(as: NeblinaFirmwareVersion_t.self)
				let b = (UInt32(vers.firmware_build.0) & 0xFF) | ((UInt32(vers.firmware_build.1) & 0xFF) << 8) | ((UInt32(vers.firmware_build.2) & 0xFF) << 16)
				//let d = data.load(as: NeblinaFirmwareVersion_t.self)
				
				versionLabel.stringValue = String(format: "API:%d, Firm. Ver.:%d.%d.%d-%d", vers.api,
												  vers.firmware_major, vers.firmware_minor, vers.firmware_patch, b)
				//String(format: "API:%d, FEN:%d.%d.%d, BLE:%d.%d.%d", vers.api,
				//								  vers.coreVersion.major, vers.coreVersion.minor, vers.coreVersion.build,
				//								  vers.bleVersion.major, vers.bleVersion.minor, vers.bleVersion.build)
//					String(format: "API:%d, FEN:%d.%d.%d, BLE:%d.%d.%d", d.apiVersion,
//												  d.coreVersion.major, d.coreVersion.minor, d.coreVersion.build,
//												  d.bleVersion.major, d.bleVersion.minor, d.bleVersion.build)
				if sysStatusReceived == false {
					nebdev?.getSystemStatus()
				}
				//				print("\(versionLabel.stringValue)")
			default:
				break
			}
		case NEBLINA_SUBSYSTEM_RECORDER:
			switch (cmdRspId) {
				case NEBLINA_COMMAND_RECORDER_RECORD:
					break
				case NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD:
					break
				case NEBLINA_COMMAND_RECORDER_PLAYBACK:
					if data[0] != 0 {
						break
					}
					let id = (UInt16(data[0]) & 0xFF) | ((UInt16(data[1]) & 0xFF) << 8)
					flashLabel.stringValue = "Playback completed"
					playback = false
					let i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_PLAYBACK)
					if i >= 0 {
						let cell = cmdView.rowView(atRow: i, makeIfNecessary: false)
						if (cell != nil) {
							let control = cell!.viewWithTag(4) as! NSTextField
							let but = cell!.viewWithTag(2) as! NSButton
							but.title = "Play"
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
	
	func didReceiveRSSI(sender : Neblina, rssi : NSNumber) {
		
	}

	func didReceiveBatteryLevel(sender: Neblina, level: UInt8) {
	
	}
	
	//
	// General data
	//
	func didReceiveGeneralData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafeRawPointer, dataLen : Int, errFlag : Bool) {
		//UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		switch (cmdRspId) {
			case NEBLINA_COMMAND_GENERAL_SYSTEM_STATUS:
				sysStatusReceived = true;
				var myStruct = NeblinaSystemStatus_t()
				let status = withUnsafeMutablePointer(to: &myStruct) {_ in UnsafeMutableRawPointer(mutating: data)}
				print("Status \(status)")
				let d = data.load(as: NeblinaSystemStatus_t.self)// UnsafeBufferPointer<NeblinaSystemStatus_t>(data)
				print(" \(d)")
				updateUI(status: d)
				//	MemoryLayout<yLayout<\(d)")
			case NEBLINA_COMMAND_GENERAL_FIRMWARE_VERSION:
				let vers = data.load(as: NeblinaFirmwareVersion_t.self)
				let b = (UInt32(vers.firmware_build.0) & 0xFF) | ((UInt32(vers.firmware_build.1) & 0xFF) << 8) | ((UInt32(vers.firmware_build.2) & 0xFF) << 16)
				versionLabel.stringValue = String(format: "API:%d, Firm. Ver.:%d.%d.%d-%d", vers.api,
												  vers.firmware_major, vers.firmware_minor, vers.firmware_patch, b
				)
				if sysStatusReceived == false {
					nebdev?.getSystemStatus()
				}
//				print("\(versionLabel.stringValue)")
			
			default:
				break
		}
	}
	
	//
	// Fusion data
	//
	func didReceiveFusionData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : NeblinaFusionPacket_t, errFlag : Bool) {
		
		if sysStatusReceived == false {
			nebdev?.getSystemStatus()
		}
		//let errflag = Bool(type.rawValue & 0x80 == 0x80)
		
		//let id = FusionId(rawValue: type.rawValue & 0x7F)! as FusionId
//		flashLabel.text = String(format: "Total packet %u @ %0.2f pps", nebdev.getPacketCount(), nebdev.getDataRate())
		
		switch (cmdRspId) {
			
//		case NEBLINA_COMMAND_FUSION_MOTION_STATE:
//			break
//		case NEBLINA_COMMAND_FUSION_IMU_STATE:
//			break
		case NEBLINA_COMMAND_FUSION_EULER_ANGLE_STREAM:
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
		case NEBLINA_COMMAND_FUSION_QUATERNION_STREAM:
			
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
//			print("\(data.timestamp)")
			if (prevTimeStamp == 0 || data.timestamp <= prevTimeStamp)
			{
				prevTimeStamp = data.timestamp;
				startTime = Date()
				rxCount = 0
			}
			else
			{
				let tdiff = data.timestamp - prevTimeStamp;
				if (tdiff > 18000)
				{
					dropCnt += 1
					dumpLabel.stringValue = String("\(dropCnt) Drop : \(tdiff)")
				}
				if (tdiff < 8)
				{
					print("diff \(tdiff)")
				}
				rxCount += 1
				prevTimeStamp = data.timestamp
				let curDate =  Date()
				let rate = (Double(rxCount) * 20.0) / curDate.timeIntervalSince(startTime)
				//print("\(data.timestamp), \(tdiff)")
			}
			
			ship.orientation = SCNQuaternion(-zq, xq, yq, wq)
			cube.orientation = SCNQuaternion(-zq, xq, yq, wq)
			dataLabel.stringValue = String(format:"Quat - x:%.2f, y:%.2f, z:%.2f, w:%.2f", xq, yq, zq, wq)
/*			for (idx, item) in selectedDevices.enumerated() {
				if (sender == item) {
				switch idx {
				case 0:
					let node = ship.childNode(withName :"Leg_l", recursively: true)!
					node.orientation = SCNQuaternion(yq, xq, zq, wq)
					break
				case 1:
					let node = ship.childNode(withName :"Leg_r", recursively: true)!
					node.orientation = SCNQuaternion(yq, xq, zq, wq)
					break
				default:
					break
				}
				}
			}*/
			//print("\(ship.childNodes[0].childNodes)")
			break
		case NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STREAM:
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
		case NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM:
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
	func didReceivePmgntData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		let value = UInt16(data[0]) | (UInt16(data[1]) << 8)
		if (cmdRspId == NEBLINA_COMMAND_POWER_CHARGE_CURRENT)
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
	func didReceiveLedData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		switch (cmdRspId) {
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
	func didReceiveDebugData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	{
		//print("Debug \(type) data \(data)")
		switch (cmdRspId) {
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
	func didReceiveRecorderData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {

		switch (cmdRspId) {
		case NEBLINA_COMMAND_RECORDER_ERASE_ALL:
			flashLabel.stringValue = "Flash erased"
			let i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_ERASE_ALL)
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
				flashLabel.stringValue = String(format: "End session %d, %u", session, (nebdev?.getPacketCount())!)
				
				let i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_PLAYBACK)
				if i < 0 {
					break
				}
				let cell = cmdView.view(atColumn: 0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				let sw = cell.viewWithTag(2) as! NSButton
				
				//sw.isEnabled = true
				sw.title = "Play"
				playback = false
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
				curSessionOffset += UInt32(dataLen)
				flashLabel.stringValue = String(format: "Downloading session %d : %u", curSessionId, curSessionOffset)
				if cmdRspId == NEBLINA_COMMAND_RECORDER_SESSION_READ {
					nebdev?.sessionRead(curSessionId, Len: 16, Offset: curSessionOffset)
				}
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
		case NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD:
//			print("SessionDownload \(curSessionOffset), \(offset), \(data) \(dataLen)")
			
			if (errFlag == false && dataLen > 0) {

				if dataLen < 4 {
					//print("\(data)")
					break
				}
				
				let offset = UInt32(UInt32(data[0]) | (UInt32(data[1]) << 8) | (UInt32(data[2]) << 16) | (UInt32(data[3]) << 24))
				if curSessionOffset != offset {
					// packet loss
					print("SessionDownload \(curSessionOffset), \(offset), \(data) \(dataLen)")
					if downloadRecovering == false {
						nebdev?.sessionDownload(false, SessionId: curSessionId, Len: 12, Offset: curSessionOffset)
						downloadRecovering = true
					}
				}
				else {
					downloadRecovering = false
					let d = NSData(bytes: data + 4, length: dataLen - 4)
					//writing
					if file != nil {
						
						file?.write(d as Data)
					}
					curSessionOffset += UInt32(dataLen-4)
					flashLabel.stringValue = String(format: "Downloading session %d : %u", curSessionId, curSessionOffset)
				}
				//print("\(curSessionOffset), \(data)")
			}
			else {
				print("End session \(filepath)")
				print(" Download End session errflag")
				flashLabel.stringValue = String(format: "Downloaded session %d : %u", curSessionId, curSessionOffset)
				
				if (dataLen > 0) {
					let d = NSData(bytes: data, length: dataLen)
					//writing
					if file != nil {
						file?.write(d as Data)
					}
				}
				file?.closeFile()
				let i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD)
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
	func didReceiveEepromData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		switch (cmdRspId) {
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
	func didReceiveSensorData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		if sysStatusReceived == false {
			nebdev?.getSystemStatus()
		}
		switch (cmdRspId) {
		case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_STREAM:
			let x = (Int16(data[4]) & 0xff) | (Int16(data[5]) << 8)
			//let xq = x
			let y = (Int16(data[6]) & 0xff) | (Int16(data[7]) << 8)
			//let yq = y
			let z = (Int16(data[8]) & 0xff) | (Int16(data[9]) << 8)
			//let zq = z
			dataLabel.stringValue = String("Accel - x:\(x), y:\(y), z:\(z)")
			//rxCount += 1
			//timeStamp = (UInt32(data[0]) & 0xff) | (UInt32(data[1]) << 8) | (UInt32(data[2]) << 16) | (UInt32(data[2]) << 24)
			//print("Time: \(t)")
			//if (t - prevTimeStamp) > 10
//			diffTime = timeStamp - prevTimeStamp;
/*			if (diffTime > 18000)
			{
				dropCnt += 1
				dumpLabel.stringValue = String("\(dropCnt) Drop : \(diffTime)")
			}
		
			if (diffTime < 8)
			{
				print("diff \(diffTime)")
			}
			rxCount += 1
			prevTimeStamp = timeStamp
*/
			break
		case NEBLINA_COMMAND_SENSOR_GYROSCOPE_STREAM:
			let x = (Int16(data[4]) & 0xff) | (Int16(data[5]) << 8)
			let xq = x
			let y = (Int16(data[6]) & 0xff) | (Int16(data[7]) << 8)
			let yq = y
			let z = (Int16(data[8]) & 0xff) | (Int16(data[9]) << 8)
			let zq = z
			dataLabel.stringValue = String("Gyro - x:\(xq), y:\(yq), z:\(zq)")
			rxCount += 1
			break
		case NEBLINA_COMMAND_SENSOR_HUMIDITY_STREAM:
			break
		case NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM:
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
		case NEBLINA_COMMAND_SENSOR_PRESSURE_STREAM:
			break
		case NEBLINA_COMMAND_SENSOR_TEMPERATURE_STREAM:
			break
		case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE_STREAM:
			let x = (Int16(data[4]) & 0xff) | (Int16(data[5]) << 8)
			let xq = x
			let y = (Int16(data[6]) & 0xff) | (Int16(data[7]) << 8)
			let yq = y
			let z = (Int16(data[8]) & 0xff) | (Int16(data[9]) << 8)
			let zq = z
			dataLabel.stringValue = String("IMU - x:\(xq), y:\(yq), z:\(zq)")
			rxCount += 1
			break
		case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER_STREAM:
			break
		default:
			break
		}
		cmdView.setNeedsDisplay()
	}
	
}


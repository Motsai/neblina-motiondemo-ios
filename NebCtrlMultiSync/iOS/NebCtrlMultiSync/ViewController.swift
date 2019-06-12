//
//  ViewController.swift
//  BauerPanel
//
//  Created by Hoan Hoang on 2017-02-23.
//  Copyright © 2017 Hoan Hoang. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore
import SceneKit


let CmdMotionDataStream = Int32(1)
let CmdHeading = Int32(2)

let NebCmdList = [NebCmdItem] (arrayLiteral:
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_INTERFACE_STATE, ActiveStatus: UInt32(NEBLINA_INTERFACE_STATUS_BLE.rawValue),
	           Name: "BLE Data Port", Actuator : 1, Text: ""),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_INTERFACE_STATE, ActiveStatus: UInt32(NEBLINA_INTERFACE_STATUS_UART.rawValue),
			  Name: "UART Data Port", Actuator : 1, Text: ""),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_CALIBRATE_FORWARD_POSITION, ActiveStatus: 0,
			  Name: "Calibrate Forward Pos", Actuator : 2, Text: "Calib Fwrd"),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_CALIBRATE_DOWN_POSITION, ActiveStatus: 0,
			  Name: "Calibrate Down Pos", Actuator : 2, Text: "Calib Dwn"),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_FUSION_TYPE, ActiveStatus: 0,
			  Name: "Fusion 9 axis", Actuator : 1, Text:""),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_RESET_TIMESTAMP, ActiveStatus: 0,
			  Name: "Reset timestamp", Actuator : 2, Text: "Reset"),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STREAM, ActiveStatus: UInt32(NEBLINA_FUSION_STATUS_QUATERNION.rawValue),
			  Name: "Quaternion Stream", Actuator : 1, Text: ""),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_ACCELEROMETER_STREAM, ActiveStatus: UInt32(NEBLINA_SENSOR_STATUS_ACCELEROMETER.rawValue),
			  Name: "Accelerometer Sensor Stream", Actuator : 1, Text: ""),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_GYROSCOPE_STREAM, ActiveStatus: UInt32(NEBLINA_SENSOR_STATUS_GYROSCOPE.rawValue),
			  Name: "Gyroscope Sensor Stream", Actuator : 1, Text: ""),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM, ActiveStatus: UInt32(NEBLINA_SENSOR_STATUS_MAGNETOMETER.rawValue),
			  Name: "Magnetometer Sensor Stream", Actuator : 1, Text: ""),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE_STREAM, ActiveStatus: UInt32(NEBLINA_SENSOR_STATUS_ACCELEROMETER_GYROSCOPE.rawValue),
			  Name: "Accel & Gyro Stream", Actuator : 1, Text:""),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_PRESSURE_STREAM, ActiveStatus: UInt32(NEBLINA_SENSOR_STATUS_PRESSURE.rawValue),
              Name: "Pressure Sensor Stream", Actuator : 1, Text: ""),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_TEMPERATURE_STREAM, ActiveStatus: UInt32(NEBLINA_SENSOR_STATUS_TEMPERATURE.rawValue),
              Name: "Temperature Sensor Stream", Actuator : 1, Text: ""),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_HUMIDITY_STREAM, ActiveStatus: UInt32(NEBLINA_SENSOR_STATUS_HUMIDITY.rawValue),
              Name: "Humidity Sensor Stream", Actuator : 1, Text: ""),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_LOCK_HEADING_REFERENCE, ActiveStatus: 0,
			  Name: "Lock Heading Ref.", Actuator : 1, Text: ""),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_RECORD, ActiveStatus: UInt32(NEBLINA_RECORDER_STATUS_RECORD.rawValue),
			  Name: "Flash Record", Actuator : 2, Text: "Start"),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_RECORD, ActiveStatus: 0,
			  Name: "Flash Record", Actuator : 2, Text: "Stop"),
   NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_PLAYBACK, ActiveStatus: 0,
			  Name: "Flash Playback", Actuator : 4, Text: "Play"),
   //	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD, ActiveStatus: 0,
	//	           Name: "Flash Download", Actuator : 2, Text: "Start"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_LED, CmdId: NEBLINA_COMMAND_LED_STATE, ActiveStatus: 0,
	           Name: "Set LED0 level", Actuator : 3, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_LED, CmdId: NEBLINA_COMMAND_LED_STATE, ActiveStatus: 0,
	           Name: "Set LED1 level", Actuator : 3, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_LED, CmdId: NEBLINA_COMMAND_LED_STATE, ActiveStatus: 0,
	           Name: "Set LED2", Actuator : 1, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_EEPROM, CmdId: NEBLINA_COMMAND_EEPROM_READ, ActiveStatus: 0,
	           Name: "EEPROM Read", Actuator : 2, Text: "Read"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_POWER, CmdId: NEBLINA_COMMAND_POWER_CHARGE_CURRENT, ActiveStatus: 0,
	           Name: "Charge Current in mA", Actuator : 3, Text: ""),
	NebCmdItem(SubSysId: 0xf, CmdId: CmdMotionDataStream, ActiveStatus: 0,
	           Name: "Motion data stream", Actuator : 1, Text: ""),
	NebCmdItem(SubSysId: 0xf, CmdId: CmdHeading, ActiveStatus: 0,
	           Name: "Heading", Actuator : 1, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_ERASE_ALL, ActiveStatus: 0,
	           Name: "Flash Erase All", Actuator : 2, Text: "Erase"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_FIRMWARE_UPDATE, ActiveStatus: 0,
	           Name: "Firmware Update", Actuator : 2, Text: "DFU")
	// Baromter, pressure
)


class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, SCNSceneRendererDelegate, CBCentralManagerDelegate, NeblinaDelegate {
	
//, CBPeripheralDelegate {
	let scene = SCNScene(named: "art.scnassets/ship.scn")!
	let scene2 = SCNScene(named: "art.scnassets/ship.scn")!
	var ship = [SCNNode]() //= scene.rootNode.childNodeWithName("ship", recursively: true)!
	let max_count = Int16(15)
	var prevTimeStamp : [UInt32] = Array(repeating: 0, count: 8)//[UInt32(0), UInt32(0), UInt32(0), UInt32(0), UInt32(0), UInt32(0), UInt32(0), UInt32(0)]
	var cnt = Int16(15)
	var xf = Int16(0)
	var yf = Int16(0)
	var zf = Int16(0)
	var heading = Bool(false)
	//var flashEraseProgress = Bool(false)
	var PaketCnt : [UInt32] = Array(repeating: 0, count: 8)//[UInt32(0), UInt32(0), UInt32(0), UInt32(0), UInt32(0), UInt32(0), UInt32(0), UInt32(0)]
	var dropCnt : [UInt32] = Array(repeating: 0, count: 8)//[UInt32(0), UInt32(0), UInt32(0), UInt32(0), UInt32(0), UInt32(0), UInt32(0), UInt32(0)]
	var bleCentralManager : CBCentralManager!
	var foundDevices = [Neblina]()
	var connectedDevices = [Neblina]()
	//var nebdev = Neblina(devid: 0, peripheral: nil)
	var selectedDevices = [Neblina]()
	var curSessionId = UInt16(0)
	var curSessionOffset = UInt32(0)
	var sessionCount = UInt8(0)
	var startDownload = Bool(false)
	var filepath = String()
	var file : FileHandle?
	var downloadRecovering = Bool(false)
	var playback = Bool(false)
	var packetCnt = Int(0)
	var graphDisplay = Bool(false)
	
	@IBOutlet weak var cmdView: UITableView!
	@IBOutlet weak var devscanView : UITableView!
	@IBOutlet weak var selectedView : UITableView!
	@IBOutlet weak var versionLabel: UILabel!
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var flashLabel: UILabel!
	//@IBOutlet weak var dumpLabel: UILabel!
	@IBOutlet weak var logView: UITextView!
	@IBOutlet weak var sceneView : SCNView!
	@IBOutlet weak var sceneView2 : SCNView!

	@IBAction func doubleTap(_ sender: UITapGestureRecognizer) {
		let idx = selectedView.indexPathForSelectedRow! as IndexPath
		if idx.row > 0 {
			let dev = connectedDevices.remove(at: idx.row - 1)
			if connectedDevices.count > 0 {
				if selectedDevices.count > 2 {
					selectedDevices.remove(at: 0)
				}
				selectedDevices.append(connectedDevices[0])
			}
			else {
				selectedDevices.removeAll()
//				nebdev = Neblina(devid: 0, peripheral: nil)
			}
			bleCentralManager.cancelPeripheralConnection(dev.device)
			//foundDevices.append(dev)
			foundDevices.removeAll()
			devscanView.reloadData()
			selectedView.reloadData()
			
			bleCentralManager.scanForPeripherals(withServices: [NEB_SERVICE_UUID], options: nil)
		}
	}


	func getCmdIdx(_ subsysId : Int32, cmdId : Int32) -> Int {
		for (idx, item) in NebCmdList.enumerated() {
			if (item.SubSysId == subsysId && item.CmdId == cmdId) {
				return idx
			}
		}
		
		return -1
	}

	override func viewDidLoad() {
		super.viewDidLoad()


		devscanView.dataSource = self
		selectedView.dataSource = self
		cmdView.dataSource = self
		
		bleCentralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)

		// Do any additional setup after loading the view, typically from a nib.
		cnt = max_count
		//textview = self.view.viewWithTag(3) as! UITextView
		
		// create a new scene
		//scene = SCNScene(named: "art.scnassets/ship.scn")!
		
		//scene = SCNScene(named: "art.scnassets/Arc-170_ship/Obj_Shaded/Arc170.obj")
		
		// create and add a camera to the scene
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		scene.rootNode.addChildNode(cameraNode)
		let cameraNode2 = SCNNode()
		cameraNode2.camera = SCNCamera()
		scene2.rootNode.addChildNode(cameraNode2)
		
		// place the camera
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
		cameraNode2.position = SCNVector3(x: 0, y: 0, z: 15)
		//cameraNode.position = SCNVector3(x: 0, y: 15, z: 0)
		//cameraNode.rotation = SCNVector4(0, 0, 1, GLKMathDegreesToRadians(-180))
		//cameraNode.rotation = SCNVector3(x:
		// create and add a light to the scene
		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light!.type = SCNLight.LightType.omni
		lightNode.position = SCNVector3(x: 0, y: 10, z: 50)
		scene.rootNode.addChildNode(lightNode)
		let lightNode2 = SCNNode()
		lightNode2.light = SCNLight()
		lightNode2.light!.type = SCNLight.LightType.omni
		lightNode2.position = SCNVector3(x: 0, y: 10, z: 50)
		scene2.rootNode.addChildNode(lightNode2)
		
		// create and add an ambient light to the scene
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = SCNLight.LightType.ambient
		ambientLightNode.light!.color = UIColor.darkGray
		scene.rootNode.addChildNode(ambientLightNode)
		let ambientLightNode2 = SCNNode()
		ambientLightNode2.light = SCNLight()
		ambientLightNode2.light!.type = SCNLight.LightType.ambient
		ambientLightNode2.light!.color = UIColor.darkGray
		scene2.rootNode.addChildNode(ambientLightNode)
		
		
		// retrieve the ship node
		
		//		ship = scene.rootNode.childNodeWithName("MillenniumFalconTop", recursively: true)!
		//		ship = scene.rootNode.childNodeWithName("ARC_170_LEE_RAY_polySurface1394376_2_2", recursively: true)!
		var sh = scene.rootNode.childNode(withName: "ship", recursively: true)!
		ship.append(sh)
		//		ship = scene.rootNode.childNodeWithName("MDL Obj", recursively: true)!
		ship[0].eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(90), 0, GLKMathDegreesToRadians(180))
		//ship.rotation = SCNVector4(1, 0, 0, GLKMathDegreesToRadians(90))
		//print("1 - \(ship)")
		// animate the 3d object
		//ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
		//ship.runAction(SCNAction.rotateToX(CGFloat(eulerAngles.x), y: CGFloat(eulerAngles.y), z: CGFloat(eulerAngles.z), duration:1 ))// 10, y: 0.0, z: 0.0, duration: 1))
		let sh1 = scene2.rootNode.childNode(withName: "ship", recursively: true)!
		ship.append(sh1)
		//		ship = scene.rootNode.childNodeWithName("MDL Obj", recursively: true)!
		ship[1].eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(90), 0, GLKMathDegreesToRadians(180))
		
		// retrieve the SCNView
		let scnView = self.view.subviews[0] as! SCNView
		
		// set the scene to the view
		scnView.scene = scene
		
		// allows the user to manipulate the camera
		scnView.allowsCameraControl = true
		
		// show statistics such as fps and timing information
		scnView.showsStatistics = true
		
		// configure the view
		scnView.backgroundColor = UIColor.black
		
		// add a tap gesture recognizer
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(_:)))
		scnView.addGestureRecognizer(tapGesture)
		//scnView.preferredFramesPerSecond = 60
		
//		let scnView2 = self.view.subviews[1] as! SCNView
		
		// set the scene to the view
		sceneView2.scene = scene2
		
		// allows the user to manipulate the camera
		sceneView2.allowsCameraControl = true
		
		// show statistics such as fps and timing information
		sceneView2.showsStatistics = true
		
		// configure the view
		sceneView2.backgroundColor = UIColor.black
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		// retrieve the SCNView
		let scnView = self.view.subviews[0] as! SCNView
		
		// check what nodes are tapped
		let p = gestureRecognize.location(in: scnView)
		let hitResults = scnView.hitTest(p, options: nil)
		// check that we clicked on at least one object
		if hitResults.count > 0 {
			// retrieved the first clicked object
			let result: AnyObject! = hitResults[0]
			
			// get its material
			let material = result.node!.geometry!.firstMaterial!
			
			// highlight it
			SCNTransaction.begin()
			SCNTransaction.animationDuration = 0.5
			
			// on completion - unhighlight
			/*SCNTransaction.completionBlock {
			SCNTransaction.begin()
			SCNTransaction.animationDuration = 0.5
			
			material.emission.contents = UIColor.black
			
			SCNTransaction.commit()
			}
			*/
			material.emission.contents = UIColor.red
			
			SCNTransaction.commit()
		}
		
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
	{
		textField.resignFirstResponder()
		
		var value = UInt16(textField.text!)
		let idx = cmdView.indexPath(for: textField.superview!.superview as! UITableViewCell)
		let row = ((idx as NSIndexPath?)?.row)! as Int
		if (value == nil) {
			value = 0
		}
		switch (NebCmdList[row].SubSysId) {
		case NEBLINA_SUBSYSTEM_LED:
			let i = getCmdIdx(NEBLINA_SUBSYSTEM_LED,  cmdId: NEBLINA_COMMAND_LED_STATE)
			for item in connectedDevices {
				item.setLed(UInt8(row - i), Value: UInt8(value!))
			}
			break
		case NEBLINA_SUBSYSTEM_POWER:
			for item in connectedDevices {
				item.setBatteryChargeCurrent(value!)
			}
			break
		default:
			break
		}
		
		return true;
	}

	@IBAction func didSelectDevice(sender : UITableViewCell) {
	
	}
	
	@IBAction func buttonAction(_ sender:UIButton)
	{
		let idx = cmdView.indexPath(for: sender.superview!.superview as! UITableViewCell)
		let row = ((idx as NSIndexPath?)?.row)! as Int
		
		if connectedDevices.count <= 0 {
			return
		}
		
		if (row < NebCmdList.count) {
			switch (NebCmdList[row].SubSysId)
			{
			case NEBLINA_SUBSYSTEM_GENERAL:
				switch (NebCmdList[row].CmdId)
				{
				case NEBLINA_COMMAND_GENERAL_FIRMWARE_UPDATE:
					for item in connectedDevices {
						item.firmwareUpdate()
					}
					//nebdev.firmwareUpdate()
					print("DFU Command")
					break
				case NEBLINA_COMMAND_GENERAL_RESET_TIMESTAMP:
					for item in connectedDevices {
						item.resetTimeStamp(Delayed: true)
					}
//					nebdev.resetTimeStamp(Delayed: true)
					print("Reset timestamp")
				default:
					break
				}
				break
			case NEBLINA_SUBSYSTEM_EEPROM:
				switch (NebCmdList[row].CmdId)
				{
				case NEBLINA_COMMAND_EEPROM_READ:
					selectedDevices[0].eepromRead(0)
					break
				case NEBLINA_COMMAND_EEPROM_WRITE:
					//UInt8_t eepdata[8]
					//nebdev.SendCmdEepromWrite(0, eepdata)
					break
				default:
					break
				}
				break
			case NEBLINA_SUBSYSTEM_FUSION:
				switch (NebCmdList[row].CmdId) {
				case NEBLINA_COMMAND_FUSION_CALIBRATE_FORWARD_POSITION:
					for item in connectedDevices {
						item.calibrateForwardPosition()
					}
					break
				case NEBLINA_COMMAND_FUSION_CALIBRATE_DOWN_POSITION:
					for item in connectedDevices {
						item.calibrateDownPosition()
					}
					break
				default:
					break
				}
				break
			case NEBLINA_SUBSYSTEM_RECORDER:
				switch (NebCmdList[row].CmdId) {
				case NEBLINA_COMMAND_RECORDER_ERASE_ALL:
					//if flashEraseProgress == false {
					//	flashEraseProgress = true;
						for item in connectedDevices {
							item.eraseStorage(false)
							logView.text = logView.text + String(format: "%@ - Erase command sent\n", item.device.name!)
						}
						
					//}
				case NEBLINA_COMMAND_RECORDER_RECORD:
					
					if NebCmdList[row].ActiveStatus == 0 {
						for item in connectedDevices {
							item.sessionRecord(false, info: "")
						}
						//nebdev.sessionRecord(false)
					}
					else {
						for item in connectedDevices {
							item.sessionRecord(true, info: "")
						}
						//nebdev.sessionRecord(true)
					}
					break
				case NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD:
/*					let cell = cmdView.cellForRow( at: IndexPath(row: row, section: 0))
					
					if (cell != nil) {
						//let control = cell!.viewWithTag(4) as! UITextField
						//let but = cell!.viewWithTag(2) as! UIButton
						
						//but.isEnabled = false
						curSessionId = 0//UInt16(control.text!)!
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
					}*/
					break
				case NEBLINA_COMMAND_RECORDER_PLAYBACK:
					let cell = cmdView.cellForRow( at: IndexPath(row: row, section: 0))
					if cell != nil {
						let tf = cell?.viewWithTag(4) as! UITextField
						let bt = cell?.viewWithTag(2) as! UIButton
						if playback == true {
							bt.setTitle("Play", for: .normal)
							playback = false
						}
						else {
							bt.setTitle("Stop", for: .normal)
							var n = UInt16(0)
							if UInt16(tf.text!)! != nil {
								n = UInt16(tf.text!)!
								
							}
							for item in connectedDevices {
								item.sessionPlayback(true, sessionId : n)
							}
							//selectedDevices[1].sessionPlayback(true, sessionId : n)
							//nebdev.sessionPlayback(true, sessionId : n)
							packetCnt = 0
							playback = true
						}
					}
					break
				default:
					break
				}
			default:
				break
			}
		}
	}

	@IBAction func switchAction(_ sender:UISegmentedControl)
	{
		//let tableView = sender.superview?.superview?.superview?.superview as! UITableView
		let idx = cmdView.indexPath(for: sender.superview!.superview as! UITableViewCell)
		let row = ((idx as NSIndexPath?)?.row)! as Int
		
		if (selectedDevices.count <= 0) {
			return
		}
		
		if (row < NebCmdList.count) {
			switch (NebCmdList[row].SubSysId)
			{
			case NEBLINA_SUBSYSTEM_GENERAL:
				switch (NebCmdList[row].CmdId)
				{
				case NEBLINA_COMMAND_GENERAL_INTERFACE_STATUS:
					//nebdev!.setInterface(sender.selectedSegmentIndex)
					break
				case NEBLINA_COMMAND_GENERAL_INTERFACE_STATE:
					for item in connectedDevices {
						item.setDataPort(row, Ctrl:UInt8(sender.selectedSegmentIndex))
					}
					break;
				default:
					break
				}
				break
				
			case NEBLINA_SUBSYSTEM_FUSION:
				switch (NebCmdList[row].CmdId)
				{
				case NEBLINA_COMMAND_FUSION_MOTION_STATE_STREAM:
					for item in connectedDevices {
						item.streamMotionState(sender.selectedSegmentIndex == 1)
					}
					break
				case NEBLINA_COMMAND_FUSION_FUSION_TYPE:
					for item in connectedDevices {
						item.setFusionType(UInt8(sender.selectedSegmentIndex))
					}
					break
					//case IMU_Data:
					//	nebdev!.streamIMU(sender.selectedSegmentIndex == 1)
				//		break
				case NEBLINA_COMMAND_FUSION_QUATERNION_STREAM:
					for item in connectedDevices {
						item.streamQuaternion(sender.selectedSegmentIndex == 1)
					}
					/*
					nebdev.streamEulerAngle(false)
					heading = false
					prevTimeStamp = 0
					nebdev.streamQuaternion(sender.selectedSegmentIndex == 1)*/
					let i = getCmdIdx(0xf,  cmdId: 1)
					let cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
					if (cell != nil) {
						let sw = cell!.viewWithTag(1) as! UISegmentedControl
						sw.selectedSegmentIndex = 0
					}
					break
				case NEBLINA_COMMAND_FUSION_EULER_ANGLE_STREAM:
					for item in connectedDevices {
						item.streamQuaternion(false)
						item.streamEulerAngle(sender.selectedSegmentIndex == 1)
					}
					break
				case NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STREAM:
					for item in connectedDevices {
						item.streamExternalForce(sender.selectedSegmentIndex == 1)
					}
					break
				case NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM:
					for item in connectedDevices {
						item.streamPedometer(sender.selectedSegmentIndex == 1)
					}
					break;
				case NEBLINA_COMMAND_FUSION_TRAJECTORY_RECORD:
					for item in connectedDevices {
						item.recordTrajectory(sender.selectedSegmentIndex == 1)
					}
					break;
				case NEBLINA_COMMAND_FUSION_TRAJECTORY_INFO_STREAM:
					for item in connectedDevices {
						item.streamTrajectoryInfo(sender.selectedSegmentIndex == 1)
					}
					break;
/*				case NEBLINA_COMMAND_FUSION_MAG_STATE:
					nebdev.streamMAG(sender.selectedSegmentIndex == 1)
					break;*/
				case NEBLINA_COMMAND_FUSION_LOCK_HEADING_REFERENCE:
					for item in connectedDevices {
						item.lockHeadingReference()
					}
					let cell = cmdView.cellForRow( at: IndexPath(row: row, section: 0))
					if (cell != nil) {
						let sw = cell!.viewWithTag(1) as! UISegmentedControl
						sw.selectedSegmentIndex = 0
					}
					break
				default:
					break
				}
			case NEBLINA_SUBSYSTEM_LED:
				let i = getCmdIdx(NEBLINA_SUBSYSTEM_LED,  cmdId: NEBLINA_COMMAND_LED_STATE)
				for item in connectedDevices {
					if sender.selectedSegmentIndex == 1 {
						item.setLed(UInt8(row - i), Value: 255)
					}
					else {
						item.setLed(UInt8(row - i), Value: 0)
					}
				}
				break
			case NEBLINA_SUBSYSTEM_RECORDER:
				switch (NebCmdList[row].CmdId)
				{
					
				case NEBLINA_COMMAND_RECORDER_ERASE_ALL:
					if (sender.selectedSegmentIndex == 1) {
//						flashEraseProgress = true;
					}
					for item in connectedDevices {
						item.eraseStorage(sender.selectedSegmentIndex == 1)
					}
					break
				case NEBLINA_COMMAND_RECORDER_RECORD:
					for item in connectedDevices {
						item.sessionRecord(sender.selectedSegmentIndex == 1, info: "")
					}
					break
				case NEBLINA_COMMAND_RECORDER_PLAYBACK:
					for item in connectedDevices {
						item.sessionPlayback(sender.selectedSegmentIndex == 1, sessionId : 0xffff)
					}
					if (sender.selectedSegmentIndex == 1) {
						packetCnt = 0
					}
					break
				case NEBLINA_COMMAND_RECORDER_SESSION_READ:
					//							curDownloadSession = 0xFFFF
					//							curDownloadOffset = 0
					//							nebdev!.sessionRead(curDownloadSession, Len: 32, Offset: curDownloadOffset)
					break
				default:
					break
				}
				break
			case NEBLINA_SUBSYSTEM_EEPROM:
				switch (NebCmdList[row].CmdId)
				{
				case NEBLINA_COMMAND_EEPROM_READ:
					for item in connectedDevices {
						item.eepromRead(0)
					}
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
					for item in connectedDevices {
						item.sensorStreamAccelData(sender.selectedSegmentIndex == 1)
					}
					break
				case NEBLINA_COMMAND_SENSOR_GYROSCOPE_STREAM:
					for item in connectedDevices {
						item.sensorStreamGyroData(sender.selectedSegmentIndex == 1)
					}
					break
				case NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM:
					for item in connectedDevices {
						item.sensorStreamMagData(sender.selectedSegmentIndex == 1)
					}
					break
				case NEBLINA_COMMAND_SENSOR_PRESSURE_STREAM:
					for item in connectedDevices {
						item.sensorStreamPressureData(sender.selectedSegmentIndex == 1)
					}
					break
				case NEBLINA_COMMAND_SENSOR_TEMPERATURE_STREAM:
					for item in connectedDevices {
						item.sensorStreamTemperatureData(sender.selectedSegmentIndex == 1)
					}
					break
				case NEBLINA_COMMAND_SENSOR_HUMIDITY_STREAM:
					for item in connectedDevices {
						item.sensorStreamHumidityData(sender.selectedSegmentIndex == 1)
					}
					break
				case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE_STREAM:
					for item in connectedDevices {
						item.sensorStreamAccelGyroData(sender.selectedSegmentIndex == 1)
					}
					//nebdev.streamAccelGyroSensorData(sender.selectedSegmentIndex == 1)
					break
				case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER_STREAM:
					for item in connectedDevices {
						item.sensorStreamAccelMagData(sender.selectedSegmentIndex == 1)
					}
//					nebdev.streamAccelMagSensorData(sender.selectedSegmentIndex == 1)
					break
				default:
					break
				}
				break
				
			case 0xf:
				switch (NebCmdList[row].CmdId) {
				case CmdHeading:
					for item in connectedDevices {
						item.streamQuaternion(false)
						item.streamEulerAngle(sender.selectedSegmentIndex == 1)
					}
//					Heading = sender.selectedSegmentIndex == 1
					var i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STREAM)
					var cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
					if (cell != nil) {
						let control = cell!.viewWithTag(1) as! UISegmentedControl
						control.selectedSegmentIndex = 0
					}
					i = getCmdIdx(0xF,  cmdId: CmdMotionDataStream)
					cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
					if (cell != nil) {
						let control = cell!.viewWithTag(1) as! UISegmentedControl
						control.selectedSegmentIndex = 0
					}
					break
				case CmdMotionDataStream:
					if sender.selectedSegmentIndex == 0 {
						for item in connectedDevices {
							item.disableStreaming()
						}
						break
					}
					
					for item in connectedDevices {
						item.streamQuaternion(sender.selectedSegmentIndex == 1)
					}
					var i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STREAM)
					var cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
					if (cell != nil) {
						let control = cell!.viewWithTag(1) as! UISegmentedControl
						control.selectedSegmentIndex = sender.selectedSegmentIndex
					}
					for item in connectedDevices {
						item.sensorStreamMagData(sender.selectedSegmentIndex == 1)
					}
					i = getCmdIdx(NEBLINA_SUBSYSTEM_SENSOR,  cmdId: NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM)
					cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
					if (cell != nil) {
						let control = cell!.viewWithTag(1) as! UISegmentedControl
						control.selectedSegmentIndex = sender.selectedSegmentIndex
					}
					for item in connectedDevices {
						item.streamExternalForce(sender.selectedSegmentIndex == 1)
					}
					i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STREAM)
					cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
					if (cell != nil) {
						let control = cell!.viewWithTag(1) as! UISegmentedControl
						control.selectedSegmentIndex = sender.selectedSegmentIndex
					}
					for item in connectedDevices {
						item.streamPedometer(sender.selectedSegmentIndex == 1)
					}
					i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM)
					cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
					if (cell != nil) {
						let control = cell!.viewWithTag(1) as! UISegmentedControl
						control.selectedSegmentIndex = sender.selectedSegmentIndex
					}
					for item in connectedDevices {
						item.streamRotationInfo(sender.selectedSegmentIndex == 1, Type: 2)
					}
					i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_ROTATION_INFO_STREAM)
					cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
					if (cell != nil) {
						let control = cell!.viewWithTag(1) as! UISegmentedControl
						control.selectedSegmentIndex = sender.selectedSegmentIndex
					}
					i = getCmdIdx(0xF,  cmdId: CmdHeading)
					cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
					if (cell != nil) {
						let control = cell!.viewWithTag(1) as! UISegmentedControl
						control.selectedSegmentIndex = 0
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
		/*		else {
		switch (row - NebCmdList.count) {
		case 0:
		nebdev.streamQuaternion(false)
		nebdev.streamEulerAngle(true)
		heading = sender.selectedSegmentIndex == 1
		let i = getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: Quaternion)
		let cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
		if (cell != nil) {
		let sw = cell!.viewWithTag(1) as! UISegmentedControl
		sw.selectedSegmentIndex = 0
		}
		break
		default:
		break
		}
		}*/
	}
	
	func updateUI(status : NeblinaSystemStatus_t) {
		for idx in 0...NebCmdList.count - 1 {
			switch (NebCmdList[idx].SubSysId) {
			case NEBLINA_SUBSYSTEM_GENERAL:
				switch (NebCmdList[idx].CmdId) {
				case NEBLINA_COMMAND_GENERAL_INTERFACE_STATE:
					//let cell = cmdView.view(atColumn: 0, row: idx, makeIfNecessary: false)! as NSView
					let cell = cmdView.cellForRow( at: IndexPath(row: idx, section: 0))
					if cell != nil {
						let control = cell?.viewWithTag(1) as! UISegmentedControl
						
						if NebCmdList[idx].ActiveStatus & UInt32(status.interface) == 0 {
							control.selectedSegmentIndex = 0
						}
						else {
							control.selectedSegmentIndex = 1
						}
					}
				default:
					break
				}
			case NEBLINA_SUBSYSTEM_FUSION:
				//let cell = cmdView.view(atColumn: 0, row: idx, makeIfNecessary: false)! as NSView
				let cell = cmdView.cellForRow( at: IndexPath(row: idx, section: 0))
				if cell != nil {
					let control = cell?.viewWithTag(1) as! UISegmentedControl
					if NebCmdList[idx].ActiveStatus & status.fusion == 0 {
						control.selectedSegmentIndex = 0
					}
					else {
						control.selectedSegmentIndex = 1
					}
				}
			case NEBLINA_SUBSYSTEM_SENSOR:
				let cell = cmdView.cellForRow( at: IndexPath(row: idx, section: 0))
				if cell != nil {
					//let cell = cmdView.view(atColumn: 0, row: idx, makeIfNecessary: false)! as NSView
					let control = cell?.viewWithTag(1) as! UISegmentedControl
					if NebCmdList[idx].ActiveStatus & UInt32(status.sensor) == 0 {
						control.selectedSegmentIndex = 0
					}
					else {
						control.selectedSegmentIndex = 1
					}
				}
				
			default:
				break
			}
		}
	}

	// MARK: UITableViewDelegate
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView == devscanView {
			return foundDevices.count + 1
		}
		else if tableView == selectedView {
			return connectedDevices.count + 1
		}
		else if tableView == cmdView {
			return NebCmdList.count
		}
		
		return 1
	}
	
	
	// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
	// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		if tableView == devscanView {
			if indexPath.row == 0 {
				cell.textLabel!.text = String("Devices Found")
				cell.selectionStyle = UITableViewCell.SelectionStyle.none
			}
			else {
				let object = foundDevices[(indexPath as NSIndexPath).row - 1]
//				cell.textLabel!.text = object.device.name
//				print("\(cell.textLabel!.text)")
				cell.textLabel!.text = object.device.name! + String(format: "_%lX", object.id)
			}
		}
		else if tableView == selectedView {
			if indexPath.row == 0 {
				//cell.textLabel!.text = String("Connected")
				cell.selectionStyle = UITableViewCell.SelectionStyle.none
				let label = cell.contentView.subviews[1] as! UILabel
				label.text = String("Connected")
				
			}
			else {
				let object = connectedDevices[(indexPath as NSIndexPath).row - 1]
				//cell.textLabel!.text = object.device.name
				
				let label = cell.contentView.subviews[1] as! UILabel
				label.text = object.device.name! + String(format: "_%lX", object.id)
				let label1 = cell.contentView.subviews[0] as! UILabel
				if object == selectedDevices[0] {
					label1.text = "T"
				}
				else if object == selectedDevices[1] {
					label1.text = "B"
				}
				else {
					label1.text?.removeAll()
				}
			}
		}
		else if tableView == cmdView {
			if indexPath.row < NebCmdList.count {
				let labelView = cell.viewWithTag(255) as! UILabel
	
				labelView.text = NebCmdList[indexPath.row].Name// - FusionCmdList.count].Name
				switch (NebCmdList[indexPath.row].Actuator)
				{
				case 1:
					let control = cell.viewWithTag(NebCmdList[indexPath.row].Actuator) as! UISegmentedControl
					control.isHidden = false
					let b = cell.viewWithTag(2) as! UIButton
					b.isHidden = true
					let t = cell.viewWithTag(3) as! UITextField
					t.isHidden = true
					break
				case 2:
					let control = cell.viewWithTag(NebCmdList[indexPath.row].Actuator) as! UIButton
					control.isHidden = false
					if !NebCmdList[indexPath.row].Text.isEmpty
					{
						control.setTitle(NebCmdList[indexPath.row].Text, for: UIControl.State())
					}
					let s = cell.viewWithTag(1) as! UISegmentedControl
					s.isHidden = true
					let t = cell.viewWithTag(3) as! UITextField
					t.isHidden = true
					break
				case 3:
					let control = cell.viewWithTag(NebCmdList[indexPath.row].Actuator) as! UITextField
					control.isHidden = false
					if !NebCmdList[indexPath.row].Text.isEmpty
					{
						control.text = NebCmdList[indexPath.row].Text
					}
					let s = cell.viewWithTag(1) as! UISegmentedControl
					s.isHidden = true
					let b = cell.viewWithTag(2) as! UIButton
					b.isHidden = true
					break
				case 4:
					let tfcontrol = cell.viewWithTag(NebCmdList[indexPath.row].Actuator) as! UITextField
					tfcontrol.isHidden = false
					/*					if !NebCmdList[(indexPath! as NSIndexPath).row].Text.isEmpty
					{
					tfcontrol.text = NebCmdList[(indexPath! as NSIndexPath).row].Text
					}*/
					let bucontrol = cell.viewWithTag(2) as! UIButton
					bucontrol.isHidden = false
					if !NebCmdList[indexPath.row].Text.isEmpty
					{
						bucontrol.setTitle(NebCmdList[indexPath.row].Text, for: UIControl.State())
					}
					let s = cell.viewWithTag(1) as! UISegmentedControl
					s.isHidden = true
					let t = cell.viewWithTag(3) as! UITextField
					t.isHidden = true
					break
				default:
					//switchCtrl.enabled = false
					//					switchCtrl.hidden = true
					//					buttonCtrl.hidden = true
					break
				}
			}
		}
		
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView == devscanView &&  indexPath.row > 0 {
			let dev = foundDevices.remove(at: indexPath.row - 1)
			dev.device.delegate = dev
			bleCentralManager.connect(dev.device, options: nil)
			connectedDevices.append(dev)
			//nebdev.delegate = nil
			if selectedDevices.count > 1 {
				selectedDevices.remove(at: 0)
			}
			dev.delegate = self
			selectedDevices.append(dev)
			for (idx, item)in selectedDevices.enumerated() {
				if item == dev {
					prevTimeStamp[idx] = 0
					dropCnt[idx] = 0;
				}
			}
			//nebdev = dev
			//nebdev.delegate = self
			devscanView.reloadData()
			selectedView.reloadData()
		}
		else if tableView == selectedView && indexPath.row > 0 {
			// Switch device to view
			//nebdev.delegate = nil
			let dev = connectedDevices[indexPath.row - 1]
			for item in selectedDevices {
				if item == dev {
					return
				}
			}
			
			if selectedDevices.count > 1 {
				selectedDevices.remove(at: 0)
			}
			dev.delegate = self
			selectedDevices.append(dev)
			
			// get update status
			dev.getSystemStatus()
			dev.getFirmwareVersion()
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
		
		let mdata = advertisementData[CBAdvertisementDataManufacturerDataKey] as! NSData
		
		if mdata.length < 8 {
			return
		}
		
		var id : UInt64 = 0
		(advertisementData[CBAdvertisementDataManufacturerDataKey] as! NSData).getBytes(&id, range: NSMakeRange(2, 8))
		if (id == 0) {
			return
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
		
		for dev in foundDevices
		{
			if (dev.id == id)
			{
				return;
			}
		}
		
		foundDevices.insert(device, at: 0)
		
		devscanView.reloadData();
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		
		central.stopScan()
		peripheral.discoverServices(nil)
		print("Connected to peripheral")
		
		
	}
	
	func centralManager(_ central: CBCentralManager,
	                    didDisconnectPeripheral peripheral: CBPeripheral,
	                    error: Error?) {
		for i in 0..<connectedDevices.count {
			if connectedDevices[i].device == peripheral {
				connectedDevices.remove(at: i)
				selectedView.reloadData()
				break
			}
		}
		print("disconnected from peripheral \(error)")
	}
	
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
	}
	
	func scanPeripheral(_ sender: CBCentralManager)
	{
		print("Scan for peripherals")
		bleCentralManager.scanForPeripherals(withServices: [NEB_SERVICE_UUID], options: nil)
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
	
	//
	// MARK: Neblina delegate
	//
	func didConnectNeblina(sender : Neblina) {
		
//		prevTimeStamp[0] = 0
//		prevTimeStamp[1] = 0
		sender.getSystemStatus()
		sender.getFirmwareVersion()
		
	}

	func didReceiveResponsePacket(sender: Neblina, subsystem: Int32, cmdRspId: Int32, data: UnsafePointer<UInt8>, dataLen: Int) {
		print("didReceiveResponsePacket : \(subsystem) \(cmdRspId)")
		switch subsystem {
		case NEBLINA_SUBSYSTEM_GENERAL:
			switch (cmdRspId) {
			case NEBLINA_COMMAND_GENERAL_SYSTEM_STATUS:
				let d = UnsafeMutableRawPointer(mutating: data).load(as: NeblinaSystemStatus_t.self)// UnsafeBufferPointer<NeblinaSystemStatus_t>(data))
				print(" \(d)")
				updateUI(status: d)
				break
			case NEBLINA_COMMAND_GENERAL_FIRMWARE_VERSION:
				let vers = UnsafeMutableRawPointer(mutating: data).load(as: NeblinaFirmwareVersion_t.self)
				let b = (UInt32(vers.firmware_build.0) & 0xFF) | ((UInt32(vers.firmware_build.1) & 0xFF) << 8) | ((UInt32(vers.firmware_build.2) & 0xFF) << 16)
				print("\(vers) ")
				versionLabel.text = String(format: "API:%d, Firm. Ver.:%d.%d.%d-%d", vers.api,
										   vers.firmware_major, vers.firmware_minor, vers.firmware_patch, b
				)
				logView.text = logView.text + String(format: "%@ - API:%d, Firm. Ver.:%d.%d.%d-%d", sender.device.name!, vers.api,
													 vers.firmware_major, vers.firmware_minor, vers.firmware_patch, b)
				break
			default:
				break
			}
			break
			
		case NEBLINA_SUBSYSTEM_FUSION:
			switch cmdRspId {
			case NEBLINA_COMMAND_FUSION_QUATERNION_STREAM:
				break
			default:
				break
			}
			break

		case NEBLINA_SUBSYSTEM_RECORDER:
			switch (cmdRspId) {
			case NEBLINA_COMMAND_RECORDER_ERASE_ALL:
				flashLabel.text = String(format: "%@ - Flash erased\n", sender.device.name!)
				logView.text = logView.text + String(format: "%@ - Flash erased\n", sender.device.name!)
//				flashLabel.text = "Flash erased"
				//flashEraseProgress = false
				break
			case NEBLINA_COMMAND_RECORDER_RECORD:
				let session = Int16(data[1]) | (Int16(data[2]) << 8)
				if (data[0] != 0) {
					//	if (nebdev == sender) {
					flashLabel.text = String(format: "%@ - Recording session %d", sender.device.name!, session)
					//	}
					logView.text = logView.text + String(format: "%@ - Recording session %d\n", sender.device.name!, session)
				}
				else {
					//	if (nebdev == sender) {
					flashLabel.text = String(format: "Recorded session %d", session)
					//	}
					logView.text = logView.text + String(format: "%@ - Recorded session %d\n", sender.device.name!, session)
				}

				break
			case NEBLINA_COMMAND_RECORDER_PLAYBACK:
				let session = Int16(data[1]) | (Int16(data[2]) << 8)
				if (data[0] != 0) {
					if selectedDevices[0] == sender {
						flashLabel.text = String(format: "Playing session %d", session)
					}
				}
				else {
					if selectedDevices[0] == sender {
						flashLabel.text = String(format: "End session %d, %u", session, sender.getPacketCount())
						
						playback = false
						let i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_PLAYBACK)
						let cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
						if (cell != nil) {
							let sw = cell!.viewWithTag(2) as! UIButton
							sw.setTitle("Play", for: .normal)
						}
					}
				}
				
				break
			default:
				break
			}
			break
		case NEBLINA_SUBSYSTEM_SENSOR:
			//nebdev?.getFirmwareVersion()
			break
		default:
			break
		}

	}
	
	func didReceiveRSSI(sender : Neblina, rssi : NSNumber) {
		
	}
	
	func didReceiveBatteryLevel(sender: Neblina, level: UInt8) {
		
	}

	func didReceiveGeneralData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafeRawPointer, dataLen : Int, errFlag : Bool) {
		switch (cmdRspId) {
		case NEBLINA_COMMAND_GENERAL_SYSTEM_STATUS:
			var myStruct = NeblinaSystemStatus_t()
			let status = withUnsafeMutablePointer(to: &myStruct) {_ in UnsafeMutableRawPointer(mutating: data)}
			//print("Status \(status)")
			let d = data.load(as: NeblinaSystemStatus_t.self)// UnsafeBufferPointer<NeblinaSystemStatus_t>(data)
			//print(" \(d)")
			updateUI(status: d)
			break

/*		case NEBLINA_COMMAND_GENERAL_FIRMWARE_VERSION:
			let vers = data.load(as: NeblinaFirmwareVersion_t.self)
			let b = (UInt32(vers.firmware_build.0) & 0xFF) | ((UInt32(vers.firmware_build.1) & 0xFF) << 8) | ((UInt32(vers.firmware_build.2) & 0xFF) << 16)
			if selectedDevices[0] == sender {
				//let vers = UnsafeMutableRawPointer(mutating: data).load(as: NeblinaFirmwareVersion_t.self)
				print("\(vers) ")
				versionLabel.text = String(format: "API:%d, Firm. Ver.:%d.%d.%d-%d", vers.api,
										   vers.firmware_major, vers.firmware_minor, vers.firmware_patch, b
				)
				//versionLabel.text = String(format: "API:%d, FEN:%d.%d.%d, BLE:%d.%d.%d", d.apiVersion,
				//                           d.coreVersion.major, d.coreVersion.minor, d.coreVersion.build,
				//                           d.bleVersion.major, d.bleVersion.minor, d.bleVersion.build)
			}
			logView.text = logView.text + String(format: "%@ - API:%d, Firm. Ver.:%d.%d.%d-%d", sender.device.name!, vers.api,
			                                vers.firmware_major, vers.firmware_minor, vers.firmware_patch, b)
			break*/
			/*case NEBLINA_COMMAND_GENERAL_INTERFACE_STATUS:
			let i = getCmdIdx(NEBLINA_SUBSYSTEM_GENERAL,  cmdId: NEBLINA_COMMAND_GENERAL_INTERFACE_STATE)
			var cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
			if (cell != nil) {
			let sw = cell!.viewWithTag(1) as! UISegmentedControl
			sw.selectedSegmentIndex = Int(data[0])
			}
			cell = cmdView.cellForRow( at: IndexPath(row: i + 1, section: 0))
			if (cell != nil) {
			let sw = cell!.viewWithTag(1) as! UISegmentedControl
			sw.selectedSegmentIndex = Int(data[1])
			}
			break*/
		default:
			break
		}
	}

	func didReceiveFusionData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : NeblinaFusionPacket_t, errFlag : Bool) {
		
		//let errflag = Bool(type.rawValue & 0x80 == 0x80)
		
		//let id = FusionId(rawValue: type.rawValue & 0x7F)! as FusionId
		if selectedDevices[0] == sender {
			//logView.text = logView.text + String(format: "Total packet %u @ %0.2f pps\n", nebdev.getPacketCount(), nebdev.getDataRate())
		}
		switch (cmdRspId) {
			
		case NEBLINA_COMMAND_FUSION_MOTION_STATE_STREAM:
			break
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
			
			if selectedDevices[0] == sender {
				if (heading) {
					ship[0].eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(90), 0, GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(xrot))
				}
				else {
					ship[0].eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(yrot), GLKMathDegreesToRadians(xrot), GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(zrot))
				}
				
				label.text = String("Euler - Yaw:\(xrot), Pitch:\(yrot), Roll:\(zrot)")
			}
			if selectedDevices[1] == sender {
				if (heading) {
					ship[1].eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(90), 0, GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(xrot))
				}
				else {
					ship[1].eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(yrot), GLKMathDegreesToRadians(xrot), GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(zrot))
				}
			}
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
			for (idx, item) in selectedDevices.enumerated() {
				if item == sender {
					ship[idx].orientation = SCNQuaternion(yq, xq, zq, wq)
					label.text = String("Quat - x:\(xq), y:\(yq), z:\(zq), w:\(wq)")
				}
			}
			for (idx, item) in connectedDevices.enumerated() {
					if (prevTimeStamp[idx] == 0 || data.timestamp <= prevTimeStamp[idx])
					{
						prevTimeStamp[idx] = data.timestamp;
					}
					else
					{
						let tdiff = data.timestamp - prevTimeStamp[idx];
						if (tdiff > 49000)
						{
							dropCnt[idx] += 1
							//logView.text = logView.text + String("\(dropCnt) Drop : \(tdiff)\n")
						}
						prevTimeStamp[idx] = data.timestamp
					}
			}
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
				
				ship[0].position = pos
				
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
			}
			
			if selectedDevices[0] == sender {
				label.text = String("Extrn Force - x:\(xq), y:\(yq), z:\(zq)")
			}
			//print("Extrn Force - x:\(xq), y:\(yq), z:\(zq)")
			break
/*		case NEBLINA_COMMAND_FUSION_MAG_ST:
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
			
			if nebdev == sender {
				label.text = String("Mag - x:\(xq), y:\(yq), z:\(zq)")
			}
			//ship.rotation = SCNVector4(Float(xq), Float(yq), 0, GLKMathDegreesToRadians(90))
			break
			*/
		default:
			break
		}
	}
	
	func didReceivePmgntData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		let value = UInt16(data[0]) | (UInt16(data[1]) << 8)
		if (cmdRspId == NEBLINA_COMMAND_POWER_CHARGE_CURRENT && selectedDevices[0] == sender)
		{
			let i = getCmdIdx(NEBLINA_SUBSYSTEM_POWER,  cmdId: NEBLINA_COMMAND_POWER_CHARGE_CURRENT)
			let cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
			if (cell != nil) {
				let control = cell!.viewWithTag(3) as! UITextField
				control.text = String(value)
			}
		}
	}
	func didReceiveLedData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		
	}
	func didReceiveDebugData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		//print("Debug \(type) data \(data)")
		switch (cmdRspId) {
		case NEBLINA_COMMAND_DEBUG_DUMP_DATA:
			if selectedDevices[0] == sender {
				logView.text = logView.text + String(format: "%02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
				                        data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9],
				                        data[10], data[11], data[12], data[13], data[14], data[15])
			}
			break
		default:
			break
		}
	}
	func didReceiveRecorderData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		switch (cmdRspId) {
		case NEBLINA_COMMAND_RECORDER_ERASE_ALL:
		//	if nebdev == sender {
		//		flashLabel.text = "Flash erased"
		//	}
			flashLabel.text = String(format: "%@ - Flash erased\n", sender.device.name!)
			logView.text = logView.text + String(format: "%@ - Flash erased\n", sender.device.name!)
			break
		case NEBLINA_COMMAND_RECORDER_RECORD:
			let session = Int16(data[1]) | (Int16(data[2]) << 8)
			if (data[0] != 0) {
			//	if (nebdev == sender) {
					flashLabel.text = String(format: "%@ - Recording session %d", sender.device.name!, session)
			//	}
				logView.text = logView.text + String(format: "%@ - Recording session %d\n", sender.device.name!, session)
			}
			else {
			//	if (nebdev == sender) {
					flashLabel.text = String(format: "Recorded session %d", session)
			//	}
				logView.text = logView.text + String(format: "%@ - Recorded session %d\n", sender.device.name!, session)
			}
			break
		case NEBLINA_COMMAND_RECORDER_PLAYBACK:
			let session = Int16(data[1]) | (Int16(data[2]) << 8)
			if (data[0] != 0) {
				if selectedDevices[0] == sender {
					flashLabel.text = String(format: "Playing session %d", session)
				}
			}
			else {
				if selectedDevices[0] == sender {
					flashLabel.text = String(format: "End session %d, %u", session, sender.getPacketCount())
					
					playback = false
					let i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_PLAYBACK)
					let cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
					if (cell != nil) {
						let sw = cell!.viewWithTag(2) as! UIButton
						sw.setTitle("Play", for: .normal)
					}
				}
			}
			break
/*		case NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD:
			if (errFlag == false && dataLen > 0) {
				
				if dataLen < 4 {
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
					flashLabel.text = String(format: "Downloading session %d : %u", curSessionId, curSessionOffset)
				}
				//print("\(curSessionOffset), \(data)")
			}
			else {
				print("End session \(filepath)")
				print(" Download End session errflag")
				flashLabel.text = String(format: "Downloaded session %d : %u", curSessionId, curSessionOffset)
				
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
				//					let cell = cmdView.view(atColumn: 0, row: i, makeIfNecessary: false)! as NSView // cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
				//					let sw = cell.viewWithTag(2) as! NSButton
				
				//					sw.isEnabled = true
			}
			break*/
		default:
			break
		}
	}
	func didReceiveEepromData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		switch (cmdRspId) {
		case NEBLINA_COMMAND_EEPROM_READ:
			let pageno = UInt16(data[0]) | (UInt16(data[1]) << 8)
			logView.text = logView.text + String(format: "%@ EEP page [%d] : %02x %02x %02x %02x %02x %02x %02x %02x\n", sender.device.name!,
			                        pageno, data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9])
			break
		case NEBLINA_COMMAND_EEPROM_WRITE:
			break;
		default:
			break
		}
	}
	func didReceiveSensorData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool) {
		switch (cmdRspId) {
		case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_STREAM:
			let x = (Int16(data[4]) & 0xff) | (Int16(data[5]) << 8)
			let xq = x
			let y = (Int16(data[6]) & 0xff) | (Int16(data[7]) << 8)
			let yq = y
			let z = (Int16(data[8]) & 0xff) | (Int16(data[9]) << 8)
			let zq = z
			if selectedDevices[0] == sender {
				label.text = String("Accel - x:\(xq), y:\(yq), z:\(zq)")
			}
			//			rxCount += 1
			break
		case NEBLINA_COMMAND_SENSOR_GYROSCOPE_STREAM:
			let x = (Int16(data[4]) & 0xff) | (Int16(data[5]) << 8)
			let xq = x
			let y = (Int16(data[6]) & 0xff) | (Int16(data[7]) << 8)
			let yq = y
			let z = (Int16(data[8]) & 0xff) | (Int16(data[9]) << 8)
			let zq = z
			if selectedDevices[0] == sender {
				label.text = String("Gyro - x:\(xq), y:\(yq), z:\(zq)")
			}
			//rxCount += 1
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
			if selectedDevices[0] == sender {
				label.text = String("Mag - x:\(xq), y:\(yq), z:\(zq)")
			}
			//rxCount += 1
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
			if selectedDevices[0] == sender {
				label.text = String("IMU - x:\(xq), y:\(yq), z:\(zq)")
			}
			//rxCount += 1
			break
		case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER_STREAM:
			break
		default:
			break
		}
		cmdView.setNeedsDisplay()
	}

}


//
//  DetailViewController.swift
//  Nebblina Control Panel
//
//  Created by Hoan Hoang on 2015-10-22.
//  Copyright © 2015 Hoan Hoang. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore
import SceneKit

let MotionDataStream = Int32(1)
let Heading = Int32(2)
let LuggageDataLog = Int32(3)

let NebCmdList = [NebCmdItem] (arrayLiteral:
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_INTERFACE_STATE, ActiveStatus: UInt32(NEBLINA_INTERFACE_STATUS_BLE.rawValue),
	           Name: "BLE Data Port", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_INTERFACE_STATE, ActiveStatus: UInt32(NEBLINA_INTERFACE_STATUS_UART.rawValue),
	           Name: "UART Data Port", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_DEVICE_NAME_SET, ActiveStatus: 0,
	           Name: "Change Device Name", Actuator : ACTUATOR_TYPE_TEXT_FIELD_BUTTON, Text: "Change"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_SHOCK_SEGMENT_STREAM, ActiveStatus: 0,
	           Name: "Shock Segment Stream", Actuator : ACTUATOR_TYPE_TEXT_FIELD_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_CALIBRATE_FORWARD_POSITION, ActiveStatus: 0,
	           Name: "Calibrate Forward Pos", Actuator : ACTUATOR_TYPE_BUTTON, Text: "Calib Fwrd"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_CALIBRATE_DOWN_POSITION, ActiveStatus: 0,
	           Name: "Calibrate Down Pos", Actuator : ACTUATOR_TYPE_BUTTON, Text: "Calib Dwn"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_RESET_TIMESTAMP, ActiveStatus: 0,
	           Name: "Reset timestamp", Actuator : ACTUATOR_TYPE_BUTTON, Text: "Reset"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_FUSION_TYPE, ActiveStatus: 0,
	           Name: "Fusion 9 axis", Actuator : ACTUATOR_TYPE_SWITCH, Text:""),
    NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STREAM, ActiveStatus: UInt32(NEBLINA_FUSION_STATUS_QUATERNION.rawValue),
               Name: "Quaternion Stream", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
    NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM, ActiveStatus: UInt32(NEBLINA_FUSION_STATUS_PEDOMETER.rawValue),
               Name: "Pedometer Stream", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
    NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_ROTATION_INFO_STREAM, ActiveStatus: UInt32(NEBLINA_FUSION_STATUS_ROTATION_INFO.rawValue),
               Name: "Rotation info Stream", Actuator : ACTUATOR_TYPE_TEXT_FIELD_SWITCH, Text: ""),
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
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_SENSOR, CmdId: NEBLINA_COMMAND_SENSOR_TEMPERATURE_STREAM, ActiveStatus: UInt32(NEBLINA_SENSOR_STATUS_TEMPERATURE.rawValue),
	           Name: "Temperature Sensor Stream", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_FUSION, CmdId: NEBLINA_COMMAND_FUSION_LOCK_HEADING_REFERENCE, ActiveStatus: 0,
	           Name: "Lock Heading Ref.", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_RECORD, ActiveStatus: UInt32(NEBLINA_RECORDER_STATUS_RECORD.rawValue),
	           Name: "Flash Record", Actuator : ACTUATOR_TYPE_BUTTON, Text: "Start"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_RECORD, ActiveStatus: 0,
	           Name: "Flash Record", Actuator : ACTUATOR_TYPE_BUTTON, Text: "Stop"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_PLAYBACK, ActiveStatus: 0,
	           Name: "Flash Playback", Actuator : ACTUATOR_TYPE_TEXT_FIELD_BUTTON, Text: "Play"),
//	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD, ActiveStatus: 0,
//	           Name: "Flash Download", Actuator : ACTUATOR_TYPE_BUTTON, Text: "Start"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_LED, CmdId: NEBLINA_COMMAND_LED_STATE, ActiveStatus: 0,
	           Name: "Set LED0 level", Actuator : ACTUATOR_TYPE_TEXT_FIELD, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_LED, CmdId: NEBLINA_COMMAND_LED_STATE, ActiveStatus: 0,
	           Name: "Set LED1 level", Actuator : ACTUATOR_TYPE_TEXT_FIELD, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_LED, CmdId: NEBLINA_COMMAND_LED_STATE, ActiveStatus: 0,
	           Name: "Set LED2", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_EEPROM, CmdId: NEBLINA_COMMAND_EEPROM_READ, ActiveStatus: 0,
	           Name: "EEPROM Read", Actuator : ACTUATOR_TYPE_BUTTON, Text: "Read"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_POWER, CmdId: NEBLINA_COMMAND_POWER_CHARGE_CURRENT, ActiveStatus: 0,
	           Name: "Charge Current in mA", Actuator : ACTUATOR_TYPE_TEXT_FIELD, Text: ""),
	NebCmdItem(SubSysId: 0xf, CmdId: MotionDataStream, ActiveStatus: 0,
	           Name: "Motion data stream", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: 0xf, CmdId: Heading, ActiveStatus: 0,
	           Name: "Heading", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: 0xf, CmdId: LuggageDataLog, ActiveStatus: 0,
	           Name: "Luggage data logging", Actuator : ACTUATOR_TYPE_SWITCH, Text: ""),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_RECORDER, CmdId: NEBLINA_COMMAND_RECORDER_ERASE_ALL, ActiveStatus: 0,
	           Name: "Flash Erase All", Actuator : ACTUATOR_TYPE_BUTTON, Text: "Erase"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_FIRMWARE_UPDATE, ActiveStatus: 0,
	           Name: "Firmware Update", Actuator : ACTUATOR_TYPE_BUTTON, Text: "DFU"),
	NebCmdItem(SubSysId: NEBLINA_SUBSYSTEM_GENERAL, CmdId: NEBLINA_COMMAND_GENERAL_DEVICE_SHUTDOWN, ActiveStatus: 0,
	           Name: "Shutdown", Actuator : ACTUATOR_TYPE_BUTTON, Text: "Shutdown")
)


//let CtrlName = [String](arrayLiteral:"Heading")//, "Test1", "Test2")

class DetailViewController: UIViewController, UITextFieldDelegate, NeblinaDelegate, SCNSceneRendererDelegate, UITableViewDataSource {
	var nebdev : Neblina? {
		didSet {
			nebdev!.delegate = self
		}
	}
	//let scene = SCNScene(named: "art.scnassets/Millennium_Falcon/Millennium_Falcon.dae") as SCNScene!
	//let scene = SCNScene(named: "art.scnassets/SchoolBus/schoolBus.obj")!
	let sceneShip = SCNScene(named: "art.scnassets/ship.scn")!
	//let scene = SCNScene(named: "art.scnassets/AstonMartinRapide/rapide.scn")!
	//let scene = SCNScene(named: "art.scnassets/E-TIE-I/E-TIE-I.3ds.obj")!
	let sceneCube = SCNScene(named: "art.scnassets/neblina_calibration.dae")!
	var scene : SCNScene?
	//let scene = SCNScene(named: "art.scnassets/Neblina_Cube.dae")!
	//var textview = UITextView()

	
	//@IBOutlet weak var detailDescriptionLabel: UILabel!

	@IBOutlet weak var accelGraph : GraphView!
	@IBOutlet weak var gyroGraph : GraphView!
	@IBOutlet weak var magGraph : GraphView!
	
	@IBOutlet weak var cmdView: UITableView!
	@IBOutlet weak var versionLabel: UILabel!
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var flashLabel: UILabel!
	@IBOutlet weak var dumpLabel: UILabel!
	@IBOutlet weak var planeCubeSwitch : UISegmentedControl!
	
	//var eulerAngles = SCNVector3(x: 0,y:0,z:0)
	var ship : SCNNode! //= scene.rootNode.childNodeWithName("ship", recursively: true)!
	let max_count = Int16(15)
	var prevTimeStamp = UInt32(0)
	var cnt = Int16(15)
	var xf = Int16(0)
	var yf = Int16(0)
	var zf = Int16(0)
	var heading = Bool(false)
	var flashEraseProgress = Bool(false)
	var PaketCnt = UInt32(0)
	var dropCnt = UInt32(0)
//	var curDownloadSession = UInt16(0xFFFF)
//	var curDownloadOffset = UInt32(0)
	var curSessionId = UInt16(0)
	var curSessionOffset = UInt32(0)
	var sessionCount = UInt8(0)
	var startDownload = Bool(false)
	var filepath = String()
	var file : FileHandle?
	var downloadRecovering = Bool(false)
	var playback = Bool(false)
	var badTimestampCnt = Int(0)
	var dubTimestampCnt = Int(0)
	var prevPacket = NeblinaFusionPacket_t();
	
/*	var detailItem: Neblina? {
		didSet {
		    // Update the view.
		    //self.configureView()
			//detailItem!.delegate = self
			nebdev = detailItem
			nebdev.setPeripheral(detailItem!.id, peripheral : detailItem!.peripheral)
			nebdev.delegate = self
		}
	}*/
	
	func configureView() {
		// Update the user interface for the detail item.
		if self.nebdev != nil {
		    //if let label = self.consoleTextView {
	        //label.text = detail.description
		   // }
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
		
		
		cnt = max_count

		scene = sceneShip
		// create and add a camera to the scene
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		sceneCube.rootNode.addChildNode(cameraNode)
		let cameraNode1 = SCNNode()
		sceneShip.rootNode.addChildNode(cameraNode1)
		
		//scene?.rootNode.addChildNode(cameraNode)
		
		// place the camera
		cameraNode.position = SCNVector3(x: 0, y: 0, z:20)
		cameraNode1.position = SCNVector3(x: 0, y: 0, z:20)
		//cameraNode.position = SCNVector3(x: 0, y: 15, z: 0)
		//cameraNode.rotation = SCNVector4(0, 0, 1, GLKMathDegreesToRadians(180))
		//cameraNode.rotation = SCNVector4(1, 0, 0, GLKMathDegreesToRadians(180))
		//cameraNode.rotation = SCNVector3(x:
		// create and add a light to the scene
		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light!.type = SCNLight.LightType.omni
		lightNode.position = SCNVector3(x: 0, y: 10, z: 50)
		sceneCube.rootNode.addChildNode(lightNode)
		let lightNode1 = SCNNode()
		lightNode1.light = SCNLight()
		lightNode1.light!.type = SCNLight.LightType.omni
		lightNode1.position = SCNVector3(x: 0, y: 10, z: 50)
		sceneShip.rootNode.addChildNode(lightNode1)
		
		// create and add an ambient light to the scene
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = SCNLight.LightType.ambient
		ambientLightNode.light!.color = UIColor.darkGray
		sceneCube.rootNode.addChildNode(ambientLightNode)
		let ambientLightNode1 = SCNNode()
		ambientLightNode1.light = SCNLight()
		ambientLightNode1.light!.type = SCNLight.LightType.ambient
		ambientLightNode1.light!.color = UIColor.darkGray
		sceneShip.rootNode.addChildNode(ambientLightNode1)
		
		// retrieve the ship node
		
//		ship = scene.rootNode.childNodeWithName("MillenniumFalconTop", recursively: true)!
//		ship = scene.rootNode.childNodeWithName("ARC_170_LEE_RAY_polySurface1394376_2_2", recursively: true)!
		ship = scene?.rootNode.childNode(withName: "ship", recursively: true)!
		
		//ship = scene.rootNode.childNode(withName: "Mesh258_SCHOOL_BUS2_Group2_Group1_Model", recursively: true)!
		ship.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(90), 0, GLKMathDegreesToRadians(180))

		// Cube view
		//ship.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(-90), GLKMathDegreesToRadians(0), GLKMathDegreesToRadians(0))

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
		scnView.backgroundColor = UIColor.black
		
		// add a tap gesture recognizer
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.handleTap(_:)))
		scnView.addGestureRecognizer(tapGesture)
		//scnView.preferredFramesPerSecond = 60
		magGraph.valueRanges = [-16000.0...16000.0, -16000.0...16000.0, -16000.0...16000.0]
		
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
				nebdev!.setLed(UInt8(row - i), Value: UInt8(value!))
			
				break
			case NEBLINA_SUBSYSTEM_POWER:
				nebdev!.setBatteryChargeCurrent(value!)
				break
			default:
				break
		}

		return true;
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
	

	override var shouldAutorotate : Bool {
		return true
	}
	
	override var prefersStatusBarHidden : Bool {
		return true
	}
	
	override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		if UIDevice.current.userInterfaceIdiom == .phone {
			return .allButUpsideDown
		} else {
			return .all
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	@IBAction func switch3DView(_ sender:UISwitch)
	{
		if (sender.isOn) {
			cmdView.isHidden = true
			let scnView = self.view.subviews[0] as! SCNView
			scnView.isHidden = false
			accelGraph.isHidden = false
			gyroGraph.isHidden = false
			magGraph.isHidden = false
			planeCubeSwitch.isHidden = false
		}
		else {
			cmdView.isHidden = false
			let scnView = self.view.subviews[0] as! SCNView
			scnView.isHidden = true
			accelGraph.isHidden = true
			gyroGraph.isHidden = true
			magGraph.isHidden = true
			planeCubeSwitch.isHidden = true
		}
	}
	
	@IBAction func switch3DObject(_ sender:UISegmentedControl)
	{
		if sender.selectedSegmentIndex == 0 {
			scene = sceneShip
			ship = scene?.rootNode.childNode(withName: "ship", recursively: true)!
			let scnView = self.view.subviews[0] as! SCNView
			// set the scene to the view
			scnView.scene = scene
			
			// allows the user to manipulate the camera
//			scnView.allowsCameraControl = true
			
			// show statistics such as fps and timing information
//			scnView.showsStatistics = true
			
			// configure the view
//			scnView.backgroundColor = UIColor.black
		}
		else {
			scene = sceneCube
			ship = scene?.rootNode.childNode(withName: "node", recursively: true)!
			let scnView = self.view.subviews[0] as! SCNView
			// set the scene to the view
			scnView.scene = scene
			
			// allows the user to manipulate the camera
//			scnView.allowsCameraControl = true
			
			// show statistics such as fps and timing information
//			scnView.showsStatistics = true
			
			// configure the view
//			scnView.backgroundColor = UIColor.black
		}
		
	}
	
	@IBAction func buttonAction(_ sender:UIButton)
	{
		let idx = cmdView.indexPath(for: sender.superview!.superview as! UITableViewCell)
		let row = ((idx as NSIndexPath?)?.row)! as Int
		
		if (nebdev == nil) {
			return
		}
		
		if (row < NebCmdList.count) {
			switch (NebCmdList[row].SubSysId)
			{
				case NEBLINA_SUBSYSTEM_GENERAL:
					switch (NebCmdList[row].CmdId)
					{
						case NEBLINA_COMMAND_GENERAL_FIRMWARE_UPDATE:
							nebdev!.firmwareUpdate()
							print("DFU Command")
							break
						case NEBLINA_COMMAND_GENERAL_RESET_TIMESTAMP:
							nebdev!.resetTimeStamp(Delayed: true)
							print("Reset timestamp")
							break
						case NEBLINA_COMMAND_GENERAL_DEVICE_NAME_SET:
							let cell = cmdView.cellForRow( at: IndexPath(row: row, section: 0))
							if (cell != nil) {
								let control = cell!.viewWithTag(4) as! UITextField
								nebdev!.setDeviceName(name: control.text!);
								
	//							nebdev?.device = nil
							}
							
							break
						case NEBLINA_COMMAND_GENERAL_DEVICE_SHUTDOWN:
							nebdev!.shutdown()
							
							break
						default:
							break
					}
					break
				case NEBLINA_SUBSYSTEM_EEPROM:
					switch (NebCmdList[row].CmdId)
					{
						case NEBLINA_COMMAND_EEPROM_READ:
							nebdev!.eepromRead(0)
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
						nebdev!.calibrateForwardPosition()
						break
					case NEBLINA_COMMAND_FUSION_CALIBRATE_DOWN_POSITION:
						nebdev!.calibrateDownPosition()
						break
					default:
						break
					}
					break
				case NEBLINA_SUBSYSTEM_RECORDER:
					switch (NebCmdList[row].CmdId) {
						case NEBLINA_COMMAND_RECORDER_ERASE_ALL:
							if flashEraseProgress == false {
								//print("Send Command erase")
								flashEraseProgress = true;
								flashLabel.text = "Erasing ..."
								nebdev!.eraseStorage(false)
							}
						case NEBLINA_COMMAND_RECORDER_RECORD:
							
							if NebCmdList[row].ActiveStatus == 0 {
								nebdev?.sessionRecord(false, info: "")
							}
							else {
								nebdev!.sessionRecord(true, info: "")
							}
							break
						case NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD:
							let cell = cmdView.cellForRow( at: IndexPath(row: row, section: 0))

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
							}
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
									
									if !(tf.text!.isEmpty) {
										n = (UInt16((tf.text!)))!
										
									}
								
									nebdev?.sessionPlayback(true, sessionId : n)
									PaketCnt = 0
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
		
		if (nebdev == nil) {
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
							nebdev!.setDataPort(row, Ctrl:UInt8(sender.selectedSegmentIndex))
							break;
						default:
							break
					}
					break
				
				case NEBLINA_SUBSYSTEM_FUSION:
					switch (NebCmdList[row].CmdId)
					{
						case NEBLINA_COMMAND_FUSION_MOTION_STATE_STREAM:
							nebdev!.streamMotionState(sender.selectedSegmentIndex == 1)
							break
						case NEBLINA_COMMAND_FUSION_FUSION_TYPE:
							nebdev!.setFusionType(UInt8(sender.selectedSegmentIndex))
							break
						//case IMU_Data:
						//	nebdev!.streamIMU(sender.selectedSegmentIndex == 1)
					//		break
						case NEBLINA_COMMAND_FUSION_QUATERNION_STREAM:
							nebdev!.streamEulerAngle(false)
							heading = false
							prevTimeStamp = 0
							nebdev!.streamQuaternion(sender.selectedSegmentIndex == 1)
							let i = getCmdIdx(0xf,  cmdId: 1)
							let cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
							if (cell != nil) {
								let sw = cell!.viewWithTag(1) as! UISegmentedControl
								sw.selectedSegmentIndex = 0
							}
							break
						case NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM:
							nebdev!.streamPedometer(sender.selectedSegmentIndex == 1)
							break
						case NEBLINA_COMMAND_FUSION_ROTATION_INFO_STREAM:
							let cell = cmdView.cellForRow( at: IndexPath(row: row, section: 0))
							var type = UInt8(0)
							if cell != nil {
								let tf = cell?.viewWithTag(4) as! UITextField
								
								if !(tf.text!.isEmpty) {
									type = (UInt8((tf.text!)))!
									
								}

							}
							nebdev!.streamRotationInfo(sender.selectedSegmentIndex == 1, Type:type)
							break
						case NEBLINA_COMMAND_FUSION_EULER_ANGLE_STREAM:
							nebdev!.streamQuaternion(false)
							nebdev!.streamEulerAngle(sender.selectedSegmentIndex == 1)
							break
						case NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STREAM:
							nebdev!.streamExternalForce(sender.selectedSegmentIndex == 1)
							break
						case NEBLINA_COMMAND_FUSION_TRAJECTORY_RECORD:
							nebdev!.recordTrajectory(sender.selectedSegmentIndex == 1)
							break;
						case NEBLINA_COMMAND_FUSION_TRAJECTORY_INFO_STREAM:
							nebdev!.streamTrajectoryInfo(sender.selectedSegmentIndex == 1)
							break;
//						case NEBLINA_COMMAND_FUSION_MAG_STATE:
//							nebdev!.streamMAG(sender.selectedSegmentIndex == 1)
//							break;
						case NEBLINA_COMMAND_FUSION_LOCK_HEADING_REFERENCE:
							nebdev!.lockHeadingReference()
							let cell = cmdView.cellForRow( at: IndexPath(row: row, section: 0))
							if (cell != nil) {
								let sw = cell!.viewWithTag(1) as! UISegmentedControl
								sw.selectedSegmentIndex = 0
							}
							break
						case NEBLINA_COMMAND_FUSION_SHOCK_SEGMENT_STREAM:
							var thresh = UInt8(0)
							let cell = cmdView.cellForRow( at: IndexPath(row: row, section: 0))
							if cell != nil {
								let tf = cell?.viewWithTag(4) as! UITextField
								thresh = UInt8(tf.text!)!
							}
							nebdev!.streamShockSegment(sender.selectedSegmentIndex == 1, threshold: thresh)
						default:
							break
					}
				case NEBLINA_SUBSYSTEM_LED:
					let i = getCmdIdx(NEBLINA_SUBSYSTEM_LED,  cmdId: NEBLINA_COMMAND_LED_STATE)
					nebdev!.setLed(UInt8(row - i), Value: UInt8(sender.selectedSegmentIndex))
					break
				case NEBLINA_SUBSYSTEM_RECORDER:
					switch (NebCmdList[row].CmdId)
					{
						
						case NEBLINA_COMMAND_RECORDER_ERASE_ALL:
							if (sender.selectedSegmentIndex == 1) {
								flashEraseProgress = true;
							}
							nebdev!.eraseStorage(sender.selectedSegmentIndex == 1)
							break
						case NEBLINA_COMMAND_RECORDER_RECORD:
							nebdev!.sessionRecord(sender.selectedSegmentIndex == 1, info: "")
							break
						case NEBLINA_COMMAND_RECORDER_PLAYBACK:
							nebdev!.sessionPlayback(sender.selectedSegmentIndex == 1, sessionId : 0xffff)
							if (sender.selectedSegmentIndex == 1) {
								PaketCnt = 0
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
							nebdev!.eepromRead(0)
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
						nebdev!.sensorStreamAccelData(sender.selectedSegmentIndex == 1)
						break
					case NEBLINA_COMMAND_SENSOR_GYROSCOPE_STREAM:
						nebdev?.sensorStreamGyroData(sender.selectedSegmentIndex == 1)
						break
					case NEBLINA_COMMAND_SENSOR_HUMIDITY_STREAM:
						nebdev?.sensorStreamHumidityData(sender.selectedSegmentIndex == 1)
						break
					case NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM:
						nebdev?.sensorStreamMagData(sender.selectedSegmentIndex == 1)
						
						break
					case NEBLINA_COMMAND_SENSOR_PRESSURE_STREAM:
						nebdev?.sensorStreamPressureData(sender.selectedSegmentIndex == 1)
						break
					case NEBLINA_COMMAND_SENSOR_TEMPERATURE_STREAM:
						nebdev?.sensorStreamTemperatureData(sender.selectedSegmentIndex == 1)
						break
					case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE_STREAM:
						nebdev?.sensorStreamAccelGyroData(sender.selectedSegmentIndex == 1)
						break
					case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER_STREAM:
						nebdev?.sensorStreamAccelMagData(sender.selectedSegmentIndex == 1)
						break
					default:
						break
					}
					break

				case 0xf:
					switch (NebCmdList[row].CmdId) {
						case Heading:
							nebdev!.streamQuaternion(false)
							nebdev!.streamEulerAngle(sender.selectedSegmentIndex == 1)
							heading = sender.selectedSegmentIndex == 1
							var i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STREAM)
							var cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! UISegmentedControl
								control.selectedSegmentIndex = 0
							}
							i = getCmdIdx(0xF,  cmdId: MotionDataStream)
							cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! UISegmentedControl
								control.selectedSegmentIndex = 0
							}
							i = getCmdIdx(0xF,  cmdId: LuggageDataLog)
							cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! UISegmentedControl
								control.selectedSegmentIndex = 0
							}
							break
						case MotionDataStream:
							if sender.selectedSegmentIndex == 0 {
								nebdev?.disableStreaming()
								break
							}
							
							nebdev!.streamQuaternion(sender.selectedSegmentIndex == 1)
							var i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STREAM)
							var cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! UISegmentedControl
								control.selectedSegmentIndex = sender.selectedSegmentIndex
							}
//							nebdev!.streamIMU(sender.selectedSegmentIndex == 1)
//							i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_IMU_STATE)
//							cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
//							if (cell != nil) {
//								let control = cell!.viewWithTag(1) as! UISegmentedControl
//								control.selectedSegmentIndex = sender.selectedSegmentIndex
//							}
							nebdev!.sensorStreamMagData(sender.selectedSegmentIndex == 1)
							i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM)
							cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! UISegmentedControl
								control.selectedSegmentIndex = sender.selectedSegmentIndex
							}
							nebdev!.streamExternalForce(sender.selectedSegmentIndex == 1)
							i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_EXTERNAL_FORCE_STREAM)
							cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! UISegmentedControl
								control.selectedSegmentIndex = sender.selectedSegmentIndex
							}
							nebdev!.streamPedometer(sender.selectedSegmentIndex == 1)
							i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM)
							cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! UISegmentedControl
								control.selectedSegmentIndex = sender.selectedSegmentIndex
							}
							nebdev!.streamRotationInfo(sender.selectedSegmentIndex == 1, Type : 1)
							i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_ROTATION_INFO_STREAM)
							cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! UISegmentedControl
								control.selectedSegmentIndex = sender.selectedSegmentIndex
							}
							i = getCmdIdx(0xF,  cmdId: Heading)
							cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! UISegmentedControl
								control.selectedSegmentIndex = 0
							}
							i = getCmdIdx(0xF,  cmdId: LuggageDataLog)
							cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! UISegmentedControl
								control.selectedSegmentIndex = 0
							}
							break
						case LuggageDataLog:
							if sender.selectedSegmentIndex == 0 {
								nebdev!.disableStreaming()
								nebdev!.sessionRecord(false, info: "")
								break
							}
							else {
								nebdev!.sensorStreamAccelGyroData(true)
								nebdev!.sensorStreamMagData(true)
								nebdev!.sensorStreamPressureData(true)
								nebdev!.sensorStreamTemperatureData(true)
								nebdev!.sessionRecord(true, info: "")
								
							}
							
							
							var i = getCmdIdx(NEBLINA_SUBSYSTEM_FUSION,  cmdId: NEBLINA_COMMAND_FUSION_QUATERNION_STREAM)
							var cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
							
							
							i = getCmdIdx(0xF,  cmdId: Heading)
							cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
							if (cell != nil) {
								let control = cell!.viewWithTag(1) as! UISegmentedControl
								control.selectedSegmentIndex = 0
							}
							i = getCmdIdx(0xF,  cmdId: MotionDataStream)
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
	
	//func renderer(renderer: SCNSceneRenderer,
	//	updateAtTime time: NSTimeInterval) {
//		let ship = renderer.scene!.rootNode.childNodeWithName("ship", recursively: true)!
//
//
//	}

//	func didReceiveFusionData(type : UInt8, data : FusionPacket) {
//		print("\(data)")
//	}
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
				//print("\(NebCmdList[idx])")
				let cell = cmdView.cellForRow( at: IndexPath(row: idx, section: 0))
				if cell != nil {
					//let cell = cmdView.view(atColumn: 0, row: idx, makeIfNecessary: false)! as NSView
					let control = cell?.viewWithTag(1) as! UISegmentedControl
					if NebCmdList[idx].CmdId == NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE_STREAM {
						if NebCmdList[idx].ActiveStatus == UInt32(NEBLINA_SENSOR_STATUS_ACCELEROMETER_GYROSCOPE.rawValue) {
							print("Accel_Gyro button \(status.sensor) ")
						}
					}
					if (NebCmdList[idx].ActiveStatus & UInt32(status.sensor)) == 0 {
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
	// MARK: Neblina
	func didConnectNeblina(sender : Neblina) {
		// Switch to BLE interface
		prevTimeStamp = 0;
		nebdev!.getSystemStatus()
		nebdev!.getFirmwareVersion()
	}
	
	func didReceiveResponsePacket(sender : Neblina, subsystem : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int)
	{
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
						flashLabel.text = "Flash erased"
						flashEraseProgress = false
						break
					case NEBLINA_COMMAND_RECORDER_RECORD:
						let session = Int16(data[1]) | (Int16(data[2]) << 8)
						if (data[0] != 0) {
							flashLabel.text = String(format: "Recording session %d", session)
						}
						else {
							flashLabel.text = String(format: "Recorded session %d", session)
						}
						break
					case NEBLINA_COMMAND_RECORDER_PLAYBACK:
						let session = Int16(data[1]) | (Int16(data[2]) << 8)
						if (data[0] != 0) {
							flashLabel.text = String(format: "Playing session %d", session)
						}
						else {
							flashLabel.text = String(format: "Playback sess %d finished %u packets", session, nebdev!.getPacketCount())
						
							playback = false
							let i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_PLAYBACK)
							let cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
							if (cell != nil) {
								let sw = cell!.viewWithTag(2) as! UIButton
								sw.setTitle("Play", for: .normal)
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

	//
	// General data
	//
	func didReceiveGeneralData(sender : Neblina, respType: Int32, cmdRspId : Int32, data : UnsafeRawPointer, dataLen : Int, errFlag : Bool) {
		switch (cmdRspId) {
		default:
			break
		}
	}
	
	func didReceiveFusionData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : NeblinaFusionPacket_t, errFlag : Bool) {

		//let errflag = Bool(type.rawValue & 0x80 == 0x80)

		//let id = FusionId(rawValue: type.rawValue & 0x7F)! as FusionId
		//dumpLabel.text = String(format: "Total packet %u @ %0.2f pps, drop \(dropCnt)", nebdev!.getPacketCount(), nebdev!.getDataRate())
	
		switch (cmdRspId) {
			
		case NEBLINA_COMMAND_FUSION_MOTION_STATE_STREAM:
			break
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
				ship.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(90), 0, GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(xrot))
			}
			else {
				ship.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(yrot), GLKMathDegreesToRadians(xrot), GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(zrot))
			}
			
			label.text = String("Euler - Yaw:\(xrot), Pitch:\(yrot), Roll:\(zrot)")
			
		
			break
		case NEBLINA_COMMAND_FUSION_QUATERNION_STREAM:
		
			//
			// Process Quaternion
			//
			//let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)//w
			let xq = Float(x) / 32768.0
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)//x
			let yq = Float(y) / 32768.0
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)//y
			let zq = Float(z) / 32768.0
			let w = (Int16(data.data.6) & 0xff) | (Int16(data.data.7) << 8)//z
			let wq = Float(w) / 32768.0
			ship.orientation = SCNQuaternion(-zq, xq, yq, wq)// ship
			//ship.orientation = SCNQuaternion(-yq, wq, xq, zq)// ship

			//ship.orientation = SCNQuaternion(xq, yq, zq, wq)
			//ship.orientation = SCNQuaternion(yq, -xq, -zq, wq)// cube
			label.text = String("Quat - w:\(xq), x:\(yq), y:\(zq), z:\(wq)")
			if (prevTimeStamp == data.timestamp)
			{
				var diff = Bool(false)
				if prevPacket.data.0 != data.data.0 {
					diff = true
				}
				else if prevPacket.data.1 != data.data.1 {
					diff = true
				}
				else if prevPacket.data.2 != data.data.2 {
					diff = true
				}
				else if prevPacket.data.3 != data.data.3 {
					diff = true
				}
				else if prevPacket.data.4 != data.data.4 {
					diff = true
				}
				else if prevPacket.data.5 != data.data.5 {
					diff = true
				}
				else if prevPacket.data.6 != data.data.6 {
					diff = true
				}
				else if prevPacket.data.7 != data.data.7 {
					diff = true
				}
				else if prevPacket.data.8 != data.data.8 {
					diff = true
				}
				else if prevPacket.data.9 != data.data.9 {
					diff = true
				}
				else if prevPacket.data.10 != data.data.10 {
					diff = true
				}
				else if prevPacket.data.11 != data.data.11 {
					diff = true
				}
				if diff == true {
					badTimestampCnt += 1
				}
				else {
					dubTimestampCnt += 1
				}
				
			}
			//print("\(badTimestampCnt), \(dubTimestampCnt)")
			if (prevTimeStamp == 0 || data.timestamp <= prevTimeStamp)
			{
				prevTimeStamp = data.timestamp;
				prevPacket = data;
			}
			else
			{
				let tdiff = data.timestamp - prevTimeStamp;
				if (tdiff > 49000)
				{
					dropCnt += 1
					//dumpLabel.text = String("\(dropCnt) Drop : \(tdiff), \(badTimestampCnt)")
				}
				prevTimeStamp = data.timestamp
				prevPacket = data
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
				
				ship.position = pos
				
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
			
			label.text = String("Extrn Force - x:\(xq), y:\(yq), z:\(zq)")
			//print("Extrn Force - x:\(xq), y:\(yq), z:\(zq)")
			break
/*		case NEBLINA_COMMAND_FUSION_MAG_STATE:
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
			label.text = String("Mag - x:\(xq), y:\(yq), z:\(zq)")
			
			//ship.rotation = SCNVector4(Float(xq), Float(yq), 0, GLKMathDegreesToRadians(90))
			break
			*/
		case NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM:
			let stridelen = data.data.9;
			let totaldistance = UInt16(data.data.10) + (UInt16(data.data.11) << 8)
			label.text = String("Stride = \(stridelen), dist = \(totaldistance)")
			break
		case NEBLINA_COMMAND_FUSION_SHOCK_SEGMENT_STREAM:
			let ax = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let ay = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let az = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
//			label.text = String("Accel - x:\(xq), y:\(yq), z:\(zq)")
			accelGraph.add(double3(Double(ax), Double(ay), Double(az)))

			let gx = (Int16(data.data.6) & 0xff) | (Int16(data.data.7) << 8)
			let gy = (Int16(data.data.8) & 0xff) | (Int16(data.data.9) << 8)
			let gz = (Int16(data.data.10) & 0xff) | (Int16(data.data.11) << 8)
			gyroGraph.add(double3(Double(gx), Double(gy), Double(gz)))
			break
		default:
			break
		}
		
		
	}
	
	func didReceivePmgntData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen: Int, errFlag : Bool) {
		let value = UInt16(data[0]) | (UInt16(data[1]) << 8)
		if (cmdRspId == NEBLINA_COMMAND_POWER_CHARGE_CURRENT)
		{
			let i = getCmdIdx(NEBLINA_SUBSYSTEM_POWER,  cmdId: NEBLINA_COMMAND_POWER_CHARGE_CURRENT)
			let cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
			if (cell != nil) {
				let control = cell!.viewWithTag(3) as! UITextField
				control.text = String(value)
			}
		}
	}
	
	func didReceiveLedData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen: Int, errFlag : Bool) {
		switch (cmdRspId) {
		case NEBLINA_COMMAND_LED_STATUS:
			let i = getCmdIdx(NEBLINA_SUBSYSTEM_LED,  cmdId: NEBLINA_COMMAND_LED_STATUS)
			var cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
			if (cell != nil) {
				let tf = cell!.viewWithTag(3) as! UITextField
				tf.text = String(data[0])
			}
			cell = cmdView.cellForRow( at: IndexPath(row: i + 1, section: 0))
			if (cell != nil) {
				let tf = cell!.viewWithTag(3) as! UITextField
				tf.text = String(data[1])
			}
			cell = cmdView.cellForRow( at: IndexPath(row: i + 2, section: 0))
			if (cell != nil) {
				let sw = cell!.viewWithTag(1) as! UISegmentedControl
				if (data[2] != 0) {
					sw.selectedSegmentIndex = 1
				}
				else {
					sw.selectedSegmentIndex = 0
				}
			}
			break
		default:
			break
		}
	}
	
	//
	// Debug
	//
	func didReceiveDebugData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	{
		//print("Debug \(type) data \(data)")
		switch (cmdRspId) {
		case NEBLINA_COMMAND_DEBUG_DUMP_DATA:
			dumpLabel.text = String(format: "%02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x",
			                        data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9],
			                        data[10], data[11], data[12], data[13], data[14], data[15])
			break
		default:
			break
		}
	}
		
	func didReceiveRecorderData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen: Int, errFlag : Bool) {
		switch (cmdRspId) {
			case NEBLINA_COMMAND_RECORDER_ERASE_ALL:
				flashLabel.text = "Flash erased"
				flashEraseProgress = false
				break
			case NEBLINA_COMMAND_RECORDER_RECORD:
				let session = Int16(data[1]) | (Int16(data[2]) << 8)
				if (data[0] != 0) {
					flashLabel.text = String(format: "Recording session %d", session)
				}
				else {
					flashLabel.text = String(format: "Recorded session %d", session)
				}
				break
			case NEBLINA_COMMAND_RECORDER_PLAYBACK:
				let session = Int16(data[1]) | (Int16(data[2]) << 8)
				if (data[0] != 0) {
					flashLabel.text = String(format: "Playing session %d", session)
				}
				else {
					flashLabel.text = String(format: "End session %d, %u", session, nebdev!.getPacketCount())
					
					playback = false
					let i = getCmdIdx(NEBLINA_SUBSYSTEM_RECORDER,  cmdId: NEBLINA_COMMAND_RECORDER_PLAYBACK)
					let cell = cmdView.cellForRow( at: IndexPath(row: i, section: 0))
					if (cell != nil) {
						let sw = cell!.viewWithTag(2) as! UIButton
						sw.setTitle("Play", for: .normal)
					}
				}
				break
			case NEBLINA_COMMAND_RECORDER_SESSION_DOWNLOAD:
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
				break
			default:
				break
		}
	}
	
	func didReceiveEepromData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen: Int, errFlag : Bool) {
		switch (cmdRspId) {
			case NEBLINA_COMMAND_EEPROM_READ:
				let pageno = UInt16(data[0]) | (UInt16(data[1]) << 8)
				dumpLabel.text = String(format: "EEP page [%d] : %02x %02x %02x %02x %02x %02x %02x %02x",
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
		switch (cmdRspId) {
		case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_STREAM:
			let x = (Int16(data[4]) & 0xff) | (Int16(data[5]) << 8)
			let xq = x
			let y = (Int16(data[6]) & 0xff) | (Int16(data[7]) << 8)
			let yq = y
			let z = (Int16(data[8]) & 0xff) | (Int16(data[9]) << 8)
			let zq = z
			label.text = String("Accel - x:\(xq), y:\(yq), z:\(zq)")
			accelGraph.add(double3(Double(x), Double(y), Double(z)))
//			rxCount += 1
			break
		case NEBLINA_COMMAND_SENSOR_GYROSCOPE_STREAM:
			let x = (Int16(data[4]) & 0xff) | (Int16(data[5]) << 8)
			let xq = x
			let y = (Int16(data[6]) & 0xff) | (Int16(data[7]) << 8)
			let yq = y
			let z = (Int16(data[8]) & 0xff) | (Int16(data[9]) << 8)
			let zq = z
			label.text = String("Gyro - x:\(xq), y:\(yq), z:\(zq)")
			gyroGraph.add(double3(Double(x), Double(y), Double(z)))
			//rxCount += 1
			break
		case NEBLINA_COMMAND_SENSOR_HUMIDITY_STREAM:
			let x = (Int32(data[4]) & 0xff) | (Int32(data[5]) << 8) | (Int32(data[6]) << 16) | (Int32(data[7]) << 24)
			let xf = Float(x) / 100.0;
			label.text = String("Humidity : \(xf)")
			break
		case NEBLINA_COMMAND_SENSOR_MAGNETOMETER_STREAM:
			//
			// Mag data
			//
			//let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			let x = (Int16(data[4]) & 0xff) | (Int16(data[5]) << 8)
			let y = (Int16(data[6]) & 0xff) | (Int16(data[7]) << 8)
			let z = (Int16(data[8]) & 0xff) | (Int16(data[9]) << 8)
			label.text = String("Mag - x:\(x), y:\(y), z:\(z)")
			magGraph.add(double3(Double(x), Double(y), Double(z)))
			//rxCount += 1
			//ship.rotation = SCNVector4(Float(xq), Float(yq), 0, GLKMathDegreesToRadians(90))
			break
		case NEBLINA_COMMAND_SENSOR_PRESSURE_STREAM:
			break
		case NEBLINA_COMMAND_SENSOR_TEMPERATURE_STREAM:
			let x = (Int32(data[4]) & 0xff) | (Int32(data[5]) << 8) | (Int32(data[6]) << 16) | (Int32(data[7]) << 24)
			let xf = Float(x) / 100.0;
			label.text = String("Temperature : \(xf)")
//print("Temperature \(xf)")
			break
		case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_GYROSCOPE_STREAM:
			let x = (Int16(data[4]) & 0xff) | (Int16(data[5]) << 8)
			let y = (Int16(data[6]) & 0xff) | (Int16(data[7]) << 8)
			let z = (Int16(data[8]) & 0xff) | (Int16(data[9]) << 8)
			label.text = String("IMU - x:\(x), y:\(y), z:\(z)")
			accelGraph.add(double3(Double(x), Double(y), Double(z)))
			let gx = (Int16(data[10]) & 0xff) | (Int16(data[11]) << 8)
			let gy = (Int16(data[12]) & 0xff) | (Int16(data[13]) << 8)
			let gz = (Int16(data[14]) & 0xff) | (Int16(data[15]) << 8)
			gyroGraph.add(double3(Double(gx), Double(gy), Double(gz)))
			//rxCount += 1
			break
		case NEBLINA_COMMAND_SENSOR_ACCELEROMETER_MAGNETOMETER_STREAM:
			let x = (Int16(data[4]) & 0xff) | (Int16(data[5]) << 8)
			let y = (Int16(data[6]) & 0xff) | (Int16(data[7]) << 8)
			let z = (Int16(data[8]) & 0xff) | (Int16(data[9]) << 8)
			label.text = String("Accel - x:\(x), y:\(y), z:\(z)")
			accelGraph.add(double3(Double(x), Double(y), Double(z)))
			let mx = (Int16(data[10]) & 0xff) | (Int16(data[11]) << 8)
			let my = (Int16(data[12]) & 0xff) | (Int16(data[13]) << 8)
			let mz = (Int16(data[14]) & 0xff) | (Int16(data[15]) << 8)
			magGraph.add(double3(Double(mx), Double(my), Double(mz)))
			break
		default:
			break
		}
		cmdView.setNeedsDisplay()
	}
	
	func didReceiveBatteryLevel(sender: Neblina, level: UInt8) {
		print("Batt level \(level)")
	}

	// MARK : UITableView
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return /*FusionCmdList.count + */NebCmdList.count //+ CtrlName.count
		//return 1//detailItem
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cellView = tableView.dequeueReusableCell(withIdentifier: "CellCommand", for: indexPath)
		let labelView = cellView.viewWithTag(255) as! UILabel
//		let switchCtrl = cellView.viewWithTag(2) as! UIControl//UISegmentedControl
//		var buttonCtrl = cellView.viewWithTag(3) as! UIButton
//		buttonCtrl.hidden = true
		
		//switchCtrl.addTarget(self, action: "switchAction:", forControlEvents: UIControlEvents.ValueChanged)
/*		if (indexPath!.row < FusionCmdList.count) {
			labelView.text = FusionCmdList[indexPath!.row].Name //NebApiName[indexPath!.row] as String//"Row \(row)"//"self.objects.objectAtIndex(row) as! String
		} else */
		if ((indexPath as NSIndexPath).row < /*FusionCmdList.count + */NebCmdList.count) {
			
			labelView.text = NebCmdList[(indexPath as NSIndexPath).row].Name// - FusionCmdList.count].Name
			switch (NebCmdList[(indexPath as NSIndexPath).row].Actuator)
			{
				case ACTUATOR_TYPE_SWITCH:
					let control = cellView.viewWithTag(NebCmdList[(indexPath as NSIndexPath).row].Actuator) as! UISegmentedControl
					control.isHidden = false
					let b = cellView.viewWithTag(2) as! UIButton
					b.isHidden = true
					let t = cellView.viewWithTag(3) as! UITextField
					t.isHidden = true
					break
				case ACTUATOR_TYPE_BUTTON:
					let control = cellView.viewWithTag(NebCmdList[(indexPath as NSIndexPath).row].Actuator) as! UIButton
					control.isHidden = false
					if !NebCmdList[(indexPath as NSIndexPath).row].Text.isEmpty
					{
						control.setTitle(NebCmdList[(indexPath as NSIndexPath).row].Text, for: UIControl.State())
					}
					let s = cellView.viewWithTag(1) as! UISegmentedControl
					s.isHidden = true
					let t = cellView.viewWithTag(3) as! UITextField
					t.isHidden = true
					break
				case ACTUATOR_TYPE_TEXT_FIELD:
					let control = cellView.viewWithTag(NebCmdList[(indexPath as NSIndexPath).row].Actuator) as! UITextField
					control.isHidden = false
					if !NebCmdList[(indexPath as NSIndexPath).row].Text.isEmpty
					{
						control.text = NebCmdList[(indexPath as NSIndexPath).row].Text
					}
					let s = cellView.viewWithTag(1) as! UISegmentedControl
					s.isHidden = true
					let b = cellView.viewWithTag(2) as! UIButton
					b.isHidden = true
					break
				case ACTUATOR_TYPE_TEXT_FIELD_BUTTON:
					let tfcontrol = cellView.viewWithTag(4) as! UITextField
					tfcontrol.isHidden = false
/*					if !NebCmdList[(indexPath! as NSIndexPath).row].Text.isEmpty
					{
						tfcontrol.text = NebCmdList[(indexPath! as NSIndexPath).row].Text
					}*/
					let bucontrol = cellView.viewWithTag(2) as! UIButton
					bucontrol.isHidden = false
					if !NebCmdList[(indexPath as NSIndexPath).row].Text.isEmpty
					{
						bucontrol.setTitle(NebCmdList[(indexPath as NSIndexPath).row].Text, for: UIControl.State())
					}
					let s = cellView.viewWithTag(1) as! UISegmentedControl
					s.isHidden = true
					let t = cellView.viewWithTag(3) as! UITextField
					t.isHidden = true
					break
				
				case ACTUATOR_TYPE_TEXT_FIELD_SWITCH:
					let tfcontrol = cellView.viewWithTag(4) as! UITextField
					tfcontrol.isHidden = false
					let bucontrol = cellView.viewWithTag(1) as! UISegmentedControl
					bucontrol.isHidden = false
					let s = cellView.viewWithTag(2) as! UIButton
					s.isHidden = true
					let t = cellView.viewWithTag(3) as! UITextField
					t.isHidden = true
					break
			
				default:
					//switchCtrl.enabled = false
//					switchCtrl.hidden = true
//					buttonCtrl.hidden = true
					break
			}
		}
//		else {
//			labelView.text = CtrlName[indexPath!.row /*- FusionCmdList.count*/ - NebCmdList.count] //NebApiName[indexPath!.row] as String//"Row \(row)"//"self.objects.objectAtIndex(row) as! String
//		}
		
		
		//cellView.textLabel!.text = NebApiName[indexPath!.row] as String//"Row \(row)"//"self.objects.objectAtIndex(row) as! String
			
		return cellView;
	}

	func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath?) -> Bool
	{
		return false
	}
	func scrollViewDidScroll(_ scrollView: UIScrollView)
	{
		if (nebdev == nil) {
			return
		}
		
		nebdev!.getSystemStatus()
	}
}


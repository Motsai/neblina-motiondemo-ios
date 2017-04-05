//
//  DetailViewController.swift
//  ExerciseMotionTracker
//
//  Created by Hoan Hoang on 2015-11-24.
//  Copyright © 2015 Hoan Hoang. All rights reserved.
//

import UIKit
import CoreBluetooth
import SceneKit

class DetailViewController: UIViewController, CBPeripheralDelegate, NeblinaDelegate, SCNSceneRendererDelegate {

	var nebdev : Neblina! {
		didSet {
			self.configureView()
			nebdev.delegate = self
		}
	}
	let scene = SCNScene(named: "art.scnassets/C-3PO.dae")!
	//let scene = SCNScene(named: "art.scnassets/Millenium_Falcon/Millenium_Falcon.dae")!
	var ship = SCNNode() //= scene.rootNode.childNodeWithName("ship", recursively: true)!

	@IBOutlet weak var label1: UILabel!
	@IBOutlet weak var label2: UILabel!
	@IBOutlet weak var level:UIProgressView!
	
/*	var detailItem: Neblina? {
		didSet {
		    // Update the view.
		    self.configureView()
			nebdev.setPeripheral(detailItem!.id, peripheral: (detailItem?.peripheral)!)
			nebdev.delegate = self
		}
	}*/

	func configureView() {
		// Update the user interface for the detail item.
//		if let detail = self.detailItem {
//		    if let label = self.detailDescriptionLabel {
//		        label.text = detail.description
//		    }
//		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.configureView()
		
		// create and add a camera to the scene
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		scene.rootNode.addChildNode(cameraNode)
		
		// place the camera
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 8)
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
		ambientLightNode.light!.color = UIColor.darkGray
		scene.rootNode.addChildNode(ambientLightNode)
		
		// retrieve the ship node
		ship = scene.rootNode.childNode(withName: "C3PO", recursively: true)!
		ship.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(90), 0, GLKMathDegreesToRadians(180))
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
		let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
		scnView.addGestureRecognizer(tapGesture)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func buttonTrajectRecord(_ button: UIButton)
	{
		nebdev.streamTrajectoryInfo(true)
		nebdev.recordTrajectory(true)
	}
	
	// MARK : Neblina
	func didConnectNeblina(sender : Neblina) {
		nebdev.streamEulerAngle(false)
		nebdev.streamQuaternion(true)
		nebdev.streamTrajectoryInfo(true)
	}
	
	func didReceiveRSSI(sender : Neblina , rssi : NSNumber) {
		
	}
	func didReceiveGeneralData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafeRawPointer, dataLen : Int, errFlag : Bool) {
		
	}
	func didReceiveFusionData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : NeblinaFusionPacket, errFlag : Bool) {
//	func didReceiveFusionData(type : FusionId, data : Fusion_DataPacket_t) {
		//let textview = self.view.viewWithTag(3) as! UITextView
		
		switch (cmdRspId) {
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
			ship.orientation = SCNQuaternion(yq, xq, zq, wq)
			//textview.text = String("Quat - x:\(xq), y:\(yq), z:\(zq), w:\(wq)")
			
			
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
			
			//textview.text = String("Extrn Force - x:\(xq), y:\(yq), z:\(zq)")
			//print("Extrn Force - x:\(xq), y:\(yq), z:\(zq)")
			break

		case NEBLINA_COMMAND_FUSION_TRAJECTORY_INFO_STREAM:
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let count = (Int16(data.data.6) & 0xff) | (Int16(data.data.7) << 8)
			let prval = Int(data.data.8)
			print("\(data.data)")
			label1.text = String("Error \(x),  \(y),  \(z)")
			label2.text = String("Count \(count), Val \(prval) %")
			level.progress = Float(prval)/100.0
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


//
//  ViewController.swift
//  NebFullBody
//
//  Created by Hoan Hoang on 2017-04-04.
//  Copyright © 2017 Hoan Hoang. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore
import SceneKit


class ViewController: UIViewController, UITextFieldDelegate, NeblinaDelegate, SCNSceneRendererDelegate {
	let scene = SCNScene(named: "art.scnassets/Body_Mesh_Rigged.dae")!
	//let scene = SCNScene(named: "art.scnassets/ship.scn")!
	var body : SCNNode!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		// create and add a camera to the scene
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		scene.rootNode.addChildNode(cameraNode)
		
		// place the camera
		cameraNode.position = SCNVector3(x: 0, y: 1.5, z: 4)
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
		ambientLightNode.light!.color = UIColor.darkGray
		scene.rootNode.addChildNode(ambientLightNode)
		
		body = scene.rootNode.childNode(withName :"Armature", recursively: true)!
		//body = scene.rootNode.childNode(withName :"ship", recursively: true)!
		
		
		// set the scene to the view
		let scnView = self.view.subviews[0] as! SCNView
		
		// set the scene to the view
		scnView.scene = scene
		
		// allows the user to manipulate the camera
		scnView.allowsCameraControl = true
		
		// show statistics such as fps and timing information
		scnView.showsStatistics = true
		
		// configure the view
		scnView.backgroundColor = UIColor.black
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// *****
	// NeblinaDelegate
	// *****
	
	func didConnectNeblina(sender : Neblina ) {
		
	}
	func didReceiveRSSI(sender : Neblina , rssi : NSNumber) {
		
	}
	func didReceiveGeneralData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafeRawPointer, dataLen : Int, errFlag : Bool) {
		
	}
	
	func didReceiveBatteryLevel(sender: Neblina, level: UInt8) {
		
	}
	
	func didReceiveResponsePacket(sender: Neblina, subsystem: Int32, cmdRspId: Int32, data: UnsafePointer<UInt8>, dataLen: Int) {
		
	}
	
	func didReceiveFusionData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : NeblinaFusionPacket_t, errFlag : Bool) {
	
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


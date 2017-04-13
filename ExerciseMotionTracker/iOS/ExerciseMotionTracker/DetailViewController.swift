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
	var bleCentralManager : CBCentralManager!
	
	var nebdev : Neblina! {
		didSet {
			self.configureView()
			nebdev.delegate = self
		}
	}
	//let scene = SCNScene(named: "art.scnassets/C-3PO.dae")!
	let scene = SCNScene(named: "art.scnassets/Body_Mesh_Rigged.dae")!
	var ship = SCNNode() //= scene.rootNode.childNodeWithName("ship", recursively: true)!

	@IBOutlet weak var label1: UILabel!
	@IBOutlet weak var label2: UILabel!
	@IBOutlet weak var level:UIProgressView!
	
	@IBAction func editDidEndOnExit(_ sender: Any) {
		let view = sender as! UITextField// self.view.subviews[5] as! UITextField
		print("\(view.text)")
		nebdev.setDeviceName(name: view.text!)
		
		bleCentralManager.cancelPeripheralConnection(nebdev.device)
		nebdev.device = nil
	}
	
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
		cameraNode.position = SCNVector3(x: 0, y: 1.5, z: 4)
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
		ship = scene.rootNode.childNode(withName: "Armature", recursively: true)!
		//ship.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(90), 0, GLKMathDegreesToRadians(180))
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
		
		let view = self.view.subviews[5] as! UITextField
		view.text = nebdev.device.name
	}
	
	func didReceiveResponsePacket(sender : Neblina, subsystem : Int32, cmdRspId : Int32, data : UnsafeRawPointer, dataLen : Int)
	{
		
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

			// transform knee
			let xq1 = xq
			let yq1 = yq
			let zq1 = zq
			let wq1 = wq
			
			let xq2 = Float(sqrt(2) / 2.0)
			let yq2 = Float(0.0)
			let zq2 = -Float(sqrt(2) / 2.0)
			let wq2 = Float(0.0)
			
			var rxq = xq1 * xq2 - yq1 * yq2
				rxq = rxq - zq1 * zq2 - wq1 * wq2
			var ryq = xq1 * yq2 + yq1 * xq2
				ryq = ryq + zq1 * wq2 - wq1 * zq2
			var rzq = xq1 * zq2 - yq1 * wq2
				rzq = rzq + zq1 * xq2 + wq1 * yq2
			var rwq = xq1 * wq2 + yq1 * zq2
				rwq = rwq - zq1 * yq2 + wq1 * xq2
			if sender.device != nil {
			let node = ship.childNode(withName :sender.device.name!, recursively: true)
				if node != nil {
					//node.orientation = SCNQuaternion(yq, xq, zq, wq)
					//node.orientation = SCNQuaternion(wq, xq, -zq, yq)
					//node?.orientation = SCNQuaternion(rwq, rxq, -rzq, ryq)
					node?.orientation = SCNQuaternion(xq, yq, zq, wq)
				}
			}
			//ship.orientation = SCNQuaternion(yq, xq, zq, wq)
			//textview.text = String("Quat - x:\(xq), y:\(yq), z:\(zq), w:\(wq)")
			
			
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


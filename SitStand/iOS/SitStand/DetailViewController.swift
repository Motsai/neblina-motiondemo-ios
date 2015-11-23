//
//  DetailViewController.swift
//  SitStand
//
//  Created by Hoan Hoang on 2015-11-18.
//  Copyright © 2015 Hoan Hoang. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore
import SceneKit

class DetailViewController: UIViewController, CBPeripheralDelegate, SCNSceneRendererDelegate, NeblinaDelegate {

	let device = Neblina()
	//let scene = SCNScene(named: "art.scnassets/C-3PO.obj")!
	let max_count = Int16(15)
	var cnt = Int16(15)
	@IBOutlet weak var sitLabel : UILabel!
	@IBOutlet weak var standLabel : UILabel!
	
	var detailItem: CBPeripheral? {
		didSet {
			// Update the view.
			//self.configureView()
			//detailItem!.delegate = self
			device.setPeripheral(detailItem!)
			device.delegate = self
		}
	}

	func configureView() {
		// Update the user interface for the detail item.
		if let detail = self.detailItem {
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.configureView()
		
/*		cnt = max_count
		
		// create a new scene
		//scene = SCNScene(named: "art.scnassets/ship.scn")!
		
		// create and add a camera to the scene
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
		lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
		scene.rootNode.addChildNode(lightNode)
		
		// create and add an ambient light to the scene
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = SCNLightTypeAmbient
		ambientLightNode.light!.color = UIColor.darkGrayColor()
		scene.rootNode.addChildNode(ambientLightNode)
		
		// retrieve the ship node
		let ship = scene.rootNode.childNodeWithName("MDL Obj", recursively: true)!
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
		scnView.backgroundColor = UIColor.blackColor()
		
		// add a tap gesture recognizer
		let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
		scnView.addGestureRecognizer(tapGesture)*/
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK : Neblina
	
	func didConnectNeblina() {
		device.SittingStanding(true)
	}

	func didReceiveFusionData(type : FusionId, data : Fusion_DataPacket_t) {
		//	let textview = self.view.viewWithTag(3) as! UITextView
		
		switch (type) {
			
		case FusionId.MotionState:
			break
		case FusionId.SixAxisIMU:
			break
		case FusionId.EulerAngle:
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
		case FusionId.Quaternion:
			
			//
			// Process Quaternion
			//
			/*			let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xq = Float(x) / 32768.0
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yq = Float(y) / 32768.0
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zq = Float(z) / 32768.0
			let w = (Int16(data.data.6) & 0xff) | (Int16(data.data.7) << 8)
			let wq = Float(w) / 32768.0
			ship.orientation = SCNQuaternion(yq, xq, zq, wq)
			textview.text = String("Quat - x:\(xq), y:\(yq), z:\(zq), w:\(wq)")
			
			*/
			break
		case FusionId.ExtrnForce:
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
		case FusionId.Mag:
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
		case FusionId.SittingStanding:
			let state = data.data.0
			let sitTime = (Int32(data.data.1) & 0xff) | (Int32(data.data.2) << 8)  | (Int32(data.data.3) << 16) | (Int32(data.data.4) << 24)
			let standTime = (Int32(data.data.5) & 0xff) | (Int32(data.data.6) << 8)  | (Int32(data.data.7) << 16) | (Int32(data.data.8) << 24)
			
			sitLabel.text = "Siting time : \(sitTime)"
			standLabel.text = "Standing time : \(standTime)"
			
			if (state == 0)
			{
				// Stitting
				sitLabel.backgroundColor = UIColor.greenColor()
				standLabel.backgroundColor = UIColor.grayColor()
			}
			else
			{
				// Standing
				sitLabel.backgroundColor = UIColor.grayColor()
				standLabel.backgroundColor = UIColor.greenColor()
			}
			break;
		default: break
		}
		
		
	}

}


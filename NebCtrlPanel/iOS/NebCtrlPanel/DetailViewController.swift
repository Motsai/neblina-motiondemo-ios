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

struct CtrlItem {
	let	CtrlId : FusionId
	let Name : String
}

let CtrlName = [String](arrayLiteral:"Heading", "Test1", "Test2")

class DetailViewController: UIViewController, CBPeripheralDelegate, NeblinaDelegate, SCNSceneRendererDelegate {

	let NebDevice = Neblina()
	
	//@IBOutlet weak var detailDescriptionLabel: UILabel!

	@IBOutlet weak var cmdView: UITableView!
	//var eulerAngles = SCNVector3(x: 0,y:0,z:0)
	let scene = SCNScene(named: "art.scnassets/ship.scn")!
	//var ship : SCNNode //= scene.rootNode.childNodeWithName("ship", recursively: true)!
	let max_count = Int16(15)
	var cnt = Int16(15)
	var xf = Int16(0)
	var yf = Int16(0)
	var zf = Int16(0)
	var heading = Bool(false)
	
	var detailItem: CBPeripheral? {
		didSet {
		    // Update the view.
		    //self.configureView()
			//detailItem!.delegate = self
			NebDevice.setPeripheral(detailItem!)
			NebDevice.delegate = self
		}
	}
	
	func configureView() {
		// Update the user interface for the detail item.
		if let detail = self.detailItem {
		    //if let label = self.consoleTextView {
	        //label.text = detail.description
		   // }
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		cnt = max_count
		
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
		let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
		ship.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(90), 0, GLKMathDegreesToRadians(180))
		//ship.rotation = SCNVector4(1, 0, 0, GLKMathDegreesToRadians(90))
		//print("1 - \(ship)")
		// animate the 3d object
		//ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
		//ship.runAction(SCNAction.rotateToX(CGFloat(eulerAngles.x), y: CGFloat(eulerAngles.y), z: CGFloat(eulerAngles.z), duration:1 ))// 10, y: 0.0, z: 0.0, duration: 1))
		
		// retrieve the SCNView
		let scnView = self.view.subviews[1] as! SCNView
		
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
		scnView.addGestureRecognizer(tapGesture)
		
	}

	/*
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.configureView()
		//NebDevice.delegate = self
	}
*/
	
	func handleTap(gestureRecognize: UIGestureRecognizer) {
		// retrieve the SCNView
		let scnView = self.view as! SCNView
		
		// check what nodes are tapped
		let p = gestureRecognize.locationInView(scnView)
		let hitResults = scnView.hitTest(p, options: nil)
		// check that we clicked on at least one object
		if hitResults.count > 0 {
			// retrieved the first clicked object
			let result: AnyObject! = hitResults[0]
			
			// get its material
			let material = result.node!.geometry!.firstMaterial!
			
			// highlight it
			SCNTransaction.begin()
			SCNTransaction.setAnimationDuration(0.5)
			
			// on completion - unhighlight
			SCNTransaction.setCompletionBlock {
				SCNTransaction.begin()
				SCNTransaction.setAnimationDuration(0.5)
				
				material.emission.contents = UIColor.blackColor()
				
				SCNTransaction.commit()
			}
			
			material.emission.contents = UIColor.redColor()
			
			SCNTransaction.commit()
		}
	}
	

	override func shouldAutorotate() -> Bool {
		return true
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
	
	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
			return .AllButUpsideDown
		} else {
			return .All
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func switchAction(sender:UISegmentedControl)
	{
		//let tableView = sender.superview?.superview?.superview?.superview as! UITableView
		let idx = cmdView.indexPathForCell(sender.superview!.superview as! UITableViewCell)
		let row = (idx?.row)! as Int
		
		if (row < FusionCmdList.count) {
			switch (FusionCmdList[row].CmdId)
			{
			case FusionId.MotionState:
				NebDevice.MotionStream(sender.selectedSegmentIndex == 1)
				break;
			case FusionId.SixAxisIMU:
				NebDevice.SixAxisIMU_Stream(sender.selectedSegmentIndex == 1)
				break;
			case FusionId.Quaternion:
				NebDevice.QuaternionStream(sender.selectedSegmentIndex == 1)
				break;
			case FusionId.EulerAngle:
				NebDevice.EulerAngleStream(sender.selectedSegmentIndex == 1)
				break;
			case FusionId.ExtrnForce:
				NebDevice.ExternalForceStream(sender.selectedSegmentIndex == 1)
				break;
			case FusionId.Pedometer:
				NebDevice.PedometerStream(sender.selectedSegmentIndex == 1)
				break;
			case FusionId.TrajectRecStart:
				NebDevice.TrajectoryRecord(sender.selectedSegmentIndex == 1)
				break;
			case FusionId.TrajectDistance:
				NebDevice.TrajectoryDistanceData(sender.selectedSegmentIndex == 1)
				break;
			case FusionId.Mag:
				NebDevice.MagStream(sender.selectedSegmentIndex == 1)
				break;
			case FusionId.RecorderErase:
				NebDevice.RecorderErase(sender.selectedSegmentIndex == 1)
				break
			case FusionId.RecorderStart:
				NebDevice.Recorder(sender.selectedSegmentIndex == 1)
				break
			default:
				break;
			
			}
		}
		else {
			switch (row - FusionCmdList.count) {
			case 0:
				heading = sender.selectedSegmentIndex == 1
				break
			default:
				break
			}
		}
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
	
	func didReceiveFusionData(type : FusionId, data : Fusion_DataPacket_t) {
		let textview = self.view.viewWithTag(3) as! UITextView

		switch (type) {
			
		case FusionId.MotionState:
			break
		case FusionId.SixAxisIMU:
			break
		case FusionId.EulerAngle:
			//
			// Process Euler Angle
			//
			let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
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
			
		
			break
		case FusionId.Quaternion:
		
			//
			// Process Quaternion
			//
			let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
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
			
			
			break
		case FusionId.ExtrnForce:
			//
			// Process External Force
			//
			let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
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
			//print("Extrn Force - x:\(xq), y:\(yq), z:\(zq)")
			break
		case FusionId.Mag:
			//
			// Mag data
			//
			let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xq = x / 10
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yq = y / 10
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zq = z / 10
			textview.text = String("Mag - x:\(xq), y:\(yq), z:\(zq)")
			//ship.rotation = SCNVector4(Float(xq), Float(yq), 0, GLKMathDegreesToRadians(90))
			break
		
		default: break
		}
		
		
	}
	
	// MARK : UITableView
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return FusionCmdList.count + CtrlName.count
		//return 1//detailItem
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell?
	{
		let cellView = tableView.dequeueReusableCellWithIdentifier("CellCommand", forIndexPath: indexPath!)
		let labelView = cellView.viewWithTag(1) as! UILabel
		//let switchCtrl = cellView.viewWithTag(2) as! UISwitch
		//switchCtrl.addTarget(self, action: "switchAction:", forControlEvents: UIControlEvents.ValueChanged)
		if (indexPath!.row < FusionCmdList.count) {
			labelView.text = FusionCmdList[indexPath!.row].Name //NebApiName[indexPath!.row] as String//"Row \(row)"//"self.objects.objectAtIndex(row) as! String
		} else {
			labelView.text = CtrlName[indexPath!.row - FusionCmdList.count] //NebApiName[indexPath!.row] as String//"Row \(row)"//"self.objects.objectAtIndex(row) as! String
		}
		//cellView.textLabel!.text = NebApiName[indexPath!.row] as String//"Row \(row)"//"self.objects.objectAtIndex(row) as! String
			
		return cellView;
	}

	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool
	{
		return false
	}
}


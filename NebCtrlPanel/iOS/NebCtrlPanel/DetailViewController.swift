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

class DetailViewController: UIViewController, CBPeripheralDelegate, NeblinaDelegate, SCNSceneRendererDelegate {

	let NebDevice = Neblina()
	
	//@IBOutlet weak var detailDescriptionLabel: UILabel!

	@IBOutlet weak var cmdView: UITableView!
	//var eulerAngles = SCNVector3(x: 0,y:0,z:0)
	let scene = SCNScene(named: "art.scnassets/ship.scn")!
	//var ship : SCNNode //= scene.rootNode.childNodeWithName("ship", recursively: true)!

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
		
		// create a new scene
		//scene = SCNScene(named: "art.scnassets/ship.scn")!
		
		// create and add a camera to the scene
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		scene.rootNode.addChildNode(cameraNode)
		
		// place the camera
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
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
		//print("1 - \(ship)")
		// animate the 3d object
		//ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
		//ship.runAction(SCNAction.rotateToX(CGFloat(eulerAngles.x), y: CGFloat(eulerAngles.y), z: CGFloat(eulerAngles.z), duration:1 ))// 10, y: 0.0, z: 0.0, duration: 1))
		
		// retrieve the SCNView
		let scnView = self.view.subviews[2] as! SCNView
		
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
	
	@IBAction func switchAction(sender:UISwitch)
	{
		//let tableView = sender.superview?.superview?.superview?.superview as! UITableView
		let idx = cmdView.indexPathForCell(sender.superview?.superview as! UITableViewCell)
		let row = (idx?.row)! as Int
		
		switch (FusionCmdList[row].CmdId)
		{
		case 2:
			NebDevice.MotionStream(sender.on)
			break;
		case 3:
			NebDevice.SixAxisIMU_Stream(sender.on)
			break;
		case 4:
			NebDevice.QuaternionStream(sender.on)
			break;
		case 5:
			NebDevice.EulerAngleStream(sender.on)
			break;
		case 6:
			NebDevice.ExternalForceStream(sender.on)
			break;
		case 7:
			NebDevice.PedometerStream(sender.on)
			break;
		case 8:
			NebDevice.TrajectoryRecord(sender.on)
			break;
		case 9:
			NebDevice.TrajectoryDistanceData(sender.on)
			break;
		case 10:
			NebDevice.MagStream(sender.on)
			break;
		case 11:
			NebDevice.NineAxisMode(sender.on)
			break;
		case 10:
			break;
		default:
			break;
			
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
	
	func didReceiveFusionData(type : UInt8, data : Fusion_DataPacket_t) {
		let textview = self.view.viewWithTag(3) as! UITextView
		//textview.text = String("packet \(type), \(data)")
		//textview.scrollRangeToVisible(NSRange(location:0, length:10))
		//consoleTextView.reloadInputViews()
		//print("packet \(type), \(data)")
		if (type == 0x5) {
			//
			// Process Euler Angle
			//
//			let d : Int16 = Int16(data.data.0) | Int16(data.data.1) << 8
//			var eulerAngles = SCNVector3()
			
			//d.value.getBytes(&data, range: NSMakeRange(4, 2))
//			eulerAngles.x = Float(d) / 10.0
			//let scene = SCNScene(named: "art.scnassets/ship.scn")!
			let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			//print("2 - \(ship)")
			//ship.eulerAngles = SCNVector3Make(Float(Int16(data.data.0) | (Int16(data.data.1) << 8)) / 10.0, 0, 0)
//			eulerAngles.x = Float(Int16(data.data.0) | (Int16(data.data.1) << 8)) / 10.0
//			let scnView = self.view.subviews[2] as! SCNView
			//scnView.play(ship)
			//SCNTransaction.begin()
			//SCNTransaction.setAnimationDuration(0.5)
			
			// on completion - unhighlight
			//SCNTransaction.setCompletionBlock {
			
				//material.emission.contents = UIColor.blackColor()
				//ship.eulerAngles = SCNVector3Make(Float(Int16(data.data.0) | (Int16(data.data.1) << 8)) / 10.0, 0, 0)
			//pkt->data[0] + 256*pkt->data[1] - 65536*(pkt->data[1]/128);
			//let u16 = UnsafePointer<UInt16>(bytes).memory			
			//let data1 = NSData(bytes: data.data.getBytes(buffer: UnsafeMutablePointer<Void>), length: 2)
			//var x : UInt16(
			//data.data.
			//let xrot1 = UnsafeMutablePointer<UInt16>(data.data).memory
			//print("\(data.data)")
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xrot = Float(x) / 10.0
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yrot = Float(y) / 10.0
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zrot = Float(z) / 10.0
			
//			print("\(Int16(data.data.0)), \(Int16(data.data.1)), \(x16), \(f16)")
			
			//print("\(xrot)")
			//let yrot = Float((Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8) / 10)
			//let zrot = Float((Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8) / 10)
			//let action1 = SCNAction.rotateToX(0, y: CGFloat(GLKMathDegreesToRadians(xrot)), z: 0, duration: 0.5)// rotateToX(CGFloat(Float(Int16(data.data.0) | (Int16(data.data.1) << 8))) / 10.0, y:10, z:0, duration: 1)
			//let action12 = SCNAction.rotateToX(CGFloat(GLKMathDegreesToRadians(yrot)), y: CGFloat(GLKMathDegreesToRadians(xrot)), z: 0, duration: 0.5)// rotateToX(CGFloat(Float(Int16(data.data.0) | (Int16(data.data.1) << 8))) / 10.0, y:10, z:0, duration: 1)
			//let action2 = SCNAction.rotateToX(CGFloat(GLKMathDegreesToRadians(yrot)), y: 0, z: 0, duration: 0.5)// rotateToX(CGFloat(Float(Int16(data.data.0) | (Int16(data.data.1) << 8))) / 10.0, y:10, z:0, duration: 1)
			//let action3 = SCNAction.rotateToX(0, y: 0, z: CGFloat(GLKMathDegreesToRadians(zrot)), duration: 0.5)// rotateToX(CGFloat(Float(Int16(data.data.0) | (Int16(data.data.1) << 8))) / 10.0, y:10, z:0, duration: 1)
			//let action4 = SCNAction.rotateToX(CGFloat(GLKMathDegreesToRadians(yrot)), y: CGFloat(GLKMathDegreesToRadians(xrot)), z: CGFloat(GLKMathDegreesToRadians(zrot)), duration: 0.1)
			//let rep = SCNAction.repeatActionForever(action)
			//let seq = SCNAction.sequence([action1, action12, action4])
			/*SCNTransaction.begin()
			SCNTransaction.setAnimationDuration(0.5)
			ship.runAction(action1)
			SCNTransaction.commit()
			SCNTransaction.begin()
			SCNTransaction.setAnimationDuration(0.5)
			ship.runAction(action12)
			SCNTransaction.commit()*/
			//SCNTransaction.begin()
			//SCNTransaction.setAnimationDuration(0.1)
			//ship.runAction(action4)
			//SCNTransaction.commit()
			//ship.runAction(action4)
			//ship.runAction(SCNAction.sequence([action1, action12, action4]))
			//ship.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(zrot), GLKMathDegreesToRadians(yrot), GLKMathDegreesToRadians(xrot))
			//SCNTransaction.begin()
			//SCNTransaction.setAnimationDuration(0.1)
			ship.eulerAngles.x = GLKMathDegreesToRadians(yrot)
			ship.eulerAngles.y = GLKMathDegreesToRadians(xrot)
			ship.eulerAngles.z = GLKMathDegreesToRadians(zrot)
			//SCNTransaction.commit()
				
			textview.text = String("Euler - Yaw:\(xrot), Pitch:\(yrot), Roll:\(zrot)")
			//}
			//print("\(data)")
			
			//material.emission.contents = UIColor.redColor()
			
			//SCNTransaction.commit()

			//viewDidLoad()
			//ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateToX(CGFloat(eulerAngles.x), y: 0.0, z: 0.0, duration: 1)))  //  rotateToX(eulerAngles( (x:(eulerAngles.x, y: 0, z: 0, duration: 1)))
			//ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
			
		}
		if (type == 0x4)
		{
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
			//let qq = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(-90), 1, 0, 0)
			//let q = GLKQuaternionMake(xq, yq, zq, (wq))
			//let qm = GLKQuaternionMultiply(qq, q)
			//let n = GLKQuaternionNormalize(qm)
			//let cmq = SCNQuaternion(yq, xq, zq, wq)
			ship.orientation = SCNQuaternion(yq, xq, zq, wq)
			textview.text = String("Quat - x:\(xq), y:\(yq), z:\(zq), w:\(wq)")
			
		}
		
	}
	
	// MARK : UITableView
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return FusionCmdList.count
		//return 1//detailItem
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell?
	{
		let cellView = tableView.dequeueReusableCellWithIdentifier("CellCommand", forIndexPath: indexPath!)
		let labelView = cellView.viewWithTag(1) as! UILabel
		//let switchCtrl = cellView.viewWithTag(2) as! UISwitch
		//switchCtrl.addTarget(self, action: "switchAction:", forControlEvents: UIControlEvents.ValueChanged)
		labelView.text = FusionCmdList[indexPath!.row].Name //NebApiName[indexPath!.row] as String//"Row \(row)"//"self.objects.objectAtIndex(row) as! String
		//cellView.textLabel!.text = NebApiName[indexPath!.row] as String//"Row \(row)"//"self.objects.objectAtIndex(row) as! String
			
		return cellView;
	}

	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool
	{
		return false
	}
}


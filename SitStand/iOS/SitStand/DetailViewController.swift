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

	var nebdev : Neblina! {
		didSet {
			nebdev.delegate = self
		}
	}
	//let scene = SCNScene(named: "art.scnassets/C-3PO.obj")!
	let max_count = Int16(15)
	var cnt = Int16(15)
	@IBOutlet weak var sitLabel : UILabel!
	@IBOutlet weak var standLabel : UILabel!
	var displayCnt = Int(0)
	var prevSitTime = UInt32(0)
	var prevStandTime = UInt32(0)
	var cadence = UInt8(0)
	var stepcnt = UInt16(0)

	func configureView() {
		// Update the user interface for the detail item.
//		if let detail = self.detailItem {
//		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.configureView()
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK : Neblina
	
	func didConnectNeblina(sender : Neblina) {
		nebdev.disableStreaming()
		nebdev.streamSittingStanding(false)	// Reset counts
		nebdev.streamPedometer(false)
		nebdev.streamSittingStanding(true)
		nebdev.streamPedometer(true)

	}
	
	func didReceiveRSSI(sender : Neblina, rssi : NSNumber) {
		
	}
	
	func didReceiveGeneralData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafeRawPointer, dataLen : Int, errFlag : Bool) {
		
	}

	func didReceiveFusionData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : NeblinaFusionPacket, errFlag : Bool) {
		//	let textview = self.view.viewWithTag(3) as! UITextView
		
		switch (cmdRspId) {
		case NEBLINA_COMMAND_FUSION_PEDOMETER_STREAM:
			stepcnt = (UInt16(data.data.0) & 0xff) | (UInt16(data.data.1) << 8)
			cadence = data.data.2
			break
		case NEBLINA_COMMAND_FUSION_SITTING_STANDING_STREAM:
			let state = data.data.0
			let sitTime = (UInt32(data.data.1) & 0xff) | (UInt32(data.data.2) << 8)  | (UInt32(data.data.3) << 16) | (UInt32(data.data.4) << 24)
			let standTime = (UInt32(data.data.5) & 0xff) | (UInt32(data.data.6) << 8)  | (UInt32(data.data.7) << 16) | (UInt32(data.data.8) << 24)
			
			if (sitTime != prevSitTime)
			{
				sitLabel.backgroundColor = UIColor.green
				standLabel.backgroundColor = UIColor.gray
			}
			if (standTime != prevStandTime) {
				if (cadence == 0)
				{
					sitLabel.backgroundColor = UIColor.gray
					standLabel.backgroundColor = UIColor.green
				}
				else if (cadence < 120)
				{
					sitLabel.backgroundColor = UIColor.gray
					standLabel.backgroundColor = UIColor.cyan
				}
				else
				{
					sitLabel.backgroundColor = UIColor.gray
					standLabel.backgroundColor = UIColor.red
				}
			}
			prevSitTime = sitTime
			prevStandTime = standTime
			
			sitLabel.text = "Sitting time : \(sitTime) sec"
			standLabel.text = "Standing time : \(standTime) sec\nCadence : \(cadence), Step : \(stepcnt)"

			
			break;
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


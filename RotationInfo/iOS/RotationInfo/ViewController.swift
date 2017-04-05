//
//  ViewController.swift
//  SourcyPanel
//
//  Created by Hoan Hoang on 2016-02-18.
//  Copyright © 2016 Hoan Hoang. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, UITextFieldDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, NeblinaDelegate {

	var objects = [Neblina]()
	var nebdev : Neblina! {
		didSet {
			nebdev.delegate = self
		}
	}
	var bleCentralManager : CBCentralManager!
	var recState = false
	var timer = Timer()
	
	@IBOutlet weak var deviceView: UITableView!
	@IBOutlet weak var recordButton: UIButton!
	@IBOutlet weak var rssiLabel: UILabel!
	@IBOutlet weak var modelLabel : UILabel!
	@IBOutlet weak var snLabel : UILabel!
	@IBOutlet weak var tempLabel : UILabel!
	@IBOutlet weak var rpmLabel : UILabel!
	@IBOutlet weak var speedLabel : UILabel!
	@IBOutlet weak var rotcntLabel : UILabel!
	@IBOutlet weak var distanceLabel : UILabel!
	@IBOutlet weak var rimDiam : UITextField!
	@IBOutlet weak var versLabel : UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		bleCentralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
		timer = Timer.scheduledTimer(timeInterval: 2, target:self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
		rimDiam.delegate = self
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func updateTimer() {
		if (nebdev != nil) {
			nebdev.device.readRSSI()
			nebdev.getTemperature()
		}
	}
	
	@IBAction func rescanAction(_ sender:UIButton) {
		bleCentralManager.stopScan()
		objects.removeAll()
		bleCentralManager.scanForPeripherals(withServices: [NEB_SERVICE_UUID], options: nil)	
	}
	
	@IBAction func recordingAction(_ sender:UIButton) {
		recState = !recState
		if (recState == true) {
			// Start recording
			sender.setTitle("Stop", for: UIControlState())
			nebdev.sensorStreamMagData(true)
			nebdev.sensorStreamAccelGyroData(true)
		}
		else {
			nebdev.sensorStreamMagData(false)
			nebdev.sensorStreamAccelGyroData(false)
			sender.setTitle("Start", for: UIControlState())
		}
		nebdev.sessionRecord(recState)
	}
	
	@IBAction func resetAction(_ sender:UIButton) {
		nebdev.streamRotationInfo(false);	// Reset counts
		nebdev.streamRotationInfo(true);
	}
	
	
/*	var detailItem: NebDevice? {
		didSet {
			// Update the view.
			//self.configureView()
			//detailItem!.delegate = self
			nebdev.setPeripheral(detailItem!.id, peripheral:detailItem!.peripheral)
			nebdev.delegate = self
		}
	}*/
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		// Hide the keyboard.
		textField.resignFirstResponder()
		return true
	}
	
	func didreceiveRSSI(_ rssi :NSNumber) {
//		rssiLabel.text = String(describing: NSNumber);
	}

	
	// MARK : UITableView
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return objects.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath?) -> UITableViewCell? {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath!)
		
		let object = objects[(indexPath! as NSIndexPath).row]
		let label = cell.viewWithTag(1) as! UILabel
		label.text = object.device.name! + String(format: "_%lX", object.id)
		//print("Cell Name : \(cell.textLabel!.text)")
		return cell
	}
	
	func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath?) -> Bool {
		return false
	}
	
	
	func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
		if editingStyle == .delete {
			objects.remove(at: (indexPath as NSIndexPath).row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		} else if editingStyle == .insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
		nebdev = objects[(indexPath as NSIndexPath).row]
		if (nebdev != nil) {
			bleCentralManager.cancelPeripheralConnection(nebdev!.device)
		}
		bleCentralManager.connect(nebdev.device, options: nil)
		//modelLabel.text = String(format: "%lX", object.id)
		modelLabel.text = String("1A06002H-D")
		//snLabel.text = String(format: "%lX", object.id)
		snLabel.text = String("DPC164791")
	}
	
	// MARK: - Bluetooth
	func centralManager(_ central: CBCentralManager,
		didDiscover peripheral: CBPeripheral,
		advertisementData : [String : Any],
		rssi RSSI: NSNumber) {
			//NebPeripheral = peripheral
			//central.connectPeripheral(peripheral, options: nil)
			
			// We have to set the discoveredPeripheral var we declared earlier to reference the peripheral, otherwise we won't be able to interact with it in didConnectPeripheral. And you will get state = connecting> is being dealloc'ed while pending connection error.
			
			//self.discoveredPeripheral = peripheral
			
			//var curDevice = UIDevice.currentDevice()
			
			//iPad or iPhone
			// println("VENDOR ID: \(curDevice.identifierForVendor) BATTERY LEVEL: \(curDevice.batteryLevel)\n\n")
			//println("DEVICE DESCRIPTION: \(curDevice.description) MODEL: \(curDevice.model)\n\n")
			
			// Hardware beacon
			print("PERIPHERAL NAME: \(peripheral.name)\n AdvertisementData: \(advertisementData)\n RSSI: \(RSSI)\n")
			
			print("UUID DESCRIPTION: \(peripheral.identifier.uuidString)\n")
			
			print("IDENTIFIER: \(peripheral.identifier)\n")
			
			if advertisementData[CBAdvertisementDataManufacturerDataKey] == nil {
				return
			}
			//sensorData.text = sensorData.text + "FOUND PERIPHERALS: \(peripheral) AdvertisementData: \(advertisementData) RSSI: \(RSSI)\n"
			var id = UInt64(0)
			(advertisementData[CBAdvertisementDataManufacturerDataKey] as AnyObject).getBytes(&id, range: NSMakeRange(2, 8))
			//if (id == 0) {
			//	return
			//}
			
			let device = Neblina(devid: id, peripheral: peripheral)
			
			for dev in objects
			{
				if (dev.id == id)
				{
					return;
				}
			}
			
			objects.insert(device, at: 0)
			
			deviceView.reloadData();
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		
		//peripheral.delegate = self
		peripheral.discoverServices(nil)
		//gameView.PeripheralConnected(peripheral)
		//		detailView.setPeripheral(NebDevice)
		//NebDevice.setPeripheral(peripheral)
		print("Connected to peripheral")
		
		
	}
	
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		//        sensorData.text = "FAILED TO CONNECT \(error)"
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
	
	// *****
	// MARK : Neblina
	// *****
	//
	func didConnectNeblina(sender : Neblina) {
		// Switch to BLE interface
		//nebdev.SendCmdControlInterface(0)
		//nebdev.SendCmdRotationInfo(false);
		nebdev.getSystemStatus()
		nebdev.getFirmwareVersion()
//		nebdev.device.readRSSI()
		nebdev.streamRotationInfo(true);
	}
	
	func didReceiveRSSI(sender : Neblina, rssi : NSNumber) {
		rssiLabel.text = String(describing: rssi) + String(" db")
	}
	
	func didReceivePmgntData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen: Int, errFlag : Bool) {
		if (cmdRspId == NEBLINA_COMMAND_POWER_TEMPERATURE)
		{
			let t = Float((Int16(data[4]) & 0xff) | (Int16(data[5]) << 8)) / 100.0
			tempLabel.text = String(format:"%0.1f C", t)
		}
	}

	func didReceiveFusionData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : NeblinaFusionPacket, errFlag : Bool) {
		
		//let errflag = Bool(type.rawValue & 0x80 == 0x80)
		
		//let id = FusionId(rawValue: type.rawValue & 0x7F)! as FusionId
		
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
			
			
			break
			
		case NEBLINA_COMMAND_FUSION_ROTATION_INFO_STREAM:
			let rpm = Float(Int16(data.data.4) | (Int16(data.data.5) << 8)) / 10.0
			let rotcnt = Int32(data.data.0) | (Int32(data.data.1) << 8) | (Int32(data.data.2) << 16) | (Int32(data.data.3) << 24)
			let diam = (rimDiam.text! as NSString).floatValue
			//let vt = Float(rpm) * 3.141 * diam * 0.06
			let vt = Float(rpm) * diam * 0.06	// Chain Length
			//let dt = Float(rotcnt) * 3.141 * diam
			let dt = Float(rotcnt) * diam	// Rot * Chain Length
			rpmLabel.text = String(format: "%0.1f rpm", rpm)
			rotcntLabel.text = String(format: "%d tours", rotcnt)
			speedLabel.text = String(format: "%0.1f km/h", vt)
			distanceLabel.text = String(format: "%0.1f m", dt);
			break
			
		default: break
		}
		
		
	}
	
	func didReceiveGeneralData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafeRawPointer, dataLen : Int, errFlag : Bool)
	{
		switch (cmdRspId) {
		case NEBLINA_COMMAND_GENERAL_SYSTEM_STATUS:
			let d = data.load(as: NeblinaSystemStatus_t.self)
			
			switch (d.recorder) {
			case 1:	// Playback
				recState = false
				recordButton.titleLabel?.text = "Start"
//				var i = nebdev.getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashRecordStartStop)
//				var cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
//				var sw = cell!.viewWithTag(2) as! UISegmentedControl
//				sw.selectedSegmentIndex = 0
//				i = nebdev.getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashPlaybackStartStop)
//				cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
//				sw = cell!.viewWithTag(2) as! UISegmentedControl
//				sw.selectedSegmentIndex = 1
				
				break
			case 2:	// Recording
				recState = true
				recordButton.titleLabel?.text = "Stop"
//				var i = nebdev.getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashPlaybackStartStop)
//				var cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
//				var sw = cell!.viewWithTag(2) as! UISegmentedControl
//				sw.selectedSegmentIndex = 0
//				i = nebdev.getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashRecordStartStop)
//				cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
//				sw = cell!.viewWithTag(2) as! UISegmentedControl
//				sw.selectedSegmentIndex = 1
				break
			default:
				recState = false
				recordButton.titleLabel?.text = "Start"
//				var i = nebdev.getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashPlaybackStartStop)
//				var cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
//				var sw = cell!.viewWithTag(2) as! UISegmentedControl
//				sw.selectedSegmentIndex = 0
//				i = nebdev.getCmdIdx(NEB_CTRL_SUBSYS_STORAGE,  cmdId: FlashRecordStartStop)
//				cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
//				sw = cell!.viewWithTag(2) as! UISegmentedControl
//				sw.selectedSegmentIndex = 0
				break
			}
//			var i = nebdev.getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: Quaternion)
//			var cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
//			var sw = cell!.viewWithTag(2) as! UISegmentedControl
//			sw.selectedSegmentIndex = Int(data[4] & 8) >> 3
			
//			i = nebdev.getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: MAG_Data)
////			cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: i, inSection: 0))
//			sw = cell!.viewWithTag(2) as! UISegmentedControl
//			sw.selectedSegmentIndex = Int(data[4] & 0x80) >> 7
			
			//				i = NebDevice.getCmdIdx(NEB_CTRL_SUBSYS_MOTION_ENG,  cmdId: EulerAngle)
			/*				cell = cmdView.cellForRowAtIndexPath( NSIndexPath(forRow: NebCmdList.count, inSection: 0))
			sw = cell!.viewWithTag(2) as! UISegmentedControl
			sw.selectedSegmentIndex = Int(data[4] & 0x4) >> 2*/
			//print("\(d)")
			
			break
		case NEBLINA_COMMAND_GENERAL_FIRMWARE_VERSION:
			let d = data.load(as: NeblinaFirmwareVersion_t.self)
			versLabel.text = String(format: "API:%d, FEN:%d.%d.%d, BLE:%d.%d.%d", d.apiVersion,
			                        d.coreVersion.major, d.coreVersion.minor, d.coreVersion.build,
			                        d.bleVersion.major, d.bleVersion.minor, d.bleVersion.build)
		default:
			break
		}
	
	}
	func didReceiveDebugData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen: Int, errFlag : Bool)
	{
		
	}
	
	func didReceiveRecorderData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen: Int, errFlag : Bool)
	{
		
	}
	
	func didReceiveEepromData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen: Int, errFlag : Bool)
	{
		
	}
	
	func didReceiveLedData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	{
		
	}
	
	func didReceiveSensorData(sender : Neblina, respType : Int32, cmdRspId : Int32, data : UnsafePointer<UInt8>, dataLen : Int, errFlag : Bool)
	{
		
	}
}


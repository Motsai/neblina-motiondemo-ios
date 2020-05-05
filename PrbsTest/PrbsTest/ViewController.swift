//
//  ViewController.swift
//  PrbsTest
//
//  Created by Nguyen Hoan Hoang on 2020-04-30.
//  Copyright © 2020 Motsai. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    let ServiceUid = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    let ReadCharUid = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    let WriteCharUid = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    let pakcetLen = 182
    var bleCentral : CBCentralManager!
    var device : CBPeripheral!
    var readChar : CBCharacteristic! = nil
    var writeChar : CBCharacteristic! = nil
    var lastVal = UInt8(0)
    var dropCnt = UInt(0)
    var totalCnt = UInt(0)
    
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bleCentral = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }

    func Prbs8(CurVal : UInt8) -> UInt8
    {
        let newbit :UInt8 = UInt8((((CurVal >> 6) ^ (CurVal >> 5)) & 1));
        return ((CurVal << 1) | newbit) & 0x7f;
    }
    

    // MARK: BLE Central
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData : [String : Any],
                        rssi RSSI: NSNumber) {
        print("PERIPHERAL NAME: \(String(describing: peripheral.name))\n AdvertisementData: \(advertisementData)\n RSSI: \(RSSI)\n")
        
        print("UUID DESCRIPTION: \(peripheral.identifier.uuidString)\n")
        
        print("IDENTIFIER: \(peripheral.identifier)\n")
 
        if (peripheral.name != "Uart2Ble") {
            return
        }
        central.stopScan()

        device = peripheral
        device.delegate = self
        bleCentral.connect(device, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        peripheral.discoverServices(nil)
        print("Connected to peripheral")
        
        
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        print("disconnected from peripheral")
        
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    }
    
    func scanPeripheral(_ sender: CBCentralManager)
    {
        print("Scan for peripherals")
        bleCentral.scanForPeripherals(withServices: nil, options: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
        case .poweredOff:
            print("CoreBluetooth BLE hardware is powered off")
            break
        case .poweredOn:
            print("CoreBluetooth BLE hardware is powered on and ready")
            
            bleCentral.scanForPeripherals(withServices: nil, options: nil)
            break
        case .resetting:
            print("CoreBluetooth BLE hardware is resetting")
            break
        case .unauthorized:
            print("CoreBluetooth BLE state is unauthorized")
            
            break
        case .unknown:
            print("CoreBluetooth BLE state is unknown")
            break
        case .unsupported:
            print("CoreBluetooth BLE hardware is unsupported on this platform")
            break
            
        }
    }
    
    // MARK: BLE Peripheral
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
    }
    
    //    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
    //        if (device.rssi != nil) {
    //            delegate.didReceiveRSSI(sender: self, rssi: device.rssi!)
    //        }
    //    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
        for service in peripheral.services ?? []
        {
            if service.uuid .isEqual(ServiceUid) || service.uuid .isEqual(CBUUID(string: "180F"))
            {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        for characteristic in service.characteristics ?? []
        {
            //print("car \(characteristic.UUID)");
            if (characteristic.uuid .isEqual(ReadCharUid))
            {
                print("read \(characteristic.uuid)");
                readChar = characteristic;
                print("\(readChar.properties) \n \(CBCharacteristicProperties.notify.rawValue)")
                if ((readChar.properties.rawValue & CBCharacteristicProperties.notify.rawValue) != 0)
                {
                    print("setNotify \(characteristic.uuid)");
                    peripheral.setNotifyValue(true, for: readChar);
                }
            }
            if (characteristic.uuid .isEqual(WriteCharUid))
            {
                print("write \(characteristic.uuid)");
                writeChar = characteristic;
                
            }
            if characteristic.uuid .isEqual(CBUUID(string: "2A19")) {
                // Battery characteristic
                print("Notify battery level")
                peripheral.setNotifyValue(true, for: characteristic);
            }
        }
    }
    
    func peripheralIsReady (toSendWriteWithoutResponse peripheral: CBPeripheral)
    {
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?)
    {
        if characteristic.uuid .isEqual(ReadCharUid) {
            print("didUpdateNotificationStateFor")
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
        if characteristic.uuid .isEqual(CBUUID(string: "2A19")) {
            // Batttery level
            var data = [UInt8](repeating: 0, count: 20)
            //let level =
            characteristic.value!.copyBytes(to: &data, count: characteristic.value!.count) //?.hashValue
            
            print("BATTERY LEVEL = \(data)")
        }
        if (characteristic.uuid .isEqual(ReadCharUid) && characteristic.value != nil && (characteristic.value?.count)! > 0)
        {
            var data = [UInt8](repeating: 0, count: characteristic.value!.count)

            characteristic.value!.copyBytes(to: &data, count: characteristic.value!.count) //?.hashValue
            print("\(characteristic.value)")
            var i = 0
            
            if lastVal == 0 {
                lastVal = data[0]
                i += 1
            }
            
            while i < characteristic.value!.count {
                lastVal = Prbs8(CurVal: lastVal)
                if lastVal != data[i] {
                    dropCnt += 1
                }
                lastVal = data[i]
                i += 1
                totalCnt += 1
                
                resultLabel.text = String(format:"drop:%d, Total:%d", dropCnt, totalCnt)
                
                
            }
            
        }
    }

}


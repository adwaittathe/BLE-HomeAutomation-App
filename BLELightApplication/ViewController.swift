//
//  ViewController.swift
//  BLELightApplication
//
//  Created by Anup Deshpande on 10/29/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
        @IBOutlet weak var OnOffSegment: UISegmentedControl!
    @IBOutlet weak var temperatureLabel: UILabel!
    let bulbServiceCBUUID = CBUUID(string: "DFE60419-82DE-CFEB-02CD-AA1414772848")
    let bulbCharacteristicUUID = CBUUID(string: "FB959362-F26E-43A9-927C-7E17D8FB2D8D")
    let tempratureCharacteristicUUID   = CBUUID(string: "0CED9345-B31F-457D-A6A2-B3DB9B03E39A")
    let beepCharateristicUUID = CBUUID(string: "EC958823-F26E-43A9-927C-7E17D8F32A90")

    var centralManager: CBCentralManager!
    var bulbPeripheral: CBPeripheral!
    var bulbCharacteristic: CBCharacteristic?
    var beepCharacteristic: CBCharacteristic?

    override func viewDidLoad() {
        super.viewDidLoad()
            
        centralManager = CBCentralManager(delegate: self, queue: nil)

        
    }

  
    
    
    @IBAction func onOffSegmentControlTapped(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        if(sender.selectedSegmentIndex == 1)
        {
            print("Off")
             
            var parameter = NSInteger(0)
            let data = NSData(bytes: &parameter, length: 1)
             bulbPeripheral.writeValue(data as Data, for: bulbCharacteristic!, type: .withResponse)
            
        }else
        {
            print("On")
            var parameter = NSInteger(1)
                   let data = NSData(bytes: &parameter, length: 1)
                   bulbPeripheral.writeValue(data as Data, for: bulbCharacteristic!, type: .withResponse)
        }
    }
    @IBAction func beepButtonTapped(_ sender: UIButton) {
        let valueString = ("1" as NSString).data(using: String.Encoding.utf8.rawValue)
        bulbPeripheral.writeValue(valueString!, for: beepCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    
}

extension ViewController: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .unknown:
            print("central.state is .unknown")
             
        case .resetting:
            print("central.state is .resetting")
                      
        case .unsupported:
            print("central.state is .unsupported")
            
        case .unauthorized:
            print("central.state is .unauthorized")
            
        case .poweredOff:
            print("central.state is .poweredOff")
            
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices:[bulbServiceCBUUID])
            
        @unknown default:
            print("default switch statement")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        bulbPeripheral = peripheral
        bulbPeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(bulbPeripheral)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected")

        
        bulbPeripheral.discoverServices([bulbServiceCBUUID])
        
        
    }
    
   
}

extension ViewController: CBPeripheralDelegate{
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
       
        guard let services = peripheral.services else {return}
        
        for service in services{
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics{
            print(characteristic)
            if characteristic.properties.contains(.read) {
              print("\(characteristic.uuid): properties contains .read")
              peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.write) {
              print("\(characteristic.uuid): properties contains .write")
            }
            if characteristic.properties.contains(.notify) {
              print("\(characteristic.uuid): properties contains .notify")
              peripheral.setNotifyValue(true, for: characteristic)
            }
            
           
            
           
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
          case bulbCharacteristicUUID:
            bulbCharacteristic = characteristic
            
            print("Bulb \(characteristic.value?.first)" ?? "no value")
            if let string = String(bytes: characteristic.value!, encoding: .utf8) {
                print("Bulb : \(string)")
                OnOffSegment.selectedSegmentIndex = 1 - Int(string)!
                
            } else {
                print("not a valid UTF-8 sequence")
            }
                
        case tempratureCharacteristicUUID:
           
            if let string = String(bytes: characteristic.value!, encoding: .utf8) {
                print("Temprature : \(string)")
                
                let font:UIFont? = UIFont(name: "Helvetica", size:50)
                let fontSuper:UIFont? = UIFont(name: "Helvetica", size:23)
                let attString:NSMutableAttributedString = NSMutableAttributedString(string: "\(string)o F", attributes: [.font:font!])
                attString.setAttributes([.font:fontSuper!,.baselineOffset:25], range: NSRange(location:2,length:1))
                temperatureLabel.attributedText = attString
                
            } else {
                print("not a valid UTF-8 sequence")
            }
            
        case beepCharateristicUUID:
            beepCharacteristic = characteristic
            print("Beep : \(characteristic.value?.first)" ?? "no value")
            
          default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
}




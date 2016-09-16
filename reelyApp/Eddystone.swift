//
//  Eddystone.swift
//  reelyApp
//
//  Created by Juan Pinazo on 14/09/16.
//  Copyright © 2016 reelyActive. All rights reserved.
//

import Foundation
import CoreBluetooth

class EddystoneAdvertiser: NSObject, CBPeripheralManagerDelegate {
    let reelyAnonymousUUID = "7265656C-7941-7070-2066-6f7220694f53";
    let reelyAnonymousStoryId = "reelyio";
    let PREFIX = "Story ID ";
    
    var manager: CBPeripheralManager!;
    
    func stopAdvertising() {
        manager.stopAdvertising();
    }
    
    func startAdvertising() {
        manager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    @objc func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        print("peripheralManagerDidUpdateState", peripheral)
        
        if (peripheral.state == CBPeripheralManagerState.PoweredOn) {
            let uuidStr = generateUUID(reelyAnonymousStoryId); // 53746f72-7920-4944-2072-65656c79696f
            
            peripheral.startAdvertising([
                CBAdvertisementDataLocalNameKey: "UUID-URL",
                CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: uuidStr)]
            ])
        }   
    }
    
    @objc func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        print("peripheralManagerDidStartAdvertising", peripheral, error)
        
    }
    
    func toUUIDHexString(st:String) -> String {
        var index = 0;
        var output = "";
        for char in st.utf8 {
            output += String(char, radix: 16, uppercase: false);
            if [3, 5, 7, 9].indexOf(index) != nil {
                output += "-";
            }
            index += 1;
            
        }
        return output
    }
    
    func generateUUID(storyId:String) -> String {
        let uuidStr = toUUIDHexString(PREFIX + storyId);
        print("UUID", uuidStr);
        return uuidStr;
    }
}


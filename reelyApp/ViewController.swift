//
//  ViewController.swift
//  reelyApp
//
//  Created by Juan Pinazo on 04/06/16.
//  Copyright © 2016 reelyActive. All rights reserved.
//

import UIKit
import BeaconManager

class ViewController: UIViewController {

    @IBOutlet var reelyTitle: UILabel!
    @IBOutlet weak var privacyPolicy: UIButton!
    @IBOutlet weak var detectMeButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var barnowlImage: UIImageView!
    
    var isAnonymouslyAdvertising: Bool = false;
    let beaconManager: RABeaconManager = RABeaconManager();
    let reelyUUID = "7265656C-7941-7070-2066-6f7220694f53";
    
    let peripheralName = "reelyApp - iOS";

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        statusLabel.hidden = true;
        self.view.backgroundColor = UIColor(red:0.03, green:0.40, blue:0.60, alpha:1.00);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func privacyPolicyClicked(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(
            NSURL(string : "http://context.reelyactive.com/privacy.html")!)
    }

    @IBAction func detectMeButtonClicked(sender: AnyObject) {
        if (isAnonymouslyAdvertising) {
//            isAnonymouslyAdvertising = false;
            detectMeButton.setTitle("DETECT ME ANONYMOUSLY", forState: UIControlState.Normal)
            stopAdvertising()
        } else {
//            isAnonymouslyAdvertising = true;
            detectMeButton.setTitle("Advertising...", forState: UIControlState.Normal)
            detectMeButton.enabled = false
            startAdvertising()
            statusLabel.hidden = false;

        }
    }
    
    func startAdvertising() {
        
        beaconManager.peripheralName = peripheralName
        beaconManager.peripheralServiceUUID = reelyUUID;
        
        if (beaconManager.beaconServices.count != 1) {
            beaconManager.removeAllServices()
        }
        
        beaconManager.advertisePeripheralWhenBeaconDetected = true;
        
        let uuid = NSUUID(UUIDString: reelyUUID)
        let beaconService: RABeaconService = RABeaconService(name: peripheralName, uuid: uuid!);
        
        print(beaconService.serviceUUID)
        print(beaconManager.peripheralServiceUUID)
        
        beaconManager.addBeaconService(beaconService)
        beaconManager.setBeaconDetection(true, iBeacons: false, inBackground: false)
        beaconManager.startDebuggingBeacon()
    }
    
    func stopAdvertising() {
        kill(getpid(), SIGINT);
    }
}


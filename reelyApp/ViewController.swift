//
//  ViewController.swift
//  reelyApp
//
//  Created by Juan Pinazo on 04/06/16.
//  Copyright © 2016 reelyActive. All rights reserved.
//

import UIKit
import BeaconManager
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet var reelyTitle: UILabel!
    @IBOutlet weak var privacyPolicy: UIButton!
    @IBOutlet weak var detectMeButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var barnowlImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var createProfileLabel: UILabel!
    @IBOutlet weak var getStartedLabel: UILabel!
    
    var isAnonymouslyAdvertising: Bool = false;
    let beaconManager: RABeaconManager = RABeaconManager();
    let reelyUUID = "7265656C-7941-7070-2066-6f7220694f53";
    
    let peripheralName = "UUID-URL";
    let eddystoneAdvertiser: EddystoneAdvertiser = EddystoneAdvertiser();

    let userHandler = UserHandler();

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        statusLabel.hidden = true;
        createProfileLabel.hidden = true;
        getStartedLabel.hidden = true;

        detectMeButton.layer.cornerRadius = 5; // this value vary as per your desire
        detectMeButton.clipsToBounds = true;
        
        self.view.backgroundColor = UIColor(red:0.03, green:0.44, blue:0.64, alpha:1.00)
        self.barnowlImage.layer.cornerRadius = 100
        self.barnowlImage.layer.masksToBounds = true
        self.barnowlImage.contentMode = .ScaleAspectFill;
        self.barnowlImage.layer.borderWidth = 12;
        self.barnowlImage.layer.borderColor = UIColor(red:0.22, green:0.55, blue:0.71, alpha:1.00).CGColor;
        updateUI();
        
    }
    
    func updateUI() {
        nameLabel.text = userHandler.getFullName();
        let image = userHandler.getImage();
        if (image !== nil) {
            print("IMAGE NOT NULL")
            barnowlImage.contentMode = .ScaleAspectFill;
            barnowlImage.image = image;
        }
        
        let hasProfile = userHandler.hasProfile();
        print("HAS PROFILE", hasProfile)
        createProfileLabel.hidden = hasProfile;
        getStartedLabel.hidden = hasProfile;
        detectMeButton.hidden = !hasProfile;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func privacyPolicyClicked(sender: AnyObject) {
        print( "PRIVACY ")
        UIApplication.sharedApplication().openURL(
            NSURL(string : "http://context.reelyactive.com/privacy.html")!)
    }

    @IBAction func detectMeButtonClicked(sender: AnyObject) {
        statusLabel.hidden = true;
        if (isAnonymouslyAdvertising) {
            isAnonymouslyAdvertising = false;
            detectMeButton.backgroundColor = UIColor(red:1.00, green:0.41, blue:0.00, alpha:1.00)
            detectMeButton.setTitle("ADVERTISE ME!", forState: UIControlState.Normal)
            stopAdvertising()
        } else {
            isAnonymouslyAdvertising = true;
            detectMeButton.backgroundColor = UIColor(red:0.02, green:0.34, blue:0.47, alpha:1.00);
            detectMeButton.setTitle("((( ADVERTISING )))", forState: UIControlState.Normal)
            startAdvertising()

        }
    }
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        updateUI();
    }

    @IBAction func profileClicked(sender: AnyObject) {
        print("PROFILE CLICKED")
        self.performSegueWithIdentifier("editProfile", sender: self)
    }
    
    func startAdvertising() {
        
        let reelyUUID = eddystoneAdvertiser.generateUUID("reelyio");
        
        beaconManager.peripheralName = peripheralName;
        beaconManager.peripheralServiceUUID = reelyUUID;
        
        if (beaconManager.beaconServices.count != 1) {
            beaconManager.removeAllServices()
        }
        
        beaconManager.advertisePeripheralWhenBeaconDetected = true;
        
        let uuid = NSUUID(UUIDString: reelyUUID)
        let beaconService: RABeaconService = RABeaconService(name: peripheralName, uuid: uuid!);
        
//        print(beaconService.serviceUUID)
//        print(beaconManager.peripheralServiceUUID)
        
        beaconManager.addBeaconService(beaconService);
        beaconManager.setBeaconDetection(true, iBeacons: false, inBackground: true);
        beaconManager.startDebuggingBeacon();
//        eddystoneAdvertiser.startAdvertising()
    }
    
    func stopAdvertising() {
//        eddystoneAdvertiser.stopAdvertising();
//        kill(getpid(), SIGINT);
    }
    
}


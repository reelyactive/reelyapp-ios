//
//  UserHandler.swift
//  reelyApp
//
//  Created by Juan Pinazo on 15/09/16.
//  Copyright © 2016 reelyActive. All rights reserved.
//

import Foundation
import UIKit

class UserHandler {
    
    func setGivenName(givenName:String) {
        setProperty("givenName", propertyValue: givenName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()));
        setProperty("hasProfile", propertyValue: true);
    }

    func setFamilyName(familyName:String) {
        setProperty("familyName", propertyValue: familyName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()));
        setProperty("hasProfile", propertyValue: true);
    }

    func setProperty(propertyName:String, propertyValue:AnyObject) {
        if let plist = UserPlist(name: "UserData") {
            let dict = plist.getMutablePlistFile()!
            dict[propertyName] = propertyValue;
            do {
                try plist.addValuesToPlistFile(dict)
            } catch {
                print(error)
            }
        } else {
            print("Unable to get Plist")
        }
        
    }

    func getImagePath() -> NSString {
        
        let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
        
        let imagePath:NSString = documentsPath.stringByAppendingString("/cachedImage.png")

        return imagePath;
    }
    
    func setImage(selectedImage:UIImage) {
        
        let imageData = UIImagePNGRepresentation(selectedImage)
        let imagePath:NSString = getImagePath();
        if !imageData!.writeToFile(imagePath as String, atomically: false) {
            print("not saved")
        } else {
            NSUserDefaults.standardUserDefaults().setObject(imagePath, forKey: "imagePath")
            print("saved")
            setProperty("hasProfile", propertyValue: true);
        }
    }
    
    func getImage() -> UIImage? {
        let readPath = getImagePath();
        let image = UIImage(contentsOfFile: readPath as String)
        if (image == nil) {
            return nil;
        } else {
            return image!;
        }
    }
    
    func getFullName() -> String {
        if let plist = UserPlist(name: "UserData") {
            let properties = plist.getValuesInPlistFile();
            print("PROPERTIES", properties)
            return ((properties?.objectForKey("givenName"))! as! String) + " " + ((properties?.objectForKey("familyName"))! as! String);
        } else {
            print("Unable to get Plist")
        }
        return "";
    }

    func hasProfile() -> Bool {
        if let plist = UserPlist(name: "UserData") {
            let properties = plist.getValuesInPlistFile();
            print("PROPERTIES", properties)
            let p = properties?.objectForKey("hasProfile");
            if (p == nil) {
                return false;
            }
            return p as! Int == 1;
        } else {
            print("Unable to get Plist")
        }
        return false;
    }
    

    func getGivenName() -> String {
        if let plist = UserPlist(name: "UserData") {
            let properties = plist.getValuesInPlistFile();
            print("PROPERTIES", properties)
            return ((properties?.objectForKey("givenName"))! as! String);
        } else {
            print("Unable to get Plist")
        }
        return "";
    }

    func getFamilyName() -> String {
        if let plist = UserPlist(name: "UserData") {
            let properties = plist.getValuesInPlistFile();
            print("PROPERTIES", properties)
            return ((properties?.objectForKey("familyName"))! as! String);
        } else {
            print("Unable to get Plist")
        }
        return "";
    }
    

}

struct UserPlist {
    enum PlistError: ErrorType {
        case FileNotWritten
        case FileDoesNotExist
    }
    let name:String
    var sourcePath:String? {
        guard let path = NSBundle.mainBundle().pathForResource(name, ofType: "plist") else { return .None }
        return path
    }
    var destPath:String? {
        guard sourcePath != .None else { return .None }
        let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return (dir as NSString).stringByAppendingPathComponent("\(name).plist")
    }

    init?(name:String) {
        self.name = name
        
        let fileManager = NSFileManager.defaultManager()
        
        guard let source = sourcePath else { return nil }
        guard let destination = destPath else { return nil }
        guard fileManager.fileExistsAtPath(source) else { return nil }

        if !fileManager.fileExistsAtPath(destination) {
            do {
                try fileManager.copyItemAtPath(source, toPath: destination)
            } catch let error as NSError {
                print("Unable to copy file. ERROR: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    func getValuesInPlistFile() -> NSDictionary?{
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            guard let dict = NSDictionary(contentsOfFile: destPath!) else { return .None }
            return dict
        } else {
            return .None
        }
    }

    func getMutablePlistFile() -> NSMutableDictionary?{
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            guard let dict = NSMutableDictionary(contentsOfFile: destPath!) else { return .None }
            return dict
        } else {
            return .None
        }
    }
    //3
    func addValuesToPlistFile(dictionary:NSDictionary) throws {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            if !dictionary.writeToFile(destPath!, atomically: false) {
                print("File not written successfully")
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
    
}
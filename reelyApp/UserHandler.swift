//
//  UserHandler.swift
//  reelyApp
//
//  Created by Juan Pinazo on 15/09/16.
//  Copyright © 2016 reelyActive. All rights reserved.
//

import Foundation
import UIKit
import Cloudinary

class UserHandler : NSObject, CLUploaderDelegate {
    
    func setGivenName(givenName:String) {
        setProperty("givenName", propertyValue: givenName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()));
        setProperty("hasProfile", propertyValue: true);
    }

    func setFamilyName(familyName:String) {
        setProperty("familyName", propertyValue: familyName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()));
        setProperty("hasProfile", propertyValue: true);
    }

    func setImageUrl(imageUrl:String) {
        setProperty("imageUrl", propertyValue: imageUrl.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()));
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
        
        let imagePath:NSString = documentsPath.stringByAppendingString("/cachedImage.jpg")

        return imagePath;
    }
    
    func setImage(selectedImage:UIImage) {
        var resized = cropToBounds(selectedImage, width: 100, height: 100);
        resized = resizeImage(resized, newWidth: 300);

        let imageData = UIImageJPEGRepresentation(resized, 0.85);
        let imagePath:NSString = getImagePath();
        if !imageData!.writeToFile(imagePath as String, atomically: false) {
            print("not saved")
        } else {
            NSUserDefaults.standardUserDefaults().setObject(imagePath, forKey: "imagePath")
            print("saved")
            setProperty("hasProfile", propertyValue: true);
            uploadImage();
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    

    
//    @objc func uploaderProgress(bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int, context: AnyObject!) {
//        
//    }
//    
//    @objc func uploaderSuccess(result: [NSObject : AnyObject]!, context: AnyObject!) {
//        
//    }
//    
//    @objc func uploaderError(result: String!, code: Int, context: AnyObject!) {
//        
//    }

    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    func uploadImage() {
//        let cloudinary_url = "CLOUDINARY_URL=cloudinary://396372374222976:GXlJesR6A8vGbbxn0xFkunD47KA@dblqudmg4";
        let clouder = CLCloudinary();
        clouder.config().setValue("dblqudmg4", forKey: "cloud_name");
        let image = getImage();
//        let resized = resizeImage(image!, newWidth: 400);

        let forUpload = UIImageJPEGRepresentation(image!, 0.85);
        let uploader:CLUploader = CLUploader(clouder, delegate: self)
        
        uploader.unsignedUpload(forUpload, uploadPreset: "phe0pjjm", options: nil,
                        withCompletion: { (dataDictionary: [NSObject: AnyObject]!, errorResult:String!, code:Int, context: AnyObject!) -> Void in
                            if (dataDictionary != nil) {
                                let secureUrl = dataDictionary["secure_url"];
                                print("SECURE URL", secureUrl);
                                self.setImageUrl(secureUrl as! String);
                            }
            },
                        andProgress: { (bytesWritten:Int, totalBytesWritten:Int, totalBytesExpectedToWrite:Int, context:AnyObject!) -> Void in
                            print("Upload progress: \((totalBytesWritten * 100)/totalBytesExpectedToWrite) %");
            }
        )
        
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

    func getImageUrl() -> String {
        if let plist = UserPlist(name: "UserData") {
            let properties = plist.getValuesInPlistFile();
            print("PROPERTIES", properties)
            return ((properties?.objectForKey("imageUrl"))! as! String);
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
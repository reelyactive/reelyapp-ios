//
//  Story.swift
//  reelyApp
//
//  Created by Juan Pinazo on 16/09/16.
//  Copyright © 2016 reelyActive. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire

class Person {
    
    var givenName = "";
    var familyName = "";
    var imageUrl = "";
    
    init() {
    }
    
    init(givenName: String, familyName: String, imageUrl: String) {
        self.givenName = givenName;
        self.familyName = familyName;
        self.imageUrl = imageUrl;
        
    }
    
    func toJson() -> JSON {
        let metadata: JSON = [
            "@id": "person",
            "@type": "schema:Person",
            "schema:givenName": self.givenName,
            "schema:familyName": self.familyName,
            "schema:image": self.imageUrl
        ];
        print("PERSON", metadata.rawString())
        return metadata;
    }
    
    func toParameters() -> [String: AnyObject?]{
        let json = toJson();
        return json.dictionaryObject!;
    }
}

class Product {
    var metadata: JSON = JSON([]);
    init() {
    }
    
    func toJson() -> JSON {
        let metadata: JSON = [
            "@id": "product",
            "@type": "schema:Product",
            "schema:name": "reelyApp for iOS",
            "schema:url": "https://itunes.apple.com/br/app/reelyapp-for-ios/id1121042765",
            "schema:image": "https://s3.amazonaws.com/reelyimages/reelyapp.png",
            "schema:manufacturer": [
                "@type": "schema:Organization",
                "schema:name": "Apple"
            ],
            "schema:sameAs": [
                "https://www.twitter.com/reelyactive",
                "https://www.linkedin.com/company/2690385",
                "http://context.reelyactive.com/"
            ],
            "schema:model": UIDevice.currentDevice().modelName
        ];
        print("PERSON", metadata.rawString())
        return metadata;
    }

}

class StoryRequestBody {
    var duration: String = "24h";
    var person: Person = Person();
    var product: Product = Product();
    
    init() {
    }
    
    func setPerson(person: Person) {
        self.person = person;
    }

    func setDuration(duration: String) {
        self.duration = duration;
    }
    
    func toRawJson() -> String {
        let rawString = self.toJson().rawString();
        print("JSON StoryRequestBody", rawString)
        return rawString!;
    }
    
    func toJson() -> JSON {
        let metadata: [String: JSON] = [
            "story": JSON([
                "@context": "http://schema.org/",
                "@graph": JSON([
                    self.person.toJson(),
                    self.product.toJson()
                    ])
            ]),
            "duration": JSON(self.duration)
        ];
        
        let json = JSON(metadata);
        return json
    }
    
    func toParameters() -> [String : AnyObject]? {
        let json = toJson();
        print("PARAMETERS", json.dictionaryObject)
        return json.dictionaryObject!;
    }

}

//Extend Alamofire so it can do POSTs with a JSON body from passed object
extension Alamofire.Manager {
    public class func request(
        method: Alamofire.Method,
        _ URLString: URLStringConvertible,
          body: String)
        -> Request
    {
        return Manager.sharedInstance.request(
            method,
            URLString,
            parameters: [:],
            encoding: .Custom({ (convertible, params) in
                let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
                mutableRequest.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                return (mutableRequest, nil)
            })
        )
    }
}

class Silo {
    func register(requestBody: StoryRequestBody, completion: (storyId: String) -> Void) -> String? {
        
        let request = Alamofire.request(.POST, "http://myjson.info/stories",
                                        parameters: requestBody.toParameters(), encoding: .JSON)
        var storyId: String? = nil;
        request.responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print("JSON: \(json)")
                    let dict = json["devices"].dictionaryObject!;
                    let index = dict.startIndex.advancedBy(0);
                    storyId = dict.keys[index];
                    completion(storyId: storyId!)
                    print(storyId);
                }
            case .Failure(let error):
                print(error)
            }
        }
        return storyId;

    }
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}

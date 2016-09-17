//
//  GoogleCloudStorage.swift
//  reelyApp
//
//  Created by Juan Pinazo on 17/09/16.
//  Copyright © 2016 reelyActive. All rights reserved.
//
//
// Copyright 2015 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import UIKit

//
// Class used to upload photos to Google Cloud Storage.
//
class CloudStorage {
    
    //
    // Uploads an image to a resumable upload URL from GCS.
    //
    internal func uploadImageToGoogleCloud(image: UIImage, uploadUrl: String,
                                           completion:(error: Bool, details: String) -> Void) {
        let imageData = UIImagePNGRepresentation(image)
        
        // The request to send
        let request = NSMutableURLRequest(URL:NSURL(string:uploadUrl)!);
        request.HTTPMethod = "PUT"
        request.addValue("image/png", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer AIzaSyDp_7TmQ7W9S1dEP64H7b40NamHBortGp8", forHTTPHeaderField: "Authorization")
        let uploadSession = NSURLSession.sharedSession()
        let body = NSMutableData()
        body.appendData(imageData!)
        request.HTTPBody = body
        
        // The upload task using NSURLSession
        let uploadTask = uploadSession.uploadTaskWithRequest(request, fromData:body,
                                                             completionHandler: { data, response, error -> Void in
                                                                if error == nil {
                                                                    let httpResponse = response as? NSHTTPURLResponse
                                                                    let statusCode = httpResponse!.statusCode;
                                                                    if statusCode == 200 || statusCode == 201 {
                                                                        completion(error: false, details: "");
                                                                    } else {
//                                                                        let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                                                                        completion (error: true, details: String(format: "Code: %@, Headers: %@", statusCode,
                                                                            httpResponse!.allHeaderFields ))
                                                                    }
                                                                } else {
                                                                    print(error)
                                                                    completion (error: true, details: String(format:"code: %@, domain: %@, userInfo: %@ ",
                                                                        error!.code, error!.domain, error!.userInfo))
                                                                }
        })
        uploadTask.resume()
    }
    
}
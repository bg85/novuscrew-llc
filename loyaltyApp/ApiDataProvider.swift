//
//  ParseDataProvider.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 11/27/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import Foundation
import CryptoSwift


class ApiDataProvider {
    
    func getProfile(email :String, callback:(profile: PProfile?) -> Void) {
        let url = "\(Configuration.ApiUrl)/Profile?email=\(email)"
        HTTPGetRequest(url) { (jsonResult) -> Void in
            if let result = jsonResult {
                callback(profile: PProfile(apiProfileJson: result))
            }
            else {
                callback(profile: nil)
            }}
    }
    
    func createProfile(email: String, password: String, firstName: String, lastName: String) {
        do {
            let url = "\(Configuration.ApiUrl)/Profile"
            let json: Dictionary<String,AnyObject> = ["email": email,"pass":password, "firstName":firstName, "lastName":lastName]
            let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0));
            HTTPPostJSON(url, data:data) { (response, error) -> Void in
                //do nothing
            }
        } catch {
            // do something
        }
    }
    
    func sendEmail(email: String, subject: String, body: String) {
        do {
            let url = "\(Configuration.ApiUrl)/Email"
            let json: Dictionary<String,AnyObject> = ["email": email,"subject":subject, "body": body,"html": "true"]
            let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0));
            HTTPPostJSON(url, data:data) { (response, error) -> Void in
                //do nothing
            }
        } catch {
            // do something
        }
    }
    
    func updatePassword(email: String, password: String) {
        do {
            let url = "\(Configuration.ApiUrl)/Profile"
            let json: Dictionary<String,AnyObject> = ["email": email,"pass":password]
            let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0));
            HTTPPutJSON(url, data:data) { (response, error) -> Void in
                //do nothing
            }
        } catch {
            // do something
        }
    }
    
    func getPoints(skus :[String], callback: (points: Int) -> Void) -> Void {
        let url = "\(Configuration.ApiUrl)/Products"
        HTTPGetRequest(url) { (jsonResult) -> Void in
            if let result = jsonResult {
                callback(points: self.calculatePoints(result))
            }
            else {
                callback(points: -1)
            }}
    }
    
    func deductPoints(email: String, points: Int) {
        do {
            let url = "\(Configuration.ApiUrl)/Points"
            let json: Dictionary<String,AnyObject> = ["email": email,"points":points]
            let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0));
            HTTPPostJSON(url, data:data) { (response, error) -> Void in
                //do nothing
            }
        } catch {
            // do something
        }
    }
    
    private func HTTPPostJSON(url: String,  data: NSData,
        callback: (String, String?) -> Void) {
            
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            
            request.HTTPMethod = "POST"
            request.addValue("application/json",forHTTPHeaderField: "Content-Type")
            request.addValue("application/json",forHTTPHeaderField: "Accept")
            request.addValue(hmacSha256(url),forHTTPHeaderField: "x-emgf-hmac-sha256")
            request.HTTPBody = data
            HTTPsendRequest(request, callback: callback)
    }
    
    private func HTTPPutJSON(url: String,  data: NSData,
        callback: (String, String?) -> Void) {
            
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            
            request.HTTPMethod = "PUT"
            request.addValue("application/json",forHTTPHeaderField: "Content-Type")
            request.addValue("application/json",forHTTPHeaderField: "Accept")
            request.addValue(hmacSha256(url),forHTTPHeaderField: "x-emgf-hmac-sha256")
            request.HTTPBody = data
            HTTPsendRequest(request, callback: callback)
    }
    
    private func HTTPGetRequest(url: String, onCompletion: (result:[NSDictionary]?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.addValue(hmacSha256(url),forHTTPHeaderField: "x-emgf-hmac-sha256")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(responseData, response, error) in
            var jsonData :[NSDictionary]? = nil
            if error == nil {
                do {
                    jsonData = try NSJSONSerialization.JSONObjectWithData(responseData!, options: []) as? [NSDictionary]
                } catch  {
                    //Handler error
                }
            } else {
                //Handle error
            }
            onCompletion(result: jsonData)
        }
        
        task.resume()
    }

    private func HTTPsendRequest(request: NSMutableURLRequest,
        callback: (String, String?) -> Void) {
            let task = NSURLSession.sharedSession()
                .dataTaskWithRequest(request) {
                    (data, response, error) -> Void in
                    if (error != nil) {
                        callback("", error!.localizedDescription)
                    } else {
                        callback(NSString(data: data!,
                            encoding: NSUTF8StringEncoding)! as String, nil)
                    }
            }
            
            task.resume()
    }
    
    
    private func hmacSha256(text: String)-> String {
        let secretKey = "\(Configuration.SecretKet)"
        let msg = text
        
        var secretKeyBuffer = [UInt8]()
        secretKeyBuffer += secretKey.utf8
        
        var messageBuffer = [UInt8]()
        messageBuffer += msg.utf8
        var hash = ""
        do {
            let hmac = try Authenticator.HMAC(key: secretKeyBuffer, variant: .sha256).authenticate(messageBuffer)
            hash =  NSData.withBytes(hmac).toHexString()
        }catch  {
            hash = ""
        }
        
        return hash
    }
    
    private func calculatePoints(json: [NSDictionary]) -> Int {
        return 1
    }
}

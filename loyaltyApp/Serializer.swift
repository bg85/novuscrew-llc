//
//  Serializer.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 11/12/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import Foundation

class Serializer {
    func Serialize(data :AnyObject) -> NSString! {
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(data,
            options: NSJSONWritingOptions(rawValue: 0))
        return NSString(data: jsonData, encoding: NSASCIIStringEncoding)
    }
    
    func Deserialize(data :NSString) -> AnyObject! {
        let data :NSData = data.dataUsingEncoding(NSUTF8StringEncoding)!
        return try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
    }
}
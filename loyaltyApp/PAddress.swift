//
//  PAddress.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/22/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import Foundation
import UIKit
import Buy

class PAddress {
    var addressId: String?
    var firstName: String? = nil
    var lastName: String? = nil
    var address1: String? = nil
    var address2: String? = nil
    var city: String? = nil
    var state: String? = nil
    var zip: String? = nil
    var country: String? = nil

    convenience init(coreAddress: Address) {
        
        self.init()
        
        addressId = coreAddress.addressId
        firstName = coreAddress.firstName
        lastName = coreAddress.lastName
        address1 = coreAddress.address1
        address2 = coreAddress.address2
        city = coreAddress.city
        state = coreAddress.state
        zip = coreAddress.zip
        country = coreAddress.country
    }
    
    convenience init(apiProfileJson: [NSDictionary]) {
        
        self.init()
        
        for dictionary in apiProfileJson {
            let key = "\(dictionary["Key"])"
            if key.containsString("shipingAddress"){
                assignAddress(key, value: dictionary["Value"])
            }
        }
        
        addressId = NSUUID().UUIDString
    }
    
    private func assignAddress(key :String, value:AnyObject?) {
        if key.containsString("address1") {
            address1 = value as? String
        } else if key.containsString("address2") {
            address2 = value as? String
        } else if key.containsString("address2") {
            address2 = value as? String
        } else if key.containsString("city") {
            city = value as? String
        } else if key.containsString("province") {
            state = value as? String
        } else if key.containsString("zip") {
            zip = value as? String
        } else if key.containsString("firstName") {
            firstName = value as? String
        } else if key.containsString("last_name") {
            lastName = value as? String
        } else if key.containsString("country") {
            country = value as? String
        }
    }
    
    func isSamePhisicalAddressThan(address :PAddress) -> Bool {
        return address1 == address.address1 && address2 == address.address2 && city == address.city
        && state == address.state && zip == address.zip && firstName == address.firstName
        && lastName == address.lastName && country == address.country
    }
}

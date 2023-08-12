//
//  PProfile.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/28/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit
import Buy

class PProfile {

    var email: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var points: Int32 = 0
    var pointsStatus : Int32 = 0
    var shares: Int32 = 0
    var usingApplePay = false
    var usingTouchId = false
    var visits: Int32 = 0
    var usingLazyButton = false
    var profileId: String? = nil    
    var password: String? = nil
    var shippingRateId :String? = nil
    var shippingAddressId: String? = nil
    var shippingAddress :PAddress? = nil
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var taxes: Double = 0.0
    var shippingRateTitle: String? = nil
    var shippingRatePrice: Double? = nil
    
    convenience init(coreDataProfile: Profile?) {
        
        self.init()
        
        if let profile = coreDataProfile {
            email = profile.email
            firstName = profile.firstName
            lastName = profile.lastName
            points = profile.points
            pointsStatus = profile.pointsStatus
            shares = profile.shares
            usingApplePay = profile.usingApplePay
            usingTouchId = profile.usingTouchId
            visits = profile.visits
            usingLazyButton = profile.usingLazyButton
            profileId = profile.profileId
            password = profile.password
            shippingRateId = profile.shippingRateId
            shippingAddressId = profile.shippingAddressId
            taxes = profile.taxes
            shippingRatePrice = profile.shippingRatePrice
            shippingRateTitle = profile.shippingRateTitle
            
            if shippingAddressId != nil {
                let localDataProvider = appDelegate.factory.getLocalDataProvider()
                if let address = localDataProvider.getAddress(shippingAddressId!){
                    shippingAddress = PAddress(coreAddress: address)
                }
            }
        }
    }
    
    convenience init(apiProfileJson: [NSDictionary]) {
        
        self.init()
        
        for dictionary in apiProfileJson {
            let key = "\(dictionary["Key"])"
            if !key.containsString("shipingAddress") && !key.containsString("billingAddress"){
                assign("\(dictionary["Key"])" , value: dictionary["Value"])
            }
        }
        shippingAddress = PAddress(apiProfileJson: apiProfileJson)
    }
    
    private func assign(key :String, value:AnyObject?) {
        if key.containsString("email") {
            email = value as? String
        } else if key.lowercaseString.containsString("firstname") {
            firstName = value as? String
        } else if key.lowercaseString.containsString("lastname") {
            lastName = value as? String
        } else if key.lowercaseString.containsString("points_status") {
            pointsStatus = Int32(value as! Int)
        } else if key.lowercaseString.containsString("points") {
            points = Int32(value as! Int)
        } else if key.lowercaseString.containsString("password") {
            password = value as? String
        }
    }
}

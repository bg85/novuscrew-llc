//
//  ICloudDataProvider.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 11/17/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class ICloudDataProvider {
    
    func subscribeToProfileChanges(email: String) {
        let profileRecordId = CKRecordID(recordName: email)
        let predicate = NSPredicate(format: "email = %@", profileRecordId)
        let subscription = CKSubscription(recordType: "Profile", predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordUpdate)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertActionLocalizationKey = "Profile change"
        notificationInfo.shouldBadge = true
        subscription.notificationInfo = notificationInfo
        
        let privateDB = CKContainer.defaultContainer().privateCloudDatabase
        privateDB.saveSubscription(subscription) { (subscription, error) -> Void in
            //TODO: Handler error
        }
    }
    
    func getProfle(viewController: UIViewController?, callback: (email: String?, firstName: String?, lastName: String?, lastPurchase: String?, visits: Int32?, shares: Int32?) -> Void) {
        CKContainer.defaultContainer().accountStatusWithCompletionHandler { (accountStatus, error) -> Void in
            if accountStatus == CKAccountStatus.NoAccount {
                callback(email: nil, firstName: nil, lastName: nil, lastPurchase: nil, visits: nil, shares: nil)
            } else {
                self.retrieveProfile(callback)
            }
        }
    }
    
    func updateProfile(profile: Profile) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let profileRecordId = CKRecordID(recordName: "profile")
            let profileRecord = CKRecord(recordType: "Profile", recordID: profileRecordId);
            
            profileRecord["email"] = profile.email
            profileRecord["firstName"] = profile.firstName
            profileRecord["lastName"] = profile.lastName
            profileRecord["lastPurchase"] = profile.lastPurchase
            profileRecord["visits"] = NSNumber(int: profile.visits)
            profileRecord["shares"] = NSNumber(int: profile.shares)
            //Points are not saved in the cloud because they will be retrieved from Parse every time and they are always updated in Parse
            
            let privateDB = CKContainer.defaultContainer().privateCloudDatabase
            
            privateDB.saveRecord(profileRecord, completionHandler: { (record, error) -> Void in
                //TODO: Handle error
            })
        }
    }
    
    private func retrieveProfile(callback: (email: String?, firstName: String?, lastName: String?, lastPurchase: String?, visits: Int32?, shares: Int32?) -> Void) {
        let privateDB = CKContainer.defaultContainer().privateCloudDatabase
        let profileRecord = CKRecordID(recordName: "profile")
        privateDB.fetchRecordWithID(profileRecord, completionHandler: { (record, error) -> Void in
            if error != nil {
                callback(email: nil, firstName: nil, lastName: nil, lastPurchase: nil, visits: nil, shares: nil)
            } else {
                let visits = record!.objectForKey("visits") as? NSNumber
                let shares = record!.objectForKey("shares") as? NSNumber
                callback(email: record!.objectForKey("email") as? String, firstName: record!.objectForKey("firstName") as? String, lastName: record!.objectForKey("lastName") as? String, lastPurchase: record!.objectForKey("lastPurchase") as? String,
                    visits: visits != nil ? visits?.intValue : 0, shares:shares != nil ? shares?.intValue : 0)
            }
        })
    }
}
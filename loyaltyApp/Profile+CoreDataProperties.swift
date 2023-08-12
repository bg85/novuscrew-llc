//
//  Profile+CoreDataProperties.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 2/20/16.
//  Copyright © 2016 Barbara Gonzalez. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Profile {

    @NSManaged var email: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var password: String?
    @NSManaged var points: Int32
    @NSManaged var pointsStatus: Int32
    @NSManaged var profileId: String?
    @NSManaged var shares: Int32
    @NSManaged var shippingAddressId: String?
    @NSManaged var shippingRateId: String?
    @NSManaged var shippingRatePrice: Double
    @NSManaged var shippingRateTitle: String?
    @NSManaged var taxes: Double
    @NSManaged var usingApplePay: Bool
    @NSManaged var usingLazyButton: Bool
    @NSManaged var usingTouchId: Bool
    @NSManaged var visits: Int32

}

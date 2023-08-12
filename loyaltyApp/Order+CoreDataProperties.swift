//
//  Order+CoreDataProperties.swift
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

extension Order {

    @NSManaged var date: String?
    @NSManaged var merchandiseTotal: Double
    @NSManaged var orderId: String?
    @NSManaged var orderTotal: Double
    @NSManaged var profileId: String?
    @NSManaged var rewardId: String?
    @NSManaged var shippingCost: Double
    @NSManaged var taxes: Double

}

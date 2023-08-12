//
//  Address+CoreDataProperties.swift
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

extension Address {

    @NSManaged var address1: String?
    @NSManaged var address2: String?
    @NSManaged var addressId: String?
    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var state: String?
    @NSManaged var zip: String?

}

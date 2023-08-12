//
//  SProduct+CoreDataProperties.swift
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

extension SProduct {

    @NSManaged var productId: Int64
    @NSManaged var productTitle: String?
    @NSManaged var profileId: String?
    @NSManaged var quantity: Int32
    @NSManaged var title: String?

}

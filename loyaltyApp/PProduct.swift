//
//  PProduct.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/31/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import Foundation
import Buy

class PProduct {
    var profileId :String? = nil
    var productTitle :String? = nil
    var productId :Int64? = nil
    var quantity  :Int32 = 0
    var title :String? = nil
    var shippingMethod: String? = nil
    var variant :BUYProductVariant? = nil
    
    convenience init(profileId :String?, productTitle: String, productId: NSNumber?, title: String) {
        self.init()
        
        self.productId = productId?.longLongValue ?? 0
        self.productTitle = productTitle
        self.title = title
        self.profileId = profileId
    }
    
    convenience init(profileId :String?, productTitle: String, productId: Int64, title: String, quantity: Int32) {
        self.init()

        self.productId = productId
        self.productTitle = productTitle
        self.title = title
        self.profileId = profileId
        self.quantity = quantity
    }
    
    convenience init(variant :BUYProductVariant, baseProduct: PProduct?) {
        self.init()
        
        self.productId = variant.identifier.longLongValue ?? 0
        self.productTitle = variant.product.title
        self.title = variant.title
        self.variant = variant
        if let product = baseProduct {
            self.profileId = product.profileId
            self.quantity = product.quantity
            self.shippingMethod = product.shippingMethod
        }
    }
}

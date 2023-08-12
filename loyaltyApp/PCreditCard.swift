//
//  PCreditCard.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 1/30/16.
//  Copyright © 2016 Barbara Gonzalez. All rights reserved.
//

import UIKit

class PCreditCard {
    var carholderName: String? = nil
    var number: String? = nil
    var expirationMonth: String? = nil
    var expirationYear: String? = nil
    var ccv: String? = nil
    var billingAddress :PAddress? = nil
    
    func isValid() -> Bool {
        return carholderName != nil && !carholderName!.isEmpty
            && number != nil && !number!.isEmpty
            && expirationMonth != nil && !expirationMonth!.isEmpty
            && expirationYear != nil && !expirationYear!.isEmpty
            && ccv != nil && !ccv!.isEmpty
            && billingAddress!.firstName != nil && !billingAddress!.firstName!.isEmpty
            && billingAddress!.lastName != nil && !billingAddress!.lastName!.isEmpty
            && billingAddress!.address1 != nil && !billingAddress!.address1!.isEmpty
            && billingAddress!.city != nil && !billingAddress!.city!.isEmpty
            && billingAddress!.state != nil && !billingAddress!.state!.isEmpty
            && billingAddress!.zip != nil && !billingAddress!.zip!.isEmpty
            && billingAddress!.country != nil && !billingAddress!.country!.isEmpty
    }
}

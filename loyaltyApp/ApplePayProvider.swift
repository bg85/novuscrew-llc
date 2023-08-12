//
//  ApplePayProvider.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 11/16/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit
import PassKit
import Buy

class ApplePayProvider {
    
    func getApplePayViewController(products :[PProduct], shippingMethod: String, shippingCost: Double, taxes: Double, email: String, reward: Reward?) -> PKPaymentAuthorizationViewController? {
        if PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(Configuration.ApplePaySupportedNetworks)
        {
            let paymentRequest = getPaymentRequest()
            addItemsToRequest(products, request: paymentRequest)
            addShippingToRequest(shippingMethod, shippingCost: shippingCost, request: paymentRequest)
            if reward != nil {
                addRewardToRequest(reward!, request: paymentRequest)
            }
            addTaxesToRequest(taxes, request:paymentRequest)
            addTotalToRequest(paymentRequest)
            addEmailToRequest(email, request:paymentRequest)

            return PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        }
        return nil
    }
    
    func getPaymentRequest() -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = Configuration.ApplePayMerchantID
        request.supportedNetworks = Configuration.ApplePaySupportedNetworks
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.requiredShippingAddressFields = PKAddressField.None
        request.requiredBillingAddressFields = PKAddressField.All
        
        return request
    }
    
    func addItemsToRequest(products :[PProduct], request: PKPaymentRequest) {
        var items = [PKPaymentSummaryItem]()
        for product in products {
            let totalPrice = product.variant!.price.doubleValue * Double(product.quantity)
            items.append(PKPaymentSummaryItem(label: product.productTitle!, amount: NSDecimalNumber(double: totalPrice),
                type: PKPaymentSummaryItemType.Final))
        }
        
        request.paymentSummaryItems.appendContentsOf(items)
    }
    
    
    func addShippingToRequest(shippingType :String, shippingCost :Double, request :PKPaymentRequest) {
        request.paymentSummaryItems.append(PKPaymentSummaryItem(label: shippingType, amount: NSDecimalNumber(double: shippingCost)))
    }
    
    func addTaxesToRequest(taxes :Double, request :PKPaymentRequest) {
        request.paymentSummaryItems.append(PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(double: taxes)))
    }
    
    func addRewardToRequest(reward :Reward, request :PKPaymentRequest) {
        request.paymentSummaryItems.append(PKPaymentSummaryItem(label: "Discount", amount: NSDecimalNumber(double: reward.deduction * (-1))))
    }
    
    func addEmailToRequest(email :String, request :PKPaymentRequest) {
        let contact = PKContact()
        contact.emailAddress = email
        request.shippingContact = contact
    }
    
    func addTotalToRequest(request :PKPaymentRequest) {
        var total = 0.0
        
        for item in request.paymentSummaryItems {
            total += item.amount.doubleValue
        }
        
        request.paymentSummaryItems.append(PKPaymentSummaryItem(label: "Eat Me Guilt Free", amount: NSDecimalNumber(double: total)))
    }
}
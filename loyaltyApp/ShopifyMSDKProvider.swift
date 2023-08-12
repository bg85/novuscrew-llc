//
//  ShopifyMSDKProvider.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 11/10/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import Foundation
import Buy
import PassKit

class ShopifyMSDKProvider {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let client: BUYClient
    var products = [BUYProductVariant]()
    var finishedGettingProducts = false
    
    required init() {
        client = BUYClient(shopDomain: Configuration.ShopifyShopDomain, apiKey: Configuration.ShopifyApiKey, channelId: Configuration.ShopifyChannelId)
    }
    
    func getProducts(callback: (products: [BUYProductVariant]) -> Void)
    {
        finishedGettingProducts = false
        retrieveProducts(1, callback: callback)
    }
    
    func getBuyAddress(address :PAddress) -> BUYAddress {
        let buyAddress = BUYAddress()
        buyAddress.firstName = address.firstName
        buyAddress.lastName = address.lastName
        buyAddress.address1 = address.address1
        buyAddress.address2 = address.address2
        buyAddress.city = address.city
        buyAddress.province = address.state
        buyAddress.zip = address.zip
        buyAddress.countryCode = "US"
        
        return buyAddress
    }
    
    func retrieveShippingRates(products : [PProduct], shippingAddress: PAddress, callback: (BUYCheckout,[BUYShippingRate]?, NSError?) -> Void) {
        let cart = getCartWithProducts(products)
        let checkout = BUYCheckout(cart: cart)
        checkout.reservationTime = 0
        
        checkout.shippingAddress = getBuyAddress(shippingAddress)
        
        client.createCheckout(checkout, completion: { (createdCheckout, error) -> Void in
            if error == nil {
                self.retrieveRates(createdCheckout, callback: callback)
            } else {
                callback(checkout, nil, error)
            }
        })
    }
    
    func updateCheckout(checkout :BUYCheckout, callback: (BUYCheckout, NSError?) -> Void) {
        client.updateCheckout(checkout, completion: { (updatedCheckout, error) -> Void in
            callback(updatedCheckout, error)
        })
    }
    
    private func getBuyAddressFromPayment(payment: PKPayment) -> BUYAddress? {

        if let billingContact = payment.billingContact {
            let buyBillingAddress = BUYAddress()
            buyBillingAddress.firstName = billingContact.name?.givenName
            buyBillingAddress.lastName = billingContact.name?.familyName
            if let address = billingContact.postalAddress {
                buyBillingAddress.address1 = address.street
                buyBillingAddress.city = address.city
                buyBillingAddress.province = address.state
                buyBillingAddress.zip = address.postalCode
                buyBillingAddress.country = address.country
            }
            
            return buyBillingAddress
        }
        
        return nil
    }
    
    func doApplePayCheckout(products: [PProduct], shippingAddress: PAddress, email: String, shippingRate: String, discountCode: String?, payment: PKPayment, callback: (BUYCheckout?, NSError?, BUYStatus?) -> Void) {
        // 1. Create the checkout
        let cart = getCartWithProducts(products)
        let checkout = BUYCheckout(cart: cart)
        checkout.reservationTime = 0
        
        // 2. Add the shipping address, billing address, and email to the checkout
        checkout.shippingAddress = getBuyAddress(shippingAddress)
        checkout.billingAddress = getBuyAddressFromPayment(payment)
        
        checkout!.email = email
        
        if discountCode != nil {
            checkout.discount = BUYDiscount(code: discountCode)
        }
        
        // 3. Create the checkout with the shipping rate
        client.createCheckout(checkout, completion: { (createdCheckout, error) -> Void in
            if error == nil {
                // 4. Add shipping rate to the checkout
                self.retrieveRates(createdCheckout, callback: { (ratesCheckout, rates, error) -> Void in
                    createdCheckout.shippingRate = rates!.filter{ (rate) -> Bool in
                        rate.shippingRateIdentifier == shippingRate
                        }.first
                    // 5. Update the checkout
                    self.client.updateCheckout(createdCheckout, completion: { (updatedCheckout, error) -> Void in
                        if error == nil {
                            // 5. Complete the checkout
                            self.client.completeCheckout(updatedCheckout, withApplePayToken: payment.token, completion: { (completeCheckout, error) -> Void in
                                if error == nil {
                                    self.verifyCheckoutCompletion(completeCheckout, callback: { (status) -> Void in
                                        if status == BUYStatus.Complete {
                                            callback(completeCheckout, nil, status)
                                        } else {
                                            callback(completeCheckout, error, status)
                                        }
                                    })
                                } else {
                                    callback(completeCheckout, error, nil)
                                }
                            })
                        } else {
                            callback(updatedCheckout, error, nil)
                        }
                    })
                })
            } else {
                callback(createdCheckout, error, nil)
            }
        })
    }
    
    func doCreditCardCheckout(products: [PProduct], shippingAddress: PAddress, billingAddress: PAddress, email: String, shippingRate: String, creditCard: BUYCreditCard, discountCode: String?,callback: (BUYCheckout?, NSError?, BUYStatus?) -> Void) {
        // 1. Create the checkout
        let cart = getCartWithProducts(products)
        let checkout = BUYCheckout(cart: cart)
        checkout.reservationTime = 0
        
        // 2. Add the shipping address, billing address, and email to the checkout
        checkout.shippingAddress = getBuyAddress(shippingAddress)
        checkout.billingAddress = getBuyAddress(billingAddress)
        checkout!.email = email
        
        if discountCode != nil {
            checkout.discount = BUYDiscount(code: discountCode)
        }
        
        // 3. Create the checkout with the shipping rate
        client.createCheckout(checkout, completion: { (createdCheckout, error) -> Void in
            if error == nil {
                // 4. Add shipping rate to the checkout
                self.retrieveRates(createdCheckout, callback: { (ratesCheckout, rates, error) -> Void in
                    createdCheckout.shippingRate = rates!.filter{ (rate) -> Bool in
                        rate.shippingRateIdentifier == shippingRate
                    }.first
                    // 5. Update the checkout
                    self.client.updateCheckout(createdCheckout, completion: { (updatedCheckout, error) -> Void in
                        if error == nil {
                            // 5. Associate the credit card with the checkout
                            self.client.storeCreditCard(creditCard, checkout: updatedCheckout, completion: { (creditCardCheckout, paymentSessionId, error) -> Void in
                                if error == nil {
                                    // 6. Complete the checkout
                                    self.client.completeCheckout(creditCardCheckout, completion: { (completeCheckout, error) -> Void in
                                        if error == nil {
                                            self.verifyCheckoutCompletion(completeCheckout, callback: { (status) -> Void in
                                                if status == BUYStatus.Complete {
                                                    callback(completeCheckout, nil, status)
                                                } else {
                                                    callback(completeCheckout, error, status)
                                                }
                                            })
                                        } else {
                                            callback(completeCheckout, error, nil)
                                        }
                                    })
                                } else {
                                    callback(creditCardCheckout, error, nil)
                                }
                            })
                        } else {
                            callback(updatedCheckout, error, nil)
                        }
                    })
                })
            } else {
               callback(createdCheckout, error, nil)
            }
        })
    }
    
    func doFakeCheckout(products: [PProduct], shippingAddress: PAddress, email: String, shippingRate: String, discountCode: String?,callback: (BUYCheckout?, NSError?) -> Void) {
        // 1. Create the checkout
        let cart = getCartWithProducts(products)
        let checkout = BUYCheckout(cart: cart)
        checkout.reservationTime = 0
        
        // 2. Add the shipping address, billing address, and email to the checkout
        checkout.shippingAddress = getBuyAddress(shippingAddress)
        //checkout.billingAddress = getBuyAddress(billingAddress)
        checkout!.email = email
        
        if discountCode != nil {
            checkout.discount = BUYDiscount(code: discountCode)
        }
        
        // 3. Create the checkout with the shipping rate
        client.createCheckout(checkout, completion: { (createdCheckout, error) -> Void in
            if error == nil {
                // 4. Add shipping rate to the checkout
                self.retrieveRates(createdCheckout, callback: { (ratesCheckout, rates, error) -> Void in
                    createdCheckout.shippingRate = rates!.filter{ (rate) -> Bool in
                        rate.shippingRateIdentifier == shippingRate
                        }.first
                    // 5. Update the checkout
                    self.client.updateCheckout(createdCheckout, completion: { (updatedCheckout, error) -> Void in
                        callback(updatedCheckout, error)
                    })
                })
            } else {
                callback(createdCheckout, error)
            }
        })
    }

    
    //IMPORTANT: You are required to poll the status of a checkout until the checkout is complete (either successfull or failed
    private func verifyCheckoutCompletion (checkout:BUYCheckout, callback: (BUYStatus) -> Void) {
        client.getCompletionStatusOfCheckout(checkout) { (buyStatus, error) -> Void in
            if error == nil {
                if (buyStatus == BUYStatus.Complete || buyStatus == BUYStatus.Failed) {
                    callback(buyStatus)
                } else {
                    let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 5 * Int64(NSEC_PER_SEC))
                    dispatch_after(time, dispatch_get_main_queue()) {
                        self.verifyCheckoutCompletion(checkout, callback: callback)
                    }
                }
            }
            else
            {
                callback(buyStatus)
            }
        }
    }
    
    private func getCartWithProducts(products : [PProduct]) -> BUYCart {
        let cart = BUYCart()
        products.forEach({(let product) -> () in
            for _ in 1...product.quantity {
                cart.addVariant(product.variant!)
            }
        })

        return cart;
    }
    
    private func retrieveRates(checkout: BUYCheckout, callback: (BUYCheckout, [BUYShippingRate]?, NSError?) -> Void){
        client.getShippingRatesForCheckout(checkout) { (rates, buyStatus, error) -> Void in
            if error != nil {
                callback(checkout, nil, error)
            }
            else
            {
                if buyStatus == BUYStatus.Processing {
                    let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 5 * Int64(NSEC_PER_SEC))
                    dispatch_after(time, dispatch_get_main_queue()) {
                        self.retrieveRates(checkout, callback: callback)
                    }
                }
                else if buyStatus == BUYStatus.Complete && rates.count == 0 {
                    //Handle shipping not available in this checkout
                    checkout.shippingRate = nil
                    callback(checkout, nil, nil)
                }
                else if ((buyStatus == BUYStatus.Unknown && error == nil) || buyStatus == BUYStatus.Complete) {
                    callback(checkout, rates as? [BUYShippingRate], nil)
                }
            }
        }
    }
    
    private func retrieveProducts(page :UInt, callback: (products: [BUYProductVariant]) -> Void)
    {
        let task = client.getProductsPage(page, completion: { ( productList, currentPage, hasReachedEnd, error:NSError!) -> Void in
            if error == nil {
                //self.filterProducts(productList as? [BUYProduct])
                self.pullOutVariants(productList as? [BUYProduct])
                self.finishedGettingProducts = hasReachedEnd
                if !hasReachedEnd {
                    self.retrieveProducts(page + 1, callback: callback)
                }
                else {
                    callback(products: self.products)
                }
            } else {
                self.finishedGettingProducts = true
                callback(products: [BUYProductVariant]())
            }
        })
        
        task.resume()
    }
    
    private func isValidVariant(variant :BUYProductVariant) -> Bool {
        if variant.title.containsString("%") || !variant.available || !variant.product.available {
            return false
        }
        
        return true
    }
    
    private func pullOutVariants(products: [BUYProduct]?){
        products?.forEach({ (product) -> () in
            product.variants?.forEach({ (variant) -> () in
                if variant.available && isValidVariant(variant) {
                    self.products.append(variant)
                }
            })
        })
    }
    
//    private func filterProducts(products: [BUYProduct]?)
//    {
//        if let mainProducts = products {
//            let staticDataProvider = appDelegate.factory.getSaticDataProvider()
//            let skus = staticDataProvider.getProductSKUs()
//            
//            for mainProduct in mainProducts {
//                if let variants = mainProduct.variants {
//                    for variant in variants {
//                        if variant.available && isValidVariant(variant) && skus.contains(variant.sku) {
//                            self.products.append(variant)
//                        }
//                    }
//                }
//            }
//        }
//    }
}
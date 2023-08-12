//
//  Configuration.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/29/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit
import PassKit

struct Configuration {
    static let SecretKet = "f518753f4447a0954b3da684fca17ef3"
    
//    static let ShopifyShopDomain = "substore-3.myshopify.com"
//    static let ShopifyApiKey = "db51bee7c2dd9f2b4f8bf49cc8cf675f"
//    static let ShopifyChannelId = "41784961"
    
    static let ShopifyShopDomain = "eatmeguiltfree.myshopify.com"
    static let ShopifyApiKey = "fd5a4608ade0562b35d1b4f1e3b7c1eb"
    static let ShopifyChannelId = "30168773"
    
    static let ApiUrl = "https://emgfapi.azurewebsites.net/api"
    static let ApplePayMerchantID = "merchant.EMGFMobile"
    static let ApplePaySupportedNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    
    static let TermsAndConditionsUrl = "http://www.eatmeguiltfree.com/pages/terms-and-conditions"
    
    static let BetaPassword = "betap196"
    static let BetaEmail = "email@beta.com"
    static let BetaPasswordEncrypted = "90d0b93f06ac01f4a5f2d4d4f9bcee69ba887ffcba711e2573806ebd81195958"
    static let BetaVerificationCode = "aB83"
}



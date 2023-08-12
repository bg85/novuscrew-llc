//
//  Factory.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/28/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit

class Factory {
    
    private var _serializer :Serializer? = nil
    private var _coder :Coder? = nil
    private var _localDataProvider :LocalDataProvider? = nil
    private var _apiDataProvider :ApiDataProvider? = nil
    private var _staticDataProvider :StaticDataProvider? = nil
    private var _shipifyDataProvider :ShopifyMSDKProvider? = nil
    private var _applePayProvider :ApplePayProvider? = nil
    private var _shared :Shared? = nil
    
    func getSerializer() -> Serializer {
        if _serializer == nil {
            _serializer = Serializer()
        }
        return _serializer!
    }
    
    func getLocalDataProvider() -> LocalDataProvider {
        if _localDataProvider == nil {
            _localDataProvider = LocalDataProvider(seriaizerInstance: getSerializer())
        }
        return _localDataProvider!
    }
    
    func getApiDataProvider() -> ApiDataProvider {
        if _apiDataProvider == nil {
            _apiDataProvider = ApiDataProvider()
        }
        return _apiDataProvider!
    }
    
    func getShared() -> Shared {
        if _shared == nil {
            _shared = Shared()
        }
        return _shared!
    }
    
    func getCoder() -> Coder {
        if _coder == nil {
            _coder = Coder()
        }
        return _coder!
    }
    
    func getSaticDataProvider() -> StaticDataProvider {
        if _staticDataProvider == nil {
            _staticDataProvider = StaticDataProvider()
        }
        return _staticDataProvider!
    }
    
    func getShopifyDataProvider() -> ShopifyMSDKProvider {
        if _shipifyDataProvider == nil {
            _shipifyDataProvider = ShopifyMSDKProvider()
        }
        return _shipifyDataProvider!
    }
    
    func getApplePayProvider() -> ApplePayProvider {
        if _applePayProvider == nil {
            _applePayProvider = ApplePayProvider()
        }
        return _applePayProvider!
    }
}
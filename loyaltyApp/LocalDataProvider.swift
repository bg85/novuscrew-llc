//
//  LocalDataProvider.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 11/15/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import Foundation
import Buy
import CoreData
import CryptoSwift

class LocalDataProvider {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let serializer : Serializer
    
    init(seriaizerInstance: Serializer) {
        serializer = seriaizerInstance
    }
    
    func getTopOneProfile() -> Profile? {
        let fetchRequest = NSFetchRequest(entityName: "Profile")
        
        if let fetchResults = try! managedObjectContext.executeFetchRequest(fetchRequest) as? [Profile] {
            var profiles = fetchResults
            if profiles.count > 0 {
                return profiles[0];
            }
        }
        
        return nil;
    }
    
    func updateProfile(profile :Profile?, pProfile :PProfile?) -> PProfile {
        
        if let cloudProfile = pProfile {
            let proProfile = (profile == nil ? self.getProfileById(pProfile!.profileId) : profile)
            
            proProfile!.points = cloudProfile.points
            proProfile!.pointsStatus = cloudProfile.pointsStatus
            proProfile!.firstName = (proProfile!.firstName ?? "" == "") ? cloudProfile.firstName : proProfile!.firstName
            proProfile!.lastName = (proProfile!.lastName ?? "" == "") ? cloudProfile.lastName : proProfile!.lastName
            
            if (proProfile!.shippingAddressId ?? "" == "")
                && pProfile!.shippingAddressId ?? "" != "" {
                    updateAddress(pProfile!.shippingAddressId!, cloudAddress: pProfile!.shippingAddress!)
            }
        }
        
        appDelegate.saveContext()
        
        return PProfile(coreDataProfile: profile)
    }
    
    func getProfile(email: String?) -> Profile? {
        if email ?? "" != "" {
            let fetchRequest = NSFetchRequest(entityName: "Profile")
            fetchRequest.predicate = NSPredicate(format: "email = %@ ", email!.lowercaseString)
            
            if let fetchResults = try! managedObjectContext.executeFetchRequest(fetchRequest) as? [Profile] {
                let profiles = fetchResults
                if profiles.count > 0 {
                    return profiles[0];
                }
            }
        }
        
        return nil;
    }
    
    func setUsingTouchId(profileId :String){
        if let profile = getProfileById(profileId) {
            profile.usingTouchId = true
            
            appDelegate.saveContext()
        }
    }
    
    func createProfile(profile :PProfile) -> PProfile {
               
        let newProfile = NSEntityDescription.insertNewObjectForEntityForName("Profile", inManagedObjectContext: managedObjectContext) as! Profile
        
        newProfile.profileId = NSUUID().UUIDString
        newProfile.email = profile.email?.lowercaseString
        newProfile.password = profile.password
        newProfile.firstName = profile.firstName
        newProfile.lastName = profile.lastName
        newProfile.points = profile.points
        newProfile.pointsStatus = profile.pointsStatus
        newProfile.shippingRateId = profile.shippingRateId
        newProfile.shares = 0
        newProfile.visits = 1
        newProfile.usingApplePay = false
        newProfile.usingTouchId = false
        newProfile.usingLazyButton = false
        newProfile.shippingAddressId = profile.shippingAddressId
        newProfile.shippingRateTitle = profile.shippingRateTitle
        newProfile.shippingRatePrice = profile.shippingRatePrice ?? 0.0
        
        if profile.shippingAddressId != nil && !profile.shippingAddressId!.isEmpty && profile.shippingAddress != nil {
            createAddress(profile.shippingAddress!, addressId: profile.shippingAddressId!)
        }
        
        appDelegate.saveContext()
        
        return PProfile(coreDataProfile: newProfile)
    }
     
    
    func getAddress(addressId: String?) -> Address? {
        if addressId != nil && !addressId!.isEmpty {
            let fetchRequest = NSFetchRequest(entityName: "Address")
            fetchRequest.predicate = NSPredicate(format: "addressId = %@ ", addressId!)
            
            if let fetchResults = try! managedObjectContext.executeFetchRequest(fetchRequest) as? [Address] {
                let addresses = fetchResults
                if addresses.count > 0 {
                    return addresses[0];
                }
            }
        }
        
        return nil;
    }
    
    func addShare(profileId :String){
        if let profile = getProfileById(profileId) {
            profile.shares += 1
            
            appDelegate.saveContext()
        }
    }
    
    func updatePassword(profileId :String, password :String) -> String? {
        if let profile = getProfileById(profileId) {
            profile.password = hash(password)
            
            appDelegate.saveContext()
            
            return profile.password
        }
        
        return nil
    }
    
    func getProducts(profileId :String) -> [PProduct]?{
        if let fetchResults = self.getProductsFromDB(profileId) {
            let products = fetchResults.reverse()
            
            return products.map({ (dbProduct) -> PProduct in
                let product = PProduct(profileId: dbProduct.profileId, productTitle: dbProduct.productTitle!, productId: dbProduct.productId, title: dbProduct.title!, quantity: dbProduct.quantity)
                return product
            })
        }
        return nil;
    }
    
    func saveLazyButtonConfiguration(products: [PProduct], usingApplePay: Bool, shippingRate: BUYShippingRate, shippingAddress: PAddress?, taxes: Double, profileId: String) {
        
        var hasChanged = updateProfile(usingApplePay, shippingRate: shippingRate, shippingAddress: shippingAddress, taxes:taxes, profileId: profileId)
        hasChanged = saveProducts(products, profileId: profileId) || hasChanged
        
        if hasChanged {
            appDelegate.saveContext()
        }
    }
    
    func getOrders(profileId :String) -> [Order]?{
        let fetchRequest = NSFetchRequest(entityName: "Order")
        fetchRequest.predicate = NSPredicate(format: "profileId = %@", profileId)
        
        return try! managedObjectContext.executeFetchRequest(fetchRequest) as? [Order]
    }
    
    func hash(text :String) -> String {
        return text.sha256()
    }
    
    func createOrder(profileId: String, merchadiseTotal: Double, shippingCost: Double, taxes: Double, rewardId: String?, orderTotal: Double) {
        
        let newOrder = NSEntityDescription.insertNewObjectForEntityForName("Order", inManagedObjectContext: managedObjectContext) as! Order
        
        newOrder.profileId = profileId
        newOrder.date = getTodaysDate()
        newOrder.orderId = NSUUID().UUIDString
        newOrder.merchandiseTotal = merchadiseTotal
        newOrder.shippingCost = shippingCost
        newOrder.taxes = taxes
        newOrder.rewardId = rewardId
        newOrder.orderTotal = orderTotal
        
        appDelegate.saveContext()
    }
    
    private func getTodaysDate() -> String {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        return formatter.stringFromDate(date)
    }
    
    private func getProfile(email: String, password: String) -> Profile? {
        let fetchRequest = NSFetchRequest(entityName: "Profile")
        fetchRequest.predicate = NSPredicate(format: "email = %@ and password = %@", email.lowercaseString, password)
        
        if let fetchResults = try! managedObjectContext.executeFetchRequest(fetchRequest) as? [Profile] {
            var profiles = fetchResults
            if profiles.count > 0 {
                return profiles[0];
            }
        }
        
        return nil
    }
    
    private func getProfileById(profileId: String?) -> Profile? {
        if profileId != nil && !profileId!.isEmpty {
            let fetchRequest = NSFetchRequest(entityName: "Profile")
            fetchRequest.predicate = NSPredicate(format: "profileId = %@ ", profileId!)
            
            if let fetchResults = try! managedObjectContext.executeFetchRequest(fetchRequest) as? [Profile] {
                let profiles = fetchResults
                if profiles.count > 0 {
                    return profiles[0];
                }
            }
        }
        
        return nil;
    }
    
    private func getProductsFromDB(profileId :String) -> [SProduct]? {
        let fetchRequest = NSFetchRequest(entityName: "SProduct")
        fetchRequest.predicate = NSPredicate(format: "profileId = %@", profileId)
        
        return try! managedObjectContext.executeFetchRequest(fetchRequest) as? [SProduct]
    }
    
    private func updateProfile(usingApplePay: Bool, shippingRate:BUYShippingRate, shippingAddress: PAddress?, taxes: Double, profileId :String) -> Bool{
        var hasChanged = false
        
        if let profile = getProfileById(profileId) {
            if profile.usingApplePay != usingApplePay {
                profile.usingApplePay = usingApplePay
                hasChanged = true
            }
            if !profile.usingLazyButton {
                profile.usingLazyButton = true
                hasChanged = true
            }
            if profile.shippingRateId != shippingRate.shippingRateIdentifier{
                profile.shippingRateId = shippingRate.shippingRateIdentifier
                hasChanged = true
            }
            if profile.shippingRateTitle != shippingRate.title {
                profile.shippingRateTitle = shippingRate.title
                hasChanged = true
            }
            if profile.shippingRatePrice != shippingRate.price {
                profile.shippingRatePrice = shippingRate.price.doubleValue
                hasChanged = true
            }
            if shippingAddress != nil {
                profile.shippingAddressId = NSUUID().UUIDString
                hasChanged = updateAddress(profile.shippingAddressId! , cloudAddress: shippingAddress!)
            }
            if profile.taxes != taxes {
                profile.taxes = taxes
                hasChanged = true
            }
            
            appDelegate.profile = PProfile(coreDataProfile: profile)
        }
        
        return hasChanged
    }
    
    private func updateAddress(addressId :String, cloudAddress :PAddress) -> Bool {
        var hasChanged = false
        
        if let address = getAddress(addressId) {
            if address.firstName != cloudAddress.firstName {
                address.firstName = cloudAddress.firstName
                hasChanged = true
            }
            if address.lastName != cloudAddress.lastName {
                address.lastName = cloudAddress.lastName
                hasChanged = true
            }
            if address.address1 != cloudAddress.address1 {
                address.address1 = cloudAddress.address1
                hasChanged = true
            }
            if address.address2 != cloudAddress.address2 {
                address.address2 = cloudAddress.address2
                hasChanged = true
            }
            if address.city != cloudAddress.city {
                address.city = cloudAddress.city
                hasChanged = true
            }
            if address.state != cloudAddress.state {
                address.state = cloudAddress.state
                hasChanged = true
            }
            if address.zip != cloudAddress.zip {
                address.zip = cloudAddress.zip
                hasChanged = true
            }
            if address.country != cloudAddress.country {
                address.country = cloudAddress.country
                hasChanged = true
            }
        } else {
            createAddress(cloudAddress, addressId: addressId)
            hasChanged = true
        }
        
        return hasChanged
    }
    
    private func createAddress(shippingAddress :PAddress, addressId: String) {
            
            let newAddress = NSEntityDescription.insertNewObjectForEntityForName("Address", inManagedObjectContext: managedObjectContext) as! Address
            
            newAddress.addressId = addressId
            newAddress.firstName = shippingAddress.firstName
            newAddress.lastName = shippingAddress.lastName
            newAddress.address1 = shippingAddress.address1
            newAddress.address2 = shippingAddress.address2
            newAddress.city = shippingAddress.city
            newAddress.state = shippingAddress.state
            newAddress.zip = shippingAddress.zip
            newAddress.country = shippingAddress.country
    }
    
    private func saveProducts(products :[PProduct], profileId :String) -> Bool {
        
        let result = cleanOutExistingProducts(products, profileId: profileId)
        var hasChanged = result.1
        if result.0.count > 0 {
            createNewProducts(result.0, profileId: profileId)
            hasChanged = true
        }
        
        return hasChanged
    }
    
    private func cleanOutExistingProducts(newProducts :[PProduct], profileId :String) -> ([PProduct], Bool){
        var hasChanged = false
        var products = newProducts
        
        if let existingProducts = getProductsFromDB(profileId) {
            for existingProduct in existingProducts {
                if let newMatchingProductIndex = getMatchingProductIndex(existingProduct, products: products) {
                    hasChanged = updateProduct(existingProduct, newProduct: products[newMatchingProductIndex]) || hasChanged
                    products.removeAtIndex(newMatchingProductIndex)
                }
            }
        }
        
        return (products, hasChanged)
    }
    
    private func createNewProducts(newProducts :[PProduct], profileId :String){
        for newProduct in newProducts {
            createProduct(newProduct, profileId: profileId)
        }
    }
    
    private func getMatchingProductIndex(product :SProduct, products :[PProduct]) -> Int? {
        for index in 0 ..< products.count {
            let newProduct = products[index]
            if product.productId == newProduct.productId {
                    return index
            }
        }
        
        return nil
    }
    
    private func updateProduct(existingProduct :SProduct, newProduct :PProduct) -> Bool{
        var hasChanged = false
        
        if existingProduct.productTitle != newProduct.productTitle {
            existingProduct.productTitle = newProduct.productTitle
            hasChanged = true
        }
        if existingProduct.quantity != newProduct.quantity {
            existingProduct.quantity = newProduct.quantity
            hasChanged = true
        }
        if existingProduct.title != newProduct.title {
            existingProduct.title = newProduct.title
            hasChanged = true
        }
        
        return hasChanged
    }
    
    private func createProduct(product :PProduct, profileId :String) {
        
        let newProduct = NSEntityDescription.insertNewObjectForEntityForName("SProduct", inManagedObjectContext: managedObjectContext) as! SProduct
        newProduct.profileId = profileId
        newProduct.productTitle = product.productTitle
        newProduct.productId = product.productId!
        newProduct.quantity = product.quantity
        newProduct.title = product.title
    } 
}
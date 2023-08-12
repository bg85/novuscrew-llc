//
//  Coder.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 11/18/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import Foundation

struct RegistrationCode {
    var code : String? = nil
    var creationDate: NSDate? = nil
}

class Coder {
    func generateCode() -> RegistrationCode{
        var code = RegistrationCode()
        code.code = randomStringWithLength(randomInt(min: 3, max: 6)) as String
        code.creationDate = NSDate()
        
        return code
    }
    
    func isValidCode(registrationCode: RegistrationCode, code: String) -> Bool{
        let elapsedTime = NSDate().timeIntervalSinceDate(registrationCode.creationDate!)

        return registrationCode.code! == code && elapsedTime < 360
    }
    
    private func randomInt(min min: Int, max: Int) -> Int {
        if max < min { return min }
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }
    
    private func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0 ..< len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
}

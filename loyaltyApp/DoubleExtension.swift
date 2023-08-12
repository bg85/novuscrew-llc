//
//  DoubleExtension.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 2/8/16.
//  Copyright © 2016 Barbara Gonzalez. All rights reserved.
//

import Foundation

extension Double {
    func string(fractionDigits:Int) -> String {
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.stringFromNumber(self) ?? "\(self)"
    }
}

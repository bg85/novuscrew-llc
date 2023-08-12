//
//  Rewards.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/3/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import Foundation

class Reward {
    var image = ""
    var title = ""
    var description = ""
    var points = 0
    var rewardId :String? = nil
    var skus :[String]? = nil
    var deduction :Double = 0
    
    init(id :String, image :String, title :String, description :String, points :Int, skus :[String]?, deduction :Double) {
        self.rewardId = id
        self.image = image
        self.title = title
        self.description = description
        self.points = points
        self.skus = skus
        self.deduction = deduction
    }
}
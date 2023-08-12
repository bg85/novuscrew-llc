//
//  Status.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/3/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import Foundation

class Status {
    var image = ""
    var title = ""
    var description = ""
    var points = 0
    
    init(image : String, title : String, description : String, points : Int) {
        self.image = image
        self.title = title
        self.description = description
        self.points = points
    }
}
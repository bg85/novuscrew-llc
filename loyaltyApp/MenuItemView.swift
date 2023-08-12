//
//  MenuItemView.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 2/13/16.
//  Copyright © 2016 Barbara Gonzalez. All rights reserved.
//

import UIKit

@IBDesignable
class MenuItemView: UIView {
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.CGColor
        }
    }
}
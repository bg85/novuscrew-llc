//
//  VariantsCollectionViewCell.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 1/28/16.
//  Copyright © 2016 Barbara Gonzalez. All rights reserved.
//

import UIKit

class VariantsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quantityTextBox: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    
    var controller :VariantViewController? = nil
    var index = -1
    var quantity = 0
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
   
    @IBAction func removeVariant(sender: UIButton) {
        controller!.decreaseVariantCount(index)
        if quantity > 0 {
            quantity -= 1
            quantityTextBox.text = "\(quantity)"
        }
    }
    
    @IBAction func addVariant(sender: AnyObject) {
        controller!.increaseVariantCount(index)
        quantity += 1
        quantityTextBox.text = "\(quantity)"
    }
    
    func draw(title :String, qty :Int32, price: Double, index: Int){
        let shared = appDelegate.factory.getShared()
        
        self.index = index
        self.quantity = Int(qty)
        titleLabel.text = title
        quantityTextBox.text = "\(qty)"
        priceLabel.text = "$\(shared.formatNumber(price))"
    }
}

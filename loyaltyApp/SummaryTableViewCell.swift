//
//  SummaryTableViewCell.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 1/30/16.
//  Copyright © 2016 Barbara Gonzalez. All rights reserved.
//

import UIKit

class SummaeyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productQuantityLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func draw(product: PProduct) {
        let shared = appDelegate.factory.getShared()
        
        productImageView.downloadedFrom(link: product.variant!.product.images[0].src, contentMode: UIViewContentMode.ScaleAspectFit, image: nil) { (image) -> Void in
            //do nothing
        }
        productQuantityLabel.text = "qty \(product.quantity)"
        productPriceLabel.text = "$\(shared.formatNumber(product.variant!.price.doubleValue))"
    }
}

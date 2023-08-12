//
//  ConfirmationViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 2/19/16.
//  Copyright © 2016 Barbara Gonzalez. All rights reserved.
//

import UIKit
import Buy

class ConfirmationViewController: UIViewController {

    @IBOutlet weak var productCostLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var discountHeaderLabel: UILabel!
    
    var checkout :BUYCheckout? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuClick(sender: UIButton) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let shared = appDelegate.factory.getShared()
        shared.showMenu(MenuItems.QuickBuy, viewController: self)
    }
    
    private func initialize() {
        productCostLabel.text = checkout?.subtotalPrice.doubleValue.string(2)
        taxLabel.text = checkout!.totalTax.doubleValue.string(2)
        shippingLabel.text = checkout?.shippingRate.price.doubleValue.string(2)
        if let discount = checkout?.discount {
            discountLabel.hidden = false
            discountHeaderLabel.hidden = false
            discountLabel.text = discount.amount.doubleValue.string(2)
        } else {
            discountLabel.hidden = true
            discountHeaderLabel.hidden = true
        }
        totalLabel.text = checkout?.totalPrice.doubleValue.string(2)
    }
}

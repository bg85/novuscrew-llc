//
//  PaymentMethodViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/18/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit
import Buy

class PaymentMethodViewController: UIViewController{
    
    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var creditCardButton: UIButton!
    @IBOutlet weak var creditCardView: MenuItemView!
    @IBOutlet weak var applePayView: MenuItemView!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var shippingAddress :PAddress? = nil
    var products :[PProduct]? = nil
    var usingApplePay = true
    var totalSelectedProducts = 0
    var totalCostProducts = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "lazyButtonReviewSegue" {
            let destinationController = segue.destinationViewController as! LazyButtonReviewViewController
            destinationController.products = products
            destinationController.shippingAddress = shippingAddress!
            destinationController.usingApplePay = usingApplePay
            destinationController.totalCostProducts = totalCostProducts
            destinationController.totalSelectedProducts = totalSelectedProducts
        }
    }
    
    @IBAction func applePayClick(sender: UIButton) {
        usingApplePay = true
        let shared = appDelegate.factory.getShared()
        creditCardView.backgroundColor = shared.getBackgroundGrayColor()
        applePayView.backgroundColor = shared.getGreenColor()
    }
    
    
    @IBAction func creditCardClick(sender: UIButton) {
        usingApplePay = false
        let shared = appDelegate.factory.getShared()
        creditCardView.backgroundColor = shared.getGreenColor()
        applePayView.backgroundColor = shared.getBackgroundGrayColor()
    }
    
    private func initialize() {
        if appDelegate.profile!.usingLazyButton {
            usingApplePay = appDelegate.profile!.usingApplePay
            if !usingApplePay {
                creditCardClick(creditCardButton)
            }
        } else {
            applePayClick(applePayButton)
        }
        
        let shared = appDelegate.factory.getShared()
        totalCostLabel.text = "$\(shared.formatNumber(totalCostProducts))"
        totalCountLabel.text = "\(totalSelectedProducts)"
    }
    
    @IBAction func backToPaymentViewController(segue:UIStoryboardSegue) {
    }
}

    //
//  LazyButtonViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/5/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit
import Buy
import PassKit
import SafariServices

class LazyButtonViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    
    @IBOutlet weak var welcomeImage: UIImageView!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var availableRewardsLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var shippingCostLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var productsTotalLabel: UILabel!
    @IBOutlet weak var availablePointsLabel: UILabel!
    @IBOutlet weak var selectedRewardLabel: UILabel!
    @IBOutlet weak var paymentImageButton: UIButton!
    @IBOutlet weak var discountLabel: UILabel!
    
    var rewardToApply :Reward? = nil
    var newTaxes = 0.0
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var products :[PProduct]? = nil
    var allVariants :[BUYProductVariant]? = nil
    var checkout :BUYCheckout? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if appDelegate.profile != nil && allVariants == nil {
            loadProducts { () -> Void in
                self.initialize()
            }
        } else {
            initialize()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rewardsClick(sender: UIButton) {
        self.performSegueWithIdentifier("rewardsSegue", sender: self)
    }
    
    @IBAction func editButtonClick(sender: UIButton) {
        self.performSegueWithIdentifier("lazyButtonSetUpSegue", sender: self)
    }
    
    @IBAction func orderNowButtonClick(sender: UIButton) {
        if appDelegate.profile!.usingApplePay
            && PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(Configuration.ApplePaySupportedNetworks) {
                    startApplePayCheckout()
        } else {
            self.performSegueWithIdentifier("creditCardSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "creditCardSegue" {
            let destinationViewController = segue.destinationViewController as! CreditCardViewController
            destinationViewController.products = products
            destinationViewController.reward = rewardToApply
        } else if segue.identifier == "lazyButtonSetUpSegue" {
            let destinationViewController = segue.destinationViewController as! LazyButtonWelcomeViewController
            destinationViewController.allVariants = allVariants
            destinationViewController.products = products
        } else if segue.identifier == "applePaySuccessSegue" {
            let destinationViewController = segue.destinationViewController as! ConfirmationViewController
            destinationViewController.checkout = checkout
        } else if segue.identifier == "rewardsSegue" {
            let destinationViewController = segue.destinationViewController as! LazyRewardsViewController
            destinationViewController.products = products
            destinationViewController.rewardToApply = rewardToApply
        }
    }
    
    //Apple Pay
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {
        
        let shared = self.appDelegate.factory.getShared()
        
        if isValid(payment.billingContact!) {
            let profile = appDelegate.profile!
            let shopifyDataProvider = appDelegate.factory.getShopifyDataProvider()
            shopifyDataProvider.doApplePayCheckout(products!, shippingAddress: profile.shippingAddress!, email: profile.email!, shippingRate: profile.shippingRateId!, discountCode: rewardToApply?.rewardId, payment: payment) { (checkout, error, status) -> Void in
                controller.dismissViewControllerAnimated(true, completion: nil)
                if error != nil || status != BUYStatus.Complete {
                    let shared = self.appDelegate.factory.getShared()
                    shared.showAlert("Error processing payment", message: "There was an error processing your payment, your order will not be placced.", viewController: self, handler: nil)
                } else
                {
                    self.checkout = checkout
                    self.deductRewardPoints()
                    self.saveOrder(checkout!)
                    self.performSegueWithIdentifier("applePaySuccessSegue", sender: self)
                }
            }
        } else {
            controller.dismissViewControllerAnimated(true, completion: nil)
            shared.showAlert("Invalid Billing Information", message: "Your order failed. Please correct the biling information and try again.", viewController: self, handler: nil)
        }
    }
    
    private func saveOrder(checkout: BUYCheckout) {
        let localDataProvider = appDelegate.factory.getLocalDataProvider()
        localDataProvider.createOrder(appDelegate.profile!.profileId!, merchadiseTotal: checkout.subtotalPrice.doubleValue, shippingCost: appDelegate.profile!.shippingRatePrice!, taxes: checkout.totalTax.doubleValue, rewardId: rewardToApply?.rewardId, orderTotal: checkout.totalPrice.doubleValue)
    }
    
    private func isValid(contact: PKContact) -> Bool {
        return (contact.name?.givenName ?? "") != ""
        && (contact.name?.familyName ?? "") != ""
        && (contact.postalAddress?.street ?? "") != ""
        && (contact.postalAddress?.city ?? "") != ""
        && (contact.postalAddress?.state ?? "") != ""
        && (contact.postalAddress?.postalCode ?? "") != ""
        && (contact.postalAddress?.country ?? "") != ""
    }
    
    private func deductRewardPoints() {
        if let usedReward = rewardToApply {
            let apiDataProvider = appDelegate.factory.getApiDataProvider()
            apiDataProvider.deductPoints(appDelegate.profile!.email!, points: usedReward.points)
            appDelegate.profile!.points -= usedReward.points
            appDelegate.profile!.pointsStatus += usedReward.points
        }
    }
        
    private func startApplePayCheckout() {
        let applePayDataProvider = appDelegate.factory.getApplePayProvider()
        let profile = appDelegate.profile!
        let taxes = rewardToApply != nil ? newTaxes : appDelegate.profile!.taxes
        if let applePayController = applePayDataProvider.getApplePayViewController(products!, shippingMethod: profile.shippingRateTitle!, shippingCost: profile.shippingRatePrice!, taxes: taxes, email: profile.email!, reward:rewardToApply) {
            applePayController.delegate = self
            self.presentViewController(applePayController, animated: true, completion: nil)
        }
    }
    
    private func loadProducts(callback: () -> Void) {
        let shared = appDelegate.factory.getShared()
        shared.showBusy(self.view)
        
        let localDataProvider = appDelegate.factory.getLocalDataProvider()
        products = localDataProvider.getProducts(appDelegate.profile!.profileId!)
        
        let shopifyDataProvider = appDelegate.factory.getShopifyDataProvider()
        shopifyDataProvider.getProducts { (variants) -> Void in
            self.allVariants = variants
            if self.products?.count ?? 0 > 0 {
                self.products!.forEach({ (product) -> () in
                    product.variant = variants.filter({ (variant) -> Bool in
                        variant.identifier.longLongValue == product.productId
                    }).first
                })
            }
            
            shared.hideBusy()
            callback()
        }
    }
    
    private func initialize(){
        if self.appDelegate.profile!.usingLazyButton {
            let shared = appDelegate.factory.getShared()
            
            paymentImageButton.setBackgroundImage(UIImage(named: self.appDelegate.profile!.usingApplePay
                ? "ApplePayBTN_62pt__whiteLine_logo_.png" : "creditcard.png"), forState: .Normal)
            self.welcomeImage.hidden = true
            
            availablePointsLabel.text = "\(appDelegate.profile!.points)"
            availableRewardsLabel.text = "\(availableewardsCount())"
            
            let merchandiseTotal = getMerchandiseTotal()
            productsTotalLabel.text = "$\(shared.formatNumber(merchandiseTotal))"
            shippingCostLabel.text = "$\(shared.formatNumber(appDelegate.profile!.shippingRatePrice!))"
            productCountLabel.text = "\(getMerchandiseCount())"
            
            if rewardToApply == nil {
                taxLabel.text = "$\(shared.formatNumber(appDelegate.profile!.taxes))"
                totalCostLabel.text = "$\(shared.formatNumber(merchandiseTotal + appDelegate.profile!.taxes + appDelegate.profile!.shippingRatePrice!))"
                totalLabel.text = totalCostLabel.text
    
                discountLabel.hidden = true
                selectedRewardLabel.hidden = true
            } else {
                getDiscountedTotals()
            }
        }
        else {
            self.performSegueWithIdentifier("lazyButtonSetUpSegue", sender: self)
        }
    }
    
    private func getDiscountedTotals() {

        let profile = appDelegate.profile!
        let shopifyDataProvider = appDelegate.factory.getShopifyDataProvider()
        let shared = self.appDelegate.factory.getShared()
        shared.showBusy(self.view)
        
        shopifyDataProvider.doFakeCheckout(products!, shippingAddress: profile.shippingAddress!, email: profile.email!, shippingRate: profile.shippingRateId!, discountCode: rewardToApply?.rewardId) { (checkout, error) -> Void in
            shared.hideBusy()
            if error != nil {
                shared.showAlert("Error adding discount", message: "There was an error adding your dicount, your order will not be updated.", viewController: self, handler: nil)
            } else
            {
                self.newTaxes = checkout!.totalTax.doubleValue
                self.taxLabel.text = "$\(shared.formatNumber(self.newTaxes))"
                
                self.rewardToApply!.deduction = checkout!.discount.amount.doubleValue
                self.selectedRewardLabel.text = "-$\(shared.formatNumber(self.rewardToApply!.deduction))"
                
                self.totalCostLabel.text = "$\(shared.formatNumber(checkout!.totalPrice.doubleValue))"
                self.totalLabel.text = self.totalCostLabel.text
                
                self.discountLabel.hidden = false
                self.selectedRewardLabel.hidden = false
            }
        }
    }
    
    private func getMerchandiseTotal() -> Double {
        if products == nil { return 0.0 }
        return products!.reduce(0.0, combine: {$0 + ($1.variant!.price.doubleValue * Double($1.quantity))})
    }
    
    private func getMerchandiseCount() -> Int {
        if products == nil { return 0 }
        return products!.reduce(0, combine: {$0 + Int($1.quantity)})
    }
    
    private func availableewardsCount() -> Int {
        let staticDataProvider = appDelegate.factory.getSaticDataProvider()
        
        let rewards = staticDataProvider.getRewards()
        let points = Int(appDelegate.profile!.points)
        return rewards.filter { (reward) -> Bool in
            reward.points <= points
        }.count
    }

    @IBAction func backToLazyButtonViewController(segue:UIStoryboardSegue) {
    }
}


//
//  LazyButtonReviewViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/9/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit
import Buy

class LazyButtonReviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource , UIPickerViewDelegate {

    @IBOutlet weak var shippingMethodTextBox: UITextField!
    @IBOutlet weak var taxesLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var shippingCostLabel: UILabel!
    @IBOutlet weak var totalProductsLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var shippingAddress = PAddress()
    var products : [PProduct]? = nil
    var usingApplePay = true
    var shippingRate :BUYShippingRate? = nil
    var shippingRates :[BUYShippingRate]? = nil
    var shippingRatePickerView = UIPickerView()
    var checkout :BUYCheckout? = nil
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
        if segue.identifier == "reviewBackToLazyButton" {
            let destinationViewController = segue.destinationViewController as! LazyButtonViewController
            destinationViewController.products = products
        }
    }
    
    @IBAction func saveClick(sender: UIButton) {
        if shippingRate == nil {
            let shared = appDelegate.factory.getShared()
            shared.showAlert("Invalid Shipping Rate", message: "A Shipping Rate is Required", viewController: self, handler: nil)
        } else {
            saveLazyButtonConfiguration()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (products?.count ?? 0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reviewCell", forIndexPath: indexPath) as! SummaeyTableViewCell
        
        cell.draw(products![indexPath.row] )
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        shippingMethodTextBox.resignFirstResponder()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return shippingRates?.count ?? 0
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(shippingRates![row].title) - $\(shippingRates![row].price.doubleValue)"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if shippingRates != nil && shippingRates!.count > 0 {
            let shippingRate = shippingRates![row]
            updateSelectedShippingRate(shippingRate)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool    {
        shippingMethodTextBox.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = event?.allTouches()?.first {
            if shippingMethodTextBox.isFirstResponder() && touch.view != shippingMethodTextBox {
                shippingMethodTextBox.resignFirstResponder()
            }
            super.touchesBegan(touches, withEvent: event)
        }
    }
    
    private func initialize(){
        let shared = appDelegate.factory.getShared()
        
        shippingRatePickerView.delegate = self
        shippingRatePickerView.dataSource = self
        shippingMethodTextBox.inputView = self.shippingRatePickerView
        
        totalCostLabel.text = "$\(shared.formatNumber(totalCostProducts))"
        totalProductsLabel.text = "\(totalSelectedProducts)"
        
        shared.showBusy(self.view)
        
        retrieveShippingRates()
    }
    
    private func retrieveShippingRates(){
        let shopifyDataProvider = appDelegate.factory.getShopifyDataProvider()
        let shared = appDelegate.factory.getShared()
        shopifyDataProvider.retrieveShippingRates(products!, shippingAddress: shippingAddress) { (checkout, rates, error) -> Void in
            
            shared.hideBusy()
            
            if error != nil  {
                self.checkout = nil
                shared.showAlert("Error", message: "Sorry an error has occurred, try again later", viewController: self, handler: nil)
            } else if rates == nil {
                self.checkout = nil
                shared.showAlert("Not Available Rates", message: "We are very sorry but currently we do not ship to this address.", viewController: self, handler: nil)
            } else {
                self.checkout = checkout
                self.updateShippingRates(checkout, rates: rates)
            }
        }
    }
    
    private func updateSelectedShippingRate(shippingRate: BUYShippingRate) {
        let shopifyDataProvider = appDelegate.factory.getShopifyDataProvider()
        let shared = appDelegate.factory.getShared()
        
        self.shippingRate = shippingRate
        self.checkout!.shippingRate = shippingRate
        shopifyDataProvider.updateCheckout(checkout!) { (updatedCheckout, error) -> Void in
            if error == nil {
                self.checkout = updatedCheckout
                self.shippingMethodTextBox.text = shippingRate.title
                self.shippingMethodTextBox.resignFirstResponder()
                self.shippingCostLabel.text = "$\(shared.formatNumber(shippingRate.price.doubleValue))"
                self.taxesLabel.text = "$\(shared.formatNumber(self.checkout!.totalTax.doubleValue))"
                self.totalLabel.text = "$\(shared.formatNumber(self.checkout!.totalPrice.doubleValue))"
            } else {
                let shared = self.appDelegate.factory.getShared()
                shared.showAlert("Error", message: "Sorry, an error has occurred. Try again later", viewController: self, handler: nil)
            }
        }
    }
    
    private func updateShippingRates(checkout: BUYCheckout, rates: [BUYShippingRate]?){
        self.shippingRates = rates
        
        if self.shippingRates?.count > 0 {
            updateSelectedShippingRate(self.shippingRates![0])
        }
    }
    
    func saveLazyButtonConfiguration(){
        let localDataProvider = appDelegate.factory.getLocalDataProvider()
        localDataProvider.saveLazyButtonConfiguration(products!, usingApplePay: usingApplePay, shippingRate: shippingRate!, shippingAddress: shippingAddress, taxes: checkout?.totalTax.doubleValue ?? 0.0, profileId: appDelegate.profile!.profileId!)
        self.performSegueWithIdentifier("reviewBackToLazyButton", sender: self)
    }
}

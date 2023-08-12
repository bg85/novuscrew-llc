//
//  CreditCardViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 1/30/16.
//  Copyright © 2016 Barbara Gonzalez. All rights reserved.
//

import UIKit
import Buy

class CreditCardViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
  
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var citiTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var cardHolderNameTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var expirationYearTextField: UITextField!
    @IBOutlet weak var expirationMonthTextField: UITextField!
    @IBOutlet weak var useShippingSwitch: UISwitch!
    @IBOutlet weak var creditCardBackground: UILabel!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var creditCard :PCreditCard? = nil
    var products :[PProduct]? = nil
    var reward: Reward? = nil
    var expMonthPicker = UIPickerView()
    var expYearPicker = UIPickerView()
    var months :[String]? = nil
    var years :[Int]? = nil
    var expMonth = "00"
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
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (pickerView.tag == 0 ? months?.count : years?.count)!
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView.tag == 0 ? months![row] : "\(years![row])"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            expirationMonthTextField.text = months![row]
            expMonth = String(format: "%02d", row + 1)
            expirationMonthTextField.resignFirstResponder()
        } else {
            expirationYearTextField.text = "\(years![row])"
            expirationYearTextField.resignFirstResponder()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "orderSuccessSegue" {
            let destinationViewController = segue.destinationViewController as! ConfirmationViewController
            destinationViewController.checkout = checkout
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = event?.allTouches()?.first {
            if expirationMonthTextField.isFirstResponder() && touch.view != expirationMonthTextField {
                expirationMonthTextField.resignFirstResponder()
            } else if expirationYearTextField.isFirstResponder() && touch.view != expirationYearTextField {
                expirationYearTextField.resignFirstResponder()
            } else {
                self.view.endEditing(true)
            }
            super.touchesBegan(touches, withEvent: event)
        }
    }
       
    @IBAction func placeOrderClick(sender: UIButton) {
        loadCreditCard()
        if creditCard!.isValid() {
            startCheckout()
        } else {
            let shared = appDelegate.factory.getShared()
            shared.showAlert("Error", message: "Invalid Credit Card Information", viewController: self, handler: nil)
        }
    }
    
    @IBAction func useShippingChanged(sender: UISwitch) {
        if sender.on {
            populateShipping()
        } else {
            clean()
        }
    }
    
    @IBAction func menuClick(sender: UIButton) {
        let shared = appDelegate.factory.getShared()
        shared.showMenu(MenuItems.QuickBuy, viewController: self)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool    {
        textField.resignFirstResponder()
        return true;
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var maxLength = 500
        switch textField.placeholder! {
            case "exp month" : maxLength = 2
            case "exp year": maxLength = 4
            case "card number": maxLength = 16
            case "cvv": maxLength = 4
            default: 500
        }
        return textField.text!.characters.count + string.characters.count > maxLength ? false : true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        creditCardBackground.hidden = false
        animateViewMoving(true, moveValue: 100)
    }
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 100)
        creditCardBackground.hidden = true
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    private func initialize() {
        creditCardBackground.hidden = true
        firstNameTextField.text = appDelegate.profile!.firstName
        lastNameTextField.text = appDelegate.profile!.lastName
        useShippingSwitch.on = false
        
        let shared = appDelegate.factory.getShared()
        shared.addBottomLineToTextField(firstNameTextField)
        shared.addBottomLineToTextField(lastNameTextField)
        shared.addBottomLineToTextField(addressTextField)
        shared.addBottomLineToTextField(citiTextField)
        shared.addBottomLineToTextField(stateTextField)
        shared.addBottomLineToTextField(zipCodeTextField)
        shared.addBottomLineToTextField(cardHolderNameTextField)
        shared.addBottomLineToTextField(cardNumberTextField)
        shared.addBottomLineToTextField(cvvTextField)
        shared.addBottomLineToTextField(expirationYearTextField)
        shared.addBottomLineToTextField(expirationMonthTextField)
        
        let staticDataProvider = appDelegate.factory.getSaticDataProvider()
        months = staticDataProvider.getMonths()
        years = staticDataProvider.getYears()
        
        expMonthPicker.dataSource = self
        expMonthPicker.delegate = self
        expMonthPicker.tag = 0
        expirationMonthTextField.inputView = expMonthPicker
        
        expYearPicker.dataSource = self
        expYearPicker.delegate = self
        expYearPicker.tag = 1
        expirationYearTextField.inputView = expYearPicker
    }
    
    private func startCheckout() {
        let shared = appDelegate.factory.getShared()
        shared.showBusy(self.view)
        
        let shopifyDataProvider = appDelegate.factory.getShopifyDataProvider()
        let profile = appDelegate.profile!
        shopifyDataProvider.doCreditCardCheckout(products!, shippingAddress: profile.shippingAddress!, billingAddress: loadBillingAddress(), email: profile.email!, shippingRate: profile.shippingRateId!, creditCard: getCreditCard(), discountCode: reward?.rewardId, callback: { (checkout, error, status) -> Void in
            if error == nil && status == BUYStatus.Complete {
                
                self.checkout = checkout
                self.deductRewardPoints()
                self.saveOrder(checkout!)
                
                shared.hideBusy()
                
                self.performSegueWithIdentifier("orderSuccessSegue", sender: self)
            } else {
                shared.hideBusy()
                shared.showAlert("Error", message: "There was an error processing your payment", viewController: self, handler: nil)
            }
        })
    }
    
    private func saveOrder(checkout: BUYCheckout) {
        let localDataProvider = appDelegate.factory.getLocalDataProvider()
        localDataProvider.createOrder(appDelegate.profile!.profileId!, merchadiseTotal: checkout.subtotalPrice.doubleValue, shippingCost: appDelegate.profile!.shippingRatePrice!, taxes: checkout.totalTax.doubleValue, rewardId: reward?.rewardId, orderTotal: checkout.totalPrice.doubleValue)
    }
    
    private func deductRewardPoints() {
        if let usedReward = reward {
            let apiDataProvider = appDelegate.factory.getApiDataProvider()
            apiDataProvider.deductPoints(appDelegate.profile!.email!, points: usedReward.points)
            appDelegate.profile!.points -= usedReward.points
            appDelegate.profile!.pointsStatus += usedReward.points
        }
    }
    
    private func loadCreditCard() -> Void {
        creditCard = PCreditCard()
        creditCard!.billingAddress = loadBillingAddress()
        creditCard!.carholderName = cardHolderNameTextField.text
        creditCard!.number = cardNumberTextField.text
        creditCard!.expirationMonth = "\(expMonth)"
        creditCard!.expirationYear = expirationYearTextField.text
        creditCard!.ccv = cvvTextField.text
    }
    
    private func loadBillingAddress() -> PAddress {
        let address = PAddress()
    
        address.firstName = firstNameTextField.text
        address.lastName = lastNameTextField.text
        address.address1 = addressTextField.text
        address.city = citiTextField.text
        address.state = stateTextField.text
        address.zip = zipCodeTextField.text
        address.country = "US"
    
        return address
    }
    
    private func getCreditCard() -> BUYCreditCard {
        let creditCardInfo = BUYCreditCard()
        creditCardInfo.number = creditCard!.number
        creditCardInfo.expiryMonth = creditCard!.expirationMonth
        creditCardInfo.expiryYear = creditCard!.expirationYear
        creditCardInfo.cvv = creditCard!.ccv
        creditCardInfo.nameOnCard = creditCard!.carholderName
        
        return creditCardInfo
    }
    
    private func clean() {
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        addressTextField.text = ""
        citiTextField.text = ""
        stateTextField.text = ""
        zipCodeTextField.text = ""
    }
    
    private func populateShipping() {
        if let shippingAddress = appDelegate.profile!.shippingAddress {
            firstNameTextField.text = shippingAddress.firstName
            lastNameTextField.text = shippingAddress.lastName
            addressTextField.text = shippingAddress.address1
            citiTextField.text = shippingAddress.city
            stateTextField.text = shippingAddress.state
            zipCodeTextField.text = shippingAddress.zip
        }
    }
}
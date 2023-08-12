//
//  AddressViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/18/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit
import Buy

enum AddressTypes {
    case Shipping
    case Billing
}

class AddressViewController: UIViewController {
    
    @IBOutlet weak var address1TextField: UITextField!
    @IBOutlet weak var address2textField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var totalProductsLabel: UILabel!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var shippingAddress = PAddress()
    
    var products : [PProduct]? = nil
    var totalSelectedProducts = 0
    var totalCostProducts = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialize()
        customizeUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueButtonClick(sender: UIButton) {
        if !isValidAddress() {
            let shared = appDelegate.factory.getShared()
            shared.showAlert("Error", message: "Invalid Address", viewController: self, handler: nil)
        } else {
            readAddress(shippingAddress)
            self.performSegueWithIdentifier("paymentMethodSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "paymentMethodSegue" {
            let destinationController = segue.destinationViewController as! PaymentMethodViewController
            destinationController.products = products
            destinationController.shippingAddress = shippingAddress
            destinationController.totalSelectedProducts = totalSelectedProducts
            destinationController.totalCostProducts = totalCostProducts
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool    {
        textField.resignFirstResponder()
        return true;
    }
    
    private func initialize() {
        if let address = appDelegate.profile?.shippingAddress {
            firstNameTextField.text = address.firstName
            lastNameTextField.text = address.lastName
            address1TextField.text = address.address1
            address2textField.text = address.address2
            cityTextField.text = address.city
            stateTextField.text = address.state
            zipCodeTextField.text = address.zip
        } else {
            firstNameTextField.text = appDelegate.profile?.firstName
            lastNameTextField.text = appDelegate.profile?.lastName
        }
        
        totalCostLabel.text = "$\(totalCostProducts.string(2))"
        totalProductsLabel.text = "\(totalSelectedProducts)"
    }
    
    private func isValidAddress() -> Bool {
        return address1TextField.text != nil && !address1TextField.text!.isEmpty
            && cityTextField.text != nil && !cityTextField.text!.isEmpty
            && stateTextField.text != nil && !stateTextField.text!.isEmpty
            && zipCodeTextField.text != nil && !zipCodeTextField.text!.isEmpty
            && firstNameTextField.text != nil &&  !firstNameTextField.text!.isEmpty
            && lastNameTextField.text != nil && !lastNameTextField.text!.isEmpty
    }
    
    private func readAddress( address : PAddress) {
        address.firstName = firstNameTextField.text
        address.lastName = lastNameTextField.text
        address.address1 = address1TextField.text
        address.address2 = address2textField.text
        address.city = cityTextField.text
        address.state = stateTextField.text
        address.zip = zipCodeTextField.text
    }
    
    private func customizeUI() {
        let shared = appDelegate.factory.getShared()
        
        shared.addBottomLineToTextField(firstNameTextField)
        shared.addBottomLineToTextField(lastNameTextField)
        shared.addBottomLineToTextField(address1TextField)
        shared.addBottomLineToTextField(address2textField)
        shared.addBottomLineToTextField(cityTextField)
        shared.addBottomLineToTextField(stateTextField)
        shared.addBottomLineToTextField(zipCodeTextField)
    }
    
    @IBAction func backToAddressViewController(segue:UIStoryboardSegue) {
    }
}

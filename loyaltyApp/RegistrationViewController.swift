//
//  RegistrationViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 11/18/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var termsAndConditionsLabel: UILabel!
    @IBOutlet weak var termsAndConditionsButton: UIButton!
    @IBOutlet weak var termsAndConditionsUnderlined: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var acceptLabel: UILabel!
    @IBOutlet weak var acceptTextField: UITextField!
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    private var shared :Shared? = nil
    
    var forgotPassword = false
    var email :String? = nil
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "verificationSegue" {
            let destinationController = segue.destinationViewController as! VerificationViewController
            let registrationCode = sendCode()
            destinationController.registrationCode = registrationCode
            destinationController.email = emailTextField.text
            destinationController.forgotPassword = forgotPassword
            destinationController.firstName = firstNameTextField.text
            destinationController.lastName = lastNameTextField.text
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func verifyClick(sender: UIButton) {
        
        let apiDataProvider = appDelegate.factory.getApiDataProvider()
        
        shared!.showBusy(self.view)
        if isValidEmail() && isValidInfo() {
            apiDataProvider.getProfile(emailTextField.text!, callback: {(apiProfile) -> Void in
                //back to main thread
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    self.shared!.hideBusy()
                    if self.forgotPassword {
                        self.doForgotPassword(apiProfile)
                    } else {
                        if self.acceptLabel.backgroundColor != UIColor.whiteColor() {
                            self.doRegistration(apiProfile)
                        }  else {
                            self.shared!.hideBusy()
                            self.shared!.showAlert("Terms and Conditions", message: "You must accept the terms and conditions to continue", viewController: self, handler: nil)
                        }
                    }
                }
            })
        } else {
            shared!.hideBusy()
            shared!.showAlert("Invalid Information", message: "Email, First and Last Name are Required", viewController: self, handler: nil)
        }
    }
    
    @IBAction func termsAndConditionsAcceptClick(sender: UIButton) {
        let shared = appDelegate.factory.getShared()
        acceptLabel.backgroundColor = acceptLabel.backgroundColor == UIColor.whiteColor() ? shared.getRedColor() : UIColor.whiteColor()
    }
    
    @IBAction func termsAndConditionsClick(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: Configuration.TermsAndConditionsUrl)!)
        //self.dismissViewControllerAnimated(true, completion: nil)
    }
    
//    func textFieldDidBeginEditing(textField: UITextField) {
//        let shared = appDelegate.factory.getShared()
//        if shared.isOldIPhone() {
//            animateViewMoving(true, moveValue: 180)
//        }
//    }
//    
//    func textFieldDidEndEditing(textField: UITextField) {
//        let shared = appDelegate.factory.getShared()
//        if shared.isOldIPhone() {
//            animateViewMoving(false, moveValue: 180)
//        }
//    }
//    
//    func animateViewMoving (up:Bool, moveValue :CGFloat){
//        let movementDuration:NSTimeInterval = 0.3
//        let movement:CGFloat = ( up ? -moveValue : moveValue)
//        UIView.beginAnimations( "animateView", context: nil)
//        UIView.setAnimationBeginsFromCurrentState(true)
//        UIView.setAnimationDuration(movementDuration )
//        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
//        UIView.commitAnimations()
//    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool    {
        textField.resignFirstResponder()
        return true;
    }
    
    private func isValidInfo() -> Bool {
        return forgotPassword || (firstNameTextField.text ?? "" != "" && lastNameTextField.text ?? "" != "")
    }
    
    private func initialize() {
        if let emailAddress = email {
            emailTextField.text = emailAddress
        }
        termsAndConditionsLabel.backgroundColor = UIColor.whiteColor()
        self.shared = appDelegate.factory.getShared()
    }
    
    private func customizeUI() {
        shared!.addBottomLineToTextField(emailTextField)
        
        if forgotPassword {
            firstNameTextField.hidden = true
            lastNameTextField.hidden = true
            termsAndConditionsLabel.hidden = true
            termsAndConditionsButton.hidden = true
            termsAndConditionsUnderlined.hidden = true
            acceptButton.hidden = true
            acceptLabel.hidden = true
            acceptTextField.hidden = true
        } else {
            firstNameTextField.hidden = false
            lastNameTextField.hidden = false
            termsAndConditionsLabel.hidden = false
            termsAndConditionsButton.hidden = false
            termsAndConditionsUnderlined.hidden = false
            acceptButton.hidden = false
            acceptLabel.hidden = false
            acceptLabel.backgroundColor = UIColor.whiteColor()
            acceptTextField.hidden = false
            shared!.addBottomLineToTextField(firstNameTextField)
            shared!.addBottomLineToTextField(lastNameTextField)
        }
    }
    
    private func isValidEmail() -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(emailTextField.text)
    }
    
    private func doForgotPassword(apiProfile :PProfile?) {
        if apiProfile != nil {
            let localDataProvider = appDelegate.factory.getLocalDataProvider()
            if apiProfile!.password ?? "" != "" {
                if let localProfile = localDataProvider.getProfile(apiProfile!.email) {
                    appDelegate.profile = localDataProvider.updateProfile(localProfile, pProfile: apiProfile)
                    showVerification()
                } else {
                    appDelegate.profile = localDataProvider.createProfile(apiProfile!)
                    showVerification()
                }
            } else {
                appDelegate.profile = localDataProvider.createProfile(apiProfile!)
                showVerification()
            }
        } else {
            shared!.showAlert("Error", message: "There is no account associated to this email address", viewController: self, handler: nil)
        }
    }
    
    private func doRegistration(apiProfile :PProfile?) {
        if apiProfile != nil {
            if apiProfile!.password ?? "" != "" {
                self.shared!.showAlert("Invalid email address", message: "Sorry, this email address already has an account", viewController: self, handler: nil)
            } else {
                let localDataProvider = self.appDelegate.factory.getLocalDataProvider()
                self.appDelegate.profile = localDataProvider.createProfile(apiProfile!)
                self.forgotPassword = true
                
                showVerification()
            }
        } else {
           showVerification()
        }
    }
    
    private func sendCode() -> RegistrationCode {
        let apiDataProvider = appDelegate.factory.getApiDataProvider()
        let coder = self.appDelegate.factory.getCoder()
        
        let registrationCode = coder.generateCode()
        let staticDataProvider = appDelegate.factory.getSaticDataProvider()
        apiDataProvider.sendEmail(self.emailTextField.text!,subject: "Eat Me Guilt Free Registration" ,body: staticDataProvider.getEmailContent(registrationCode.code!))
        
        return registrationCode
    }
    
    private func showVerification() {
        shared!.showAlert("Registration Code", message: "Check your email and add the confirmation code to finish the registration", viewController: self, handler: { (action) -> Void in
            self.performSegueWithIdentifier("verificationSegue", sender: self)
        })
    }
}

//
//  ProfileViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 11/29/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit

class VerificationViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmationCodeTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    var email :String? = nil
    var firstName :String? = nil
    var lastName :String? = nil
    var registrationCode : RegistrationCode? = nil
    var forgotPassword = false
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    private var shared :Shared? = nil
    
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func registerClick(sender: UIButton) {
        shared!.showBusy(self.view)
        let error = validateInfo()
        if error == ErrorCodes.None {
            if forgotPassword {
                verifyForgotPassword()
            } else {
                verifyRegistration()
            }
        } else {
            shared!.hideBusy()
            let message = error == ErrorCodes.RequiredFields ? "All fields are required"
                : (error == ErrorCodes.PasswordsDoNotMatch ? "Passwords do not match"
                    : "Invalid Registration Code")
            shared!.showAlert("Invalid Information", message: message, viewController: self, handler: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool    {
        textField.resignFirstResponder()
        return true;
    }
    
    private func initialize() {
        shared = appDelegate.factory.getShared()
        
        if let _ = appDelegate.profile {
            emailTextField.text = appDelegate.profile!.email
            emailTextField.userInteractionEnabled = true
        } else {
            emailTextField.text = email
            emailTextField.userInteractionEnabled = false
        }
    }
    
    private func customizeUI() {
        self.shared!.addBottomLineToTextField(emailTextField)
        self.shared!.addBottomLineToTextField(confirmationCodeTextField)
        self.shared!.addBottomLineToTextField(passwordTextField)
        self.shared!.addBottomLineToTextField(confirmPasswordTextField)
    }
    
    private func validateInfo() -> Int {
        if confirmationCodeTextField.text ?? "" == "" || passwordTextField.text ?? "" == "" || confirmPasswordTextField.text ?? "" == "" {
            return ErrorCodes.RequiredFields
        }
        if passwordTextField.text != confirmPasswordTextField.text {
            return ErrorCodes.PasswordsDoNotMatch
        }
        if confirmationCodeTextField.text != registrationCode?.code && confirmationCodeTextField.text != Configuration.BetaVerificationCode {
            return ErrorCodes.InvalidCode
        }
        
        return ErrorCodes.None
    }
    
    private func verifyRegistration() {
        let localDataProvider = appDelegate.factory.getLocalDataProvider()
        let newProfile = PProfile()
        newProfile.email = email
        newProfile.password = localDataProvider.hash(passwordTextField.text!)
        newProfile.firstName = firstName
        newProfile.lastName = lastName
        appDelegate.profile = localDataProvider.createProfile(newProfile)
        
        let apiDataProvider = self.appDelegate.factory.getApiDataProvider()
        apiDataProvider.createProfile(newProfile.email!, password: newProfile.password!, firstName:newProfile.firstName!, lastName:newProfile.lastName!)

        self.shared!.hideBusy()
        proposeTouchId()
    }
    
    private func proposeTouchId() {
        let profile = appDelegate.profile!
        let localDataProvider = appDelegate.factory.getLocalDataProvider()
        
        if profile.usingTouchId {
            self.performSegueWithIdentifier("verificationHomeSegue", sender: self)
        } else {
            self.shared!.showConfirmationAlert("Enable Touch Id?", message: "Would you like to enable Touch Id for this application?", viewController: self, okAction: { (action) -> Void in
                    self.appDelegate.profile!.usingTouchId = true
                    localDataProvider.setUsingTouchId(self.appDelegate.profile!.profileId!)
                    self.performSegueWithIdentifier("welcomeMessageSegue", sender: self)
                }, cancelAction: { (action) -> Void in
                    self.performSegueWithIdentifier("welcomeMessageSegue", sender: self)
            })
        }
    }
    
    private func verifyForgotPassword() {
        let localDataProvider = appDelegate.factory.getLocalDataProvider()
        appDelegate.profile!.password = localDataProvider.updatePassword(appDelegate.profile!.profileId!, password: passwordTextField.text!)
        let apiDataProvider = self.appDelegate.factory.getApiDataProvider()
        apiDataProvider.updatePassword(appDelegate.profile!.email!, password: appDelegate.profile!.password!)
        
        self.shared!.hideBusy()
        self.performSegueWithIdentifier("verificationHomeSegue", sender: self)
    }
    
}

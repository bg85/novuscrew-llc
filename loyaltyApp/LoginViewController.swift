//
//  LoginViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 11/17/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    private var shared :Shared? = nil
    private var forgotPassword = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        initialize()
        customizeUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginVerificationSegue" {
            let destinationViewController = segue.destinationViewController as! VerificationViewController
            if appDelegate.profile != nil {
                destinationViewController.email = appDelegate.profile!.email
            }
            forgotPassword = true
            destinationViewController.forgotPassword = forgotPassword
        } else if segue.identifier == "registrationSegue" {
            let destinationViewController = segue.destinationViewController as! RegistrationViewController
            destinationViewController.forgotPassword = forgotPassword
            destinationViewController.email = emailInput.text
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func forgotPasswordLink(sender: UIButton) {
        forgotPassword = true
        self.performSegueWithIdentifier("registrationSegue", sender: self)
    }
    
    @IBAction func loginClick(sender: UIButton) {
        let localDataProvider = self.appDelegate.factory.getLocalDataProvider()
        shared!.showBusy(self.view)
        var validUser = false
        
        if isValidLoginInfo() {
            let apiDataProvider = appDelegate.factory.getApiDataProvider()
            apiDataProvider.getProfile(emailInput.text!, callback: { (apiProfile) -> Void in
                if apiProfile != nil {
                    if apiProfile!.password ?? "" != "" {
                        if let localProfile = localDataProvider.getProfile(apiProfile!.email) {
                            if localProfile.password == localDataProvider.hash(self.passwordInput.text!) {
                                validUser = true
                                localProfile.visits += 1
                                self.appDelegate.profile = localDataProvider.updateProfile(localProfile, pProfile: apiProfile)
                            }
                        } else {
                            if apiProfile!.password == localDataProvider.hash(self.passwordInput.text!) {
                                validUser = true
                                self.appDelegate.profile = localDataProvider.createProfile(apiProfile!)
                            }
                        }
                        
                        //back to main thread
                        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                            self.shared!.hideBusy()
                            if validUser {
                                self.proposetouchId()
                            }
                            else {
                                self.shared!.showAlert("Error", message: "Invalid Email/Password combination", viewController: self, handler:  nil)
                            }
                        }
                    } else {
                        //back to main thread
                        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                            self.shared!.hideBusy()
                            self.appDelegate.profile = localDataProvider.createProfile(apiProfile!)
                            self.performSegueWithIdentifier("loginVerificationSegue", sender: self)
                        }
                    }
                } else {
                    //back to main thread
                    dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                        self.shared!.hideBusy()
                        self.shared!.showAlert("Error", message: "Invalid Email/Password combination", viewController: self, handler:  nil)
                    }
                }
            })
        } else {
            shared!.hideBusy()
            shared!.showAlert("Error", message: "A valid email and password are required", viewController: self, handler:  nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool    {
        textField.resignFirstResponder()
        return true;
    }
    
    private func isValidLoginInfo() -> Bool {
        return emailInput.text ?? "" != "" && passwordInput.text ?? "" != ""
    }
    
    private func initialize() {
        let localDataProvider = appDelegate.factory.getLocalDataProvider()
        shared = appDelegate.factory.getShared()
        
        shared!.showBusy(self.view)
        
        if let profile = localDataProvider.getTopOneProfile() {
            if profile.usingTouchId ?? false {
                emailInput.text = profile.email
                authenticateWithTouchId(profile)
            }
        }
        
        shared!.hideBusy()
    }
    
    private func authenticateWithTouchId(profile: Profile){
        let context = LAContext()
        var error: NSError?
        let viewController = self
        
        if context.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate with Touch ID"
            context.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(succes, error) in
                    if succes {
                        let apiDataProvider = self.appDelegate.factory.getApiDataProvider()
                        apiDataProvider.getProfile(profile.email!, callback: { (apiProfile) -> Void in
                            self.shared!.hideBusy()
                            if apiProfile != nil {
                                profile.visits += 1
                                let localDataProvider = self.appDelegate.factory.getLocalDataProvider()
                                self.appDelegate.profile = localDataProvider.updateProfile(profile, pProfile: apiProfile)
                                //back to main thread
                                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                                    self.performSegueWithIdentifier("homeSegue", sender: self)
                                }
                            } else {
                                //back to main thread
                                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                                    self.shared!.showAlert("Error", message: "An error has occurred. Please verify your Internet connection", viewController: self, handler: nil)
                                }
                            }
                        })
                    }
            })
        }
        else {
            self.shared!.hideBusy()
            shared!.showAlert("Touch ID", message: "Touch ID not available", viewController: viewController, handler: nil)
        }
    }
    
    private func proposetouchId() {
        let profile = appDelegate.profile!
        let localDataProvider = appDelegate.factory.getLocalDataProvider()
        
        if profile.usingTouchId {
            self.performSegueWithIdentifier("homeSegue", sender: self)
        } else {
            let nextScreen = appDelegate.profile!.visits == 1 ? "loginWelcomeSegue" : "homeSegue"
            self.shared!.showConfirmationAlert("Enable Touch Id?", message: "Would you like to enable Touch Id for this application?", viewController: self, okAction: { (action) -> Void in
                self.appDelegate.profile!.usingTouchId = true
                localDataProvider.setUsingTouchId(self.appDelegate.profile!.profileId!)
                self.performSegueWithIdentifier(nextScreen, sender: self)
                }, cancelAction: { (action) -> Void in
                    self.performSegueWithIdentifier(nextScreen, sender: self)
            })
        }
    }

    private func customizeUI() {
        shared!.addBottomLineToTextField(emailInput)
        shared!.addBottomLineToTextField(passwordInput)
    }
    
    @IBAction func backToLoginViewController(segue:UIStoryboardSegue) {
        emailInput.text = ""
        passwordInput.text = ""
        forgotPassword = false
    }
}


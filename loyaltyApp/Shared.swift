//
//  Shared.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/29/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit

class Shared {
    private var progressView: ProgressView? = nil
    
    func showAlert(title: String, message: String, viewController: UIViewController, handler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title:title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: handler))
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showConfirmationAlert(title: String, message: String, viewController: UIViewController, okAction :(UIAlertAction) -> Void, cancelAction: (UIAlertAction) -> Void)
    {
        let confirmationAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        confirmationAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: okAction))
        confirmationAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: cancelAction))
        
        viewController.presentViewController(confirmationAlert, animated: true, completion: nil)
    }
    
    func showBusy(view: UIView) {
        if progressView != nil {
            progressView = nil
        }
        progressView = getProgressView()
        view.addSubview(progressView!)
        progressView!.animateProgressView()
    }
    
    func hideBusy() {
        if progressView != nil {
            progressView!.hideProgressView()
            progressView!.removeFromSuperview()
            progressView = nil
        }
    }
    
    func showMenu(activeItem :Int, viewController: UIViewController) {
        let menuViewController = viewController.storyboard!.instantiateViewControllerWithIdentifier("menuViewController") as! MenuViewController
        menuViewController.currentItem = activeItem
        viewController.presentViewController(menuViewController, animated: true, completion: nil)
    }
    
    func addBottomLineToTextField(textField: UITextField) {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = getDarkGrayColor().CGColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height: textField.frame.size.height)
        
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    func getRedColor() -> UIColor {
        return UIColor(red: CGFloat(200) / 255.0, green: CGFloat(10) / 255.0, blue: CGFloat(14) / 255.0, alpha: 1)
    }
    
    func getLightGrayColor() -> UIColor {
        return UIColor(red: CGFloat(245) / 255.0, green: CGFloat(245) / 255.0, blue: CGFloat(245) / 255.0, alpha: 1)
    }
    
    func getDarkGrayColor() -> UIColor {
        return UIColor(red: CGFloat(222) / 255.0, green: CGFloat(222) / 255.0, blue: CGFloat(222) / 255.0, alpha: 1)
    }
    
    func getGreenColor() -> UIColor {
        return UIColor(red: CGFloat(99) / 255.0, green: CGFloat(200) / 255.0, blue: CGFloat(111) / 255.0, alpha: 1)
    }
    
    func getBackgroundGrayColor() -> UIColor {
        return UIColor(red: CGFloat(239) / 255.0, green: CGFloat(239) / 255.0, blue: CGFloat(239) / 255.0, alpha: 1)
    }
    
    func isOldIPhone() -> Bool {
        let deviceModel = UIDevice().type
        return deviceModel == Model.iPhone4 || deviceModel == Model.iPhone4S || deviceModel == Model.iPhone5 || deviceModel == Model.iPhone5S || deviceModel == Model.iPhone5C
    }
    
    func formatNumber(number :Double) -> String {
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.stringFromNumber(number)!
    }
    
    private func getProgressView() -> ProgressView {
        let bounds = UIScreen.mainScreen().bounds
        return ProgressView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
    }
}
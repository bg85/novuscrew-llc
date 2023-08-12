//
//  MenuViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 2/13/16.
//  Copyright © 2016 Barbara Gonzalez. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var pointsMenuView: MenuItemView!
    @IBOutlet weak var quickBuyMenuView: MenuItemView!
    @IBOutlet weak var statusMenuView: MenuItemView!
    
    var currentItem = -1
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pointsClick(sender: UIButton) {
        self.performSegueWithIdentifier("pointsBackMenuSegue", sender: self)
    }
    
    @IBAction func quickBuyClick(sender: UIButton) {
        self.performSegueWithIdentifier("quickBuyBackMenuSegue", sender: self)
    }
    
    @IBAction func statusClick(sender: UIButton) {
        self.performSegueWithIdentifier("statusBackMenuSegue", sender: self)
    }
    
    @IBAction func termsAndConditionsClick(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: Configuration.TermsAndConditionsUrl)!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func logoutClick(sender: UIButton) {
        appDelegate.profile = nil
        self.performSegueWithIdentifier("logoutSegue", sender: sender)
    }
    
    @IBAction func closeClick(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func initialize() {
        let shared = appDelegate.factory.getShared()
        let lightGrayColor = shared.getLightGrayColor()
        
        pointsMenuView.backgroundColor = (currentItem == MenuItems.Points ? lightGrayColor : UIColor.whiteColor())
        quickBuyMenuView.backgroundColor = (currentItem == MenuItems.QuickBuy ? lightGrayColor : UIColor.whiteColor())
        statusMenuView.backgroundColor = (currentItem == MenuItems.Status ? lightGrayColor : UIColor.whiteColor())
    }
}

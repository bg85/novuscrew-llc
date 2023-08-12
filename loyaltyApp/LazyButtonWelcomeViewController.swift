//
//  LazyButtonWelcomeViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/23/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit
import Buy

class LazyButtonWelcomeViewController: UIViewController {
    
    @IBOutlet weak var description2Label: UILabel!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var started = false
    
    var allVariants :[BUYProductVariant]? = nil
    var products :[PProduct]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pickAProductSegue" {
            let destinationViewController = segue.destinationViewController as! PickAProductViewController
            destinationViewController.allVariants = allVariants
            destinationViewController.products = products
        }
    }
    
    @IBAction func startButtonClicked(sender: UIButton) {
        started = true
        self.performSegueWithIdentifier("pickAProductSegue", sender: self)
    }
    
    @IBAction func menuClick(sender: UIButton) {
        let shared = appDelegate.factory.getShared()
        shared.showMenu(MenuItems.QuickBuy, viewController: self)
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        let shared = appDelegate.factory.getShared()
        if started {
            shared.showConfirmationAlert("Cancel set up", message: "Are you sure you want to cancel? Your changes will be lost", viewController: self, okAction: { (action) -> Void in
                self.performSegueWithIdentifier("welcomeBackHomeSegue", sender: self)
                }) { (action) -> Void in
                    //Do nothing
            }
        } else {
            self.performSegueWithIdentifier("welcomeBackHomeSegue", sender: self)
        }
    }
    
    private func initUI(){
        let shared = appDelegate.factory.getShared()
        if shared.isOldIPhone() {
            description2Label.hidden = true
        }
    }
}

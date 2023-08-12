//
//  StatusViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/3/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import Foundation
import UIKit
import Social

class StatusViewController: UIViewController {
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var pointsStaticLabel: UILabel!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if appDelegate.profile != nil {
            initUI()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shareClick(sender: AnyObject) {
        addShare()
        shareSocially(SLServiceTypeFacebook, errorMessage: "Please login to a Facebook account to share.")
    }
    
    @IBAction func tweetClick(sender: UIButton) {
        addShare()
        shareSocially(SLServiceTypeTwitter, errorMessage: "Please login to a Twitter account to tweet.")
    }
    
    @IBAction func menuClick(sender: UIButton) {
        let shared = appDelegate.factory.getShared()
        shared.showMenu(MenuItems.Status, viewController: self)
    }
    
    private func initUI(){
        let staticDataProvider = appDelegate.factory.getSaticDataProvider()
        let status = staticDataProvider.getStatus(Int((appDelegate.profile!.pointsStatus)))
        statusLabel.text = status.title
        pointsLabel.text = "\(appDelegate.profile!.points)"
        let shared = appDelegate.factory.getShared()
        if shared.isOldIPhone() {
            pointsStaticLabel.hidden = true
        }
    }
    
    private func addShare() {
        let localDataProvider = appDelegate.factory.getLocalDataProvider()
        localDataProvider.addShare(appDelegate.profile!.profileId!)
    }
    
    private func shareSocially(serviceType: String, errorMessage: String) {
        if SLComposeViewController.isAvailableForServiceType(serviceType) {
            let shareController:SLComposeViewController = SLComposeViewController(forServiceType: serviceType)
            self.presentViewController(shareController, animated: true, completion: nil)
        } else {
            let shared = appDelegate.factory.getShared()
            shared.showAlert("Accounts", message: errorMessage, viewController: self, handler: nil)
        }
    }
    
    @IBAction func backToStatusViewController(segue:UIStoryboardSegue) {
    }
}
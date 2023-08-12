//
//  LazyRewardsViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 1/30/16.
//  Copyright © 2016 Barbara Gonzalez. All rights reserved.
//

import UIKit

class LazyRewardsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var availableRewards = [Reward]()
    var selected = -1
    var products :[PProduct]? = nil
    var rewardToApply :Reward? = nil
    
    @IBOutlet weak var rewardsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeClick(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func selectRewardClick(sender: UIButton) {
        if selected >= 0 {
            if isRewardApplicable() {
                performSegueWithIdentifier("backToCartSegue", sender: self)
            } else {
                let shared = appDelegate.factory.getShared()
                shared.showAlert("Invalid Reward", message: "The products in your cart do not qualify for this reward", viewController: self, handler: nil)
            }
        } else {
            performSegueWithIdentifier("backToCartSegue", sender: self)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableRewards.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("lazyRewardsCell", forIndexPath: indexPath) as! LazyRewardsTableViewCell
        
        cell.controller = self
        cell.draw(availableRewards[indexPath.row], index:indexPath.row, selected:(indexPath.row == selected))
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "backToCartSegue" {//&& selected >= 0 {
            let destinationViewController = segue.destinationViewController as! LazyButtonViewController
            destinationViewController.rewardToApply = selected >= 0 ? availableRewards[selected] : nil
            //destinationViewController.updateRewards()
        }
    }
    
    func updateSelected(index :Int) {
        selected = index
        rewardsTableView.reloadData()
    }
    
    private func isRewardApplicable() -> Bool {
        let reward = availableRewards[selected]
        let rewardProducts = products!.filter({ (product) -> Bool in
            let isIncluded = reward.skus == nil ? 0 : reward.skus!.indexOf({ (sku) -> Bool in
                product.variant!.sku.lowercaseString == sku.lowercaseString
            })
            return isIncluded >= 0
        })
        
        return rewardProducts.count > 0
    }
    
    private func initialize() {
        let staticDataProvider = appDelegate.factory.getSaticDataProvider()
        
        let rewards = staticDataProvider.getRewards()
        let points = Int(appDelegate.profile!.points)
        availableRewards = rewards.filter { (reward) -> Bool in
            reward.points <= points
        }
        
        if rewardToApply != nil {
            let index = availableRewards.indexOf({ (reward) -> Bool in
                reward.rewardId == rewardToApply!.rewardId
            })
            if index >= 0 {
                updateSelected(index!)
            }
        }
    }
}

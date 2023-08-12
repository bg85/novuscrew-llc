//
//  HomeViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 11/17/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tabBArItem: UITabBarItem!
    @IBOutlet weak var sharesLabel: UILabel!
    @IBOutlet weak var vistisLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var infoList: UITableViewCell!
    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var items = [AnyObject]()
    var usedRewardIdentifiers :[String]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if appDelegate.profile != nil {
            InitData()
            InitUI()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showMenuClick(sender: AnyObject) {
        let shared = appDelegate.factory.getShared()
        shared.showMenu(MenuItems.Points, viewController: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("custonCell") as? RewardsTableViewCell {
            let reward = self.items[indexPath.row] as! Reward
            let used = self.usedRewardIdentifiers!.indexOf({ (identifier) -> Bool in
                identifier == reward.rewardId
            })
            cell.draw(reward, points: (appDelegate.profile?.points)!, used: used >= 0)
            return cell
        }
        
        return tableView.dequeueReusableCellWithIdentifier("cell")!
    }
    
    private func InitUI() {
        sharesLabel.text = "\(appDelegate.profile!.shares)"
        vistisLabel.text = "\(appDelegate.profile!.visits)"
        pointsLabel.text = "\(appDelegate.profile!.points)"
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        displayRewards()
    }
    
    private func InitData(){
        let localDataProvider = appDelegate.factory.getLocalDataProvider()
        let orders = localDataProvider.getOrders(appDelegate.profile!.profileId!)
        
        self.usedRewardIdentifiers = orders?.map({ (order) -> String in
            return order.rewardId ?? ""
        })
    }
    
    private func displayRewards() {
        let staticDataProvider = appDelegate.factory.getSaticDataProvider()
        items = staticDataProvider.getRewards()
        tableView.reloadData()
    }
    
    @IBAction func backToHome(segue:UIStoryboardSegue) {
        if appDelegate.profile != nil {
            InitData()
            InitUI()
        }
    }
    
}

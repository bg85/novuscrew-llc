//
//  RewardsTableViewCell.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 1/11/16.
//  Copyright © 2016 Barbara Gonzalez. All rights reserved.
//

import UIKit

class RewardsTableViewCell: UITableViewCell {

    @IBOutlet weak var rewardPointsLabel: UILabel!
    @IBOutlet weak var rewardTitleLabel: UILabel!
    @IBOutlet weak var rewardDescriptionLabel: UILabel!
    @IBOutlet weak var rewardActionLabel: UILabel!
    @IBOutlet weak var pointsStaticLabel: UILabel!
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func draw(reward :Reward, points :Int32, used: Bool) {
        
        rewardPointsLabel.text = "\(reward.points)"
        rewardTitleLabel.text = reward.title
        rewardDescriptionLabel.text = reward.description

        if Int(points) >= reward.points {
            let shared = appDelegate.factory.getShared()
            self.backgroundColor = used ? UIColor.grayColor() : shared.getRedColor()
            rewardActionLabel.text = used ? "Used!" : "Got it!"
            rewardTitleLabel.textColor = UIColor.whiteColor()
            rewardDescriptionLabel.textColor = UIColor.whiteColor()
            rewardActionLabel.textColor = UIColor.whiteColor()
            pointsStaticLabel.textColor = UIColor.whiteColor()
            rewardPointsLabel.textColor = UIColor.whiteColor()
        } else {
            self.backgroundColor = UIColor.whiteColor()
            rewardActionLabel.text = ""
            rewardTitleLabel.textColor = UIColor.darkGrayColor()
            rewardDescriptionLabel.textColor = UIColor.darkGrayColor()
            rewardActionLabel.textColor = UIColor.darkGrayColor()
            pointsStaticLabel.textColor = UIColor.darkGrayColor()
            rewardPointsLabel.textColor = UIColor.darkGrayColor()
        }
    }
}

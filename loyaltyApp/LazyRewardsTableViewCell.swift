//
//  LazyRewardsTableViewCell.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 1/30/16.
//  Copyright © 2016 Barbara Gonzalez. All rights reserved.
//

import UIKit

class LazyRewardsTableViewCell: UITableViewCell {
    
    var controller : LazyRewardsViewController? = nil
    private var index = -1
    
    @IBOutlet weak var onSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBAction func onClick(sender: UISwitch) {
        if !sender.on {
            //sender.on = false
            controller!.updateSelected(-1)
        } else {
            //sender.on = true
            controller!.updateSelected(index)
        }
    }
    
    func draw(reward :Reward, index: Int, selected: Bool) {
        self.index = index
        titleLabel.text = reward.title
        pointsLabel.text = "\(reward.points)"
        onSwitch.on = selected
    }
}


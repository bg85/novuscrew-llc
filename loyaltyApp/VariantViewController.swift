//
//  VariantViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 1/28/16.
//  Copyright © 2016 Barbara Gonzalez. All rights reserved.
//

import UIKit
import Buy

class VariantViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var product : (product:BUYProduct, variants:[PProduct], quantity:Int, price:Double, image: UIImage?)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "backToPickSegue" {
            let destinationController = segue.destinationViewController as! PickAProductViewController
            destinationController.updatedProduct = self.product!
        }
    }
    
    @IBAction func closeClick(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return product!.variants.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("variantCell", forIndexPath: indexPath) as! VariantsTableViewCell
        cell.controller = self
        let pvariant = product!.variants[indexPath.row]
        cell.draw(pvariant.variant!.title , qty: pvariant.quantity, price: pvariant.variant!.price.doubleValue, index:indexPath.row)
        
        return cell
    }
    
    func decreaseVariantCount(index :Int) {
        if product!.variants[index].quantity > 0 {
            product!.variants[index].quantity -= 1
            product!.quantity -= 1
        }
    }
    
    func increaseVariantCount(index :Int) {
        product!.variants[index].quantity += 1
        product!.quantity += 1
    }
}

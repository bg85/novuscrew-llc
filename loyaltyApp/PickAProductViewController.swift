	//
//  PickAProductViewController.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/6/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit
import Buy

class PickAProductViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productQtyLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var sliderScrollView: UIScrollView!
    @IBOutlet weak var productNameBackgroundLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var extra = CGFloat(8)
    var allVariants :[BUYProductVariant]? = nil
    var products :[PProduct]? = nil
    var productList :[(product:BUYProduct, variants:[PProduct], quantity:Int, price:Double, image:UIImage?)]? = nil
    var updatedProduct :(product:BUYProduct, variants:[PProduct], quantity:Int, price:Double, image:UIImage?)? = nil
    
    var totalSelectedProducts = 0
    var totalCostProducts = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBackClick(sender: UIButton) {
    }
    
    @IBAction func addProductClick(sender: UIButton) {
        if (productList![pageControl.currentPage].variants.count > 1) {
            self.performSegueWithIdentifier("variantsSegue", sender: self)
        } else {
            productList![pageControl.currentPage].quantity += 1
            productList![pageControl.currentPage].variants[0].quantity += 1
            totalSelectedProducts += 1
            totalCostProducts += Double(productList![pageControl.currentPage].price)
            productQtyLabel.text = "\(productList![pageControl.currentPage].quantity)"
            updateSummary()
        }
    }
    
    @IBAction func removeProductClick(sender: UIButton) {
        if productList![pageControl.currentPage].quantity > 0 {
            if (productList![pageControl.currentPage].variants.count > 1) {
                self.performSegueWithIdentifier("variantsSegue", sender: self)
            } else {
                productList![pageControl.currentPage].quantity -= 1
                productList![pageControl.currentPage].variants[0].quantity -= 1
                totalSelectedProducts -= 1
                totalCostProducts -= Double(productList![pageControl.currentPage].price)
                productQtyLabel.text = "\(productList![pageControl.currentPage].quantity)"
                updateSummary()
            }
        }
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        productNameLabel.alpha = 0
        productNameBackgroundLabel.alpha = 0
        productQtyLabel.alpha = 0
        productPriceLabel.alpha = 0
        minusButton.alpha = 0
        plusButton.alpha = 0
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = getCurrentPage()
        showProduct(pageControl.currentPage)
        UIView.animateWithDuration(0.5, animations: {
            self.productNameLabel.alpha = 1.0
            self.productNameBackgroundLabel.alpha = 0.6
            self.productQtyLabel.alpha = 0.5
            self.productPriceLabel.alpha = 0.75
            self.minusButton.alpha = 0.75
            self.plusButton.alpha = 0.75
        })
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "addressSegue" && totalSelectedProducts == 0) {
                let shared = appDelegate.factory.getShared()
                shared.showAlert("Must select products", message: "In order to go to the next step you must select at least one product", viewController: self, handler: { (action) -> Void in
                    return false
                })
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "addressSegue")
        {
            let destinationController = segue.destinationViewController as! AddressViewController
            destinationController.products = selectedProducts()
            destinationController.totalCostProducts = totalCostProducts
            destinationController.totalSelectedProducts = totalSelectedProducts
        } else if (segue.identifier == "variantsSegue")
        {
            let destinationController = segue.destinationViewController as! VariantViewController
            destinationController.product = productList![pageControl.currentPage]
            updatedProduct = nil
        }
    }
    
    func updateCurrentProduct(product: (product:BUYProduct, variants:[PProduct], quantity:Int, price:Double, image:UIImage?)?) {
        if let updatedProduct = product {
            productList![pageControl.currentPage] = updatedProduct
            productQtyLabel.text = "\(updatedProduct.quantity)"
            updateTotals()
            updateSummary()
        }
    }
    
    func updateTotals() {
        totalSelectedProducts = 0
        totalCostProducts = 0.00
        for product in productList! {
            for variant in product.variants {
                totalSelectedProducts += Int(variant.quantity)
                totalCostProducts += (Double(variant.quantity) * variant.variant!.price.doubleValue)
            }
        }
    }
    
    private func getCurrentPage() -> Int {
        return Int(round(self.sliderScrollView.contentOffset.x / (self.view.frame.width + extra)))
    }
    
    private func initialize() {
        totalSelectedProducts = 0
        totalCostProducts = 0.00
        
        let deviceType = UIDevice().type
        if deviceType == Model.iPhone6plus || deviceType == Model.iPhone6Splus { //|| deviceType == Model.simulator {
            extra = CGFloat(0)
        }
        
        buildProductList()
        loadImages()
        
        if appDelegate.profile!.usingLazyButton {
            updateSelectedProducts()
        }
        
        pageControl.numberOfPages = self.productList!.count
        pageControl.currentPage = 0
        showProduct(0);
        
        updateSummary()
    }
    
    private func buildProductList(){
        var prodDictionary = [Int64: [PProduct]]()
        
        for variant in allVariants! {
            let productId = variant.product.identifier.longLongValue
            let newVariant = PProduct(variant: variant, baseProduct:nil)
            
            if let _ = prodDictionary[productId] {
                prodDictionary[productId]!.append(newVariant)
            } else {
                prodDictionary[productId] = [newVariant]
            }
            
            self.totalSelectedProducts += Int(newVariant.quantity)
            self.totalCostProducts += Double(newVariant.quantity) * newVariant.variant!.price.doubleValue
        }
        
        self.productList = prodDictionary.keys.map({ (key) -> (BUYProduct, [PProduct], Int, Double, UIImage?) in
            let variants = prodDictionary[key]!
            return (variants[0].variant!.product, variants,
                variants.reduce(0, combine: { (initial, product) -> Int in
                    return initial + Int(product.quantity)
                }),
                variants.count == 1 ? variants[0].variant!.price.doubleValue : 0.00, nil)
        })
    }
    
    private func addProductToSlider(slider :UIScrollView, productIndex:Int)
    {
        if productIndex < self.productList!.count {
            let product = self.productList![productIndex]
            if product.product.images.count > 0 {
                let image = UIImageView(frame: CGRectMake(CGFloat(productIndex) * (self.view.frame.width + extra), 0, self.view.frame.width + extra, slider.frame.height))
                image.downloadedFrom(link: product.product.images[0].src, contentMode: UIViewContentMode.ScaleToFill, image: product.image, callback: { (image) -> Void in
                    self.productList![productIndex].image = image
                })
                slider.addSubview(image)
            }
        }
    }
    
    private func loadImages(){
        sliderScrollView.pagingEnabled = true
        sliderScrollView.showsHorizontalScrollIndicator = false
        sliderScrollView.delegate = self
        
        for index in 0...self.productList!.count - 1 {
            addProductToSlider(sliderScrollView, productIndex: index)
        }
        
        sliderScrollView.contentSize = CGSizeMake((self.view.frame.width + extra) * CGFloat(self.productList!.count)
            , sliderScrollView.frame.height)
    }
    
    private func updateSelectedProducts() {
        for selected in products! {
            for productIndex in 0 ... productList!.count - 1 {
                let variants = productList![productIndex].variants
                for variantIndex in 0 ... variants.count - 1 {
                    if variants[variantIndex].productId == selected.productId {
                        self.productList![productIndex].variants[variantIndex].quantity = selected.quantity
                        self.productList![productIndex].quantity += Int(selected.quantity)
                        self.totalSelectedProducts += Int(selected.quantity)
                        self.totalCostProducts += Double(selected.quantity) * variants[variantIndex].variant!.price.doubleValue
                    }
                }
            }
        }
    }
    
    private func showProduct(index :Int) {
        if index < productList?.count {
            let shared = appDelegate.factory.getShared()
            
            let product = self.productList![index]
            productNameLabel.text = product.product.title
            productPriceLabel.text = product.price > 0 ? "$\(shared.formatNumber(product.price))" : "..."
            productQtyLabel.text = "\(product.quantity)"
        }
    }
    
    private func updateSummary(){
        let shared = appDelegate.factory.getShared()
        
        totalPriceLabel.text = "$\(shared.formatNumber(totalCostProducts))"
        totalCountLabel.text = "\(totalSelectedProducts)"
    }

    private func selectedProducts() -> [PProduct]{
        return productList!.flatMap({ (product) -> [PProduct] in
            return product.variants
        }).filter { (product) -> Bool in
            product.quantity > 0
        }
    }

    @IBAction func backToPickProductViewController(segue:UIStoryboardSegue) {
        if updatedProduct != nil {
            updateCurrentProduct(updatedProduct!)
            updatedProduct = nil
        }
    }
}

//
//  ProductViewController.swift
//  E-chase
//
//  Created by Parth Saxena on 2/4/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var imageNavigationItem: UINavigationItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productLocationLabel: UILabel!
    @IBOutlet weak var locationPhoneLabel: UILabel!
    @IBOutlet weak var locationAddressLabel: UILabel!
    @IBOutlet weak var availablityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProductDetails()
        
        self.tabBar.tintColor = UIColor(red: 49/255, green: 146/255, blue: 210/255, alpha: 1.0)
        self.tabBar.selectedItem = self.tabBar.items?[0]
        tabBar.delegate = self
        
        self.imageNavigationItem.title = "Product"
        self.navigationBar.alpha = 1
        self.navigationBar.barTintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto-Light", size: 24)!, NSForegroundColorAttributeName: UIColor.init(red: 49/255, green: 146/255, blue: 210/255, alpha: 1)]
        // Do any additional setup after loading the view.
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            // we're here
        } else if item.tag == 1 {
            
        } else if item.tag == 2 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CartVC")
            self.present(vc!, animated: false, completion: nil)
        }
    }
    
    func loadProductDetails() {
        if let productBundle = GlobalVariables.productViewing {
            if let product = productBundle.first as? [String: AnyObject] {
                if let title = product["title"] as? String {
                    if let priceDouble = product["price"] as? Double {
                        if let imageURL = product["image"] as? String {
                            // got all values
                            productTitleLabel.text = title
                            productPriceLabel.text = "$\(String(format:"%.2f", priceDouble))"
                            productImageView.sd_setImage(with: NSURL(string: imageURL) as URL!)
                        } else {
                            // couldn't get image value
                            productTitleLabel.text = title
                            productPriceLabel.text = "$\(String(format:"%.2f", priceDouble))"
                            productImageView.image = UIImage(named: "image-not-available")
                        }
                    }
                }
            }
            if let location = productBundle[1] as? [String: AnyObject] {
                guard let phone = location["phone"] as? String else {
                    let alert = UIAlertController(title: "Sorry!", message: "There was an issue processing your request. If this issue persists, please contact support.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
                        self.present(vc!, animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                guard let address = location["address"] as? String else {
                    let alert = UIAlertController(title: "Sorry!", message: "There was an issue processing your request. If this issue persists, please contact support.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
                        self.present(vc!, animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                guard let city = location["city"] as? String else {
                    let alert = UIAlertController(title: "Sorry!", message: "There was an issue processing your request. If this issue persists, please contact support.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
                        self.present(vc!, animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                guard let state = location["state"] as? String else {
                    let alert = UIAlertController(title: "Sorry!", message: "There was an issue processing your request. If this issue persists, please contact support.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
                        self.present(vc!, animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                guard let name = productBundle[2] as? String else {
                    let alert = UIAlertController(title: "Sorry!", message: "There was an issue processing your request. If this issue persists, please contact support.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
                        self.present(vc!, animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                let addressLabel = "\(address), \(city), \(state)"
                self.locationPhoneLabel.text = phone
                self.locationAddressLabel.text = addressLabel
                self.availablityLabel.text = "Available through \(name)."
            }
        }
    }
    
    @IBAction func addToCartTapped(_ sender: Any) {
        
        print("Adding product to cart")
        
        let product = GlobalVariables.productViewing
        if let p = GlobalVariables.productsInCart {
            GlobalVariables.productsInCart?.append(product as AnyObject)
        } else {
            // value hasn't been initialized yet
            GlobalVariables.productsInCart = [product as AnyObject]
        }
        
        let alert = UIAlertController(title: "Item Added to Cart!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//
//  CartTableViewController.swift
//  E-chase
//
//  Created by Parth Saxena on 2/4/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import UIKit

class CartTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    var cartItems = NSMutableArray()
    @IBOutlet weak var cartTableView: UITableView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var imageNavigationItem: UINavigationItem!
    
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    var subtotal = 0.00
    var fee = 0.00
    var tax = 0.00
    var total = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.tintColor = UIColor(red: 49/255, green: 146/255, blue: 210/255, alpha: 1.0)
        self.tabBar.selectedItem = self.tabBar.items?[2]
        tabBar.delegate = self
        
        self.imageNavigationItem.title = "Cart"
        self.navigationBar.alpha = 1
        self.navigationBar.barTintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto-Light", size: 24)!, NSForegroundColorAttributeName: UIColor.init(red: 49/255, green: 146/255, blue: 210/255, alpha: 1)]
        
        cartTableView.delegate = self
        cartTableView.dataSource = self
        loadCartProducts()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
            self.present(vc!, animated: false, completion: nil)
        } else if item.tag == 1 {
            
        } else if item.tag == 2 {
            // we're here
        }
    }
    
    func loadCartProducts() {
        if let products = GlobalVariables.productsInCart {
            for productBundleBefore in GlobalVariables.productsInCart! {
                if let productBundle = productBundleBefore as? [AnyObject] {
                    if let product = productBundle.first as? [String: AnyObject] {
                        self.cartItems.add(product)
                        if let priceDouble = product["price"] as? Double {
                            subtotal += priceDouble
                        }
                    }
                }
            }
            
            if subtotal <= 20.00 {
                fee = 5.99
            } else {
                fee = 4.99
            }
            subtotal = round(100.0 * subtotal) / 100.0
            tax = (subtotal/100) * 10
            tax = round(100.0 * tax) / 100.0
            total = subtotal + tax + fee
            
            self.subtotalLabel.text = "$\(String(format:"%.2f", subtotal))"
            self.taxLabel.text = "$\(String(format:"%.2f", tax))"
            self.feeLabel.text = "$\(String(format:"%.2f", fee))"
            self.totalLabel.text = "$\(String(format:"%.2f", total))"
            
        } else {
            print("no products in cart")
        }
        cartTableView.reloadData()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.cartItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CartItemTableViewCell
        // Configure the cell...

        let product = self.cartItems[indexPath.row] as? [String: AnyObject]
        let title = product?["title"] as? String
        if let priceDouble = product?["price"] as? Double {
            if let imageURL = product?["image"] as? String {
                // got all values
                cell?.productTitleLabel.text = title
                cell?.productPriceLabel.text = "$\(String(format:"%.2f", priceDouble))"
                cell?.productImageView.sd_setImage(with: NSURL(string: imageURL) as URL!)
            } else {
                // couldn't get image value
                
                cell?.productTitleLabel.text = title
                cell?.productPriceLabel.text = "$\(String(format:"%.2f", priceDouble))"
                cell?.productImageView.image = UIImage(named: "image-not-available")
            }
        }
        
        return cell!
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

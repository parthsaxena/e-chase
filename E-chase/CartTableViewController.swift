//
//  CartTableViewController.swift
//  E-chase
//
//  Created by Parth Saxena on 2/4/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

class CartTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    var cartItems = NSMutableArray()
    @IBOutlet weak var cartTableView: UITableView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var imageNavigationItem: UINavigationItem!
    
    @IBOutlet weak var subtotalText: UILabel!
    @IBOutlet weak var taxText: UILabel!
    @IBOutlet weak var feeText: UILabel!
    @IBOutlet weak var totalText: UILabel!
    
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var checkoutButton: UIButton!
    
    @IBOutlet weak var emptyCartLabel: UILabel!
    
    var subtotal = 0.00
    var fee = 0.00
    var tax = 0.00
    var total = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.tintColor = UIColor(red: 49/255, green: 146/255, blue: 210/255, alpha: 1.0)
        self.tabBar.selectedItem = self.tabBar.items?[2]
        tabBar.delegate = self
        
        self.navigationController?.navigationItem.title = "Cart"
        self.navigationController?.navigationBar.alpha = 1
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto-Light", size: 24)!, NSForegroundColorAttributeName: UIColor.init(red: 49/255, green: 146/255, blue: 210/255, alpha: 1)]
        
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
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrdersVC")
            self.present(vc!, animated: false, completion: nil)
        } else if item.tag == 2 {
            // we're here
        } else if item.tag == 3 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AccountVC")
            self.present(vc!, animated: false, completion: nil)
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
            
            if self.cartItems.count > 1 {
                fee += Double(self.cartItems.count) * 2.0
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
            
            self.checkoutButton.isEnabled = false
            self.checkoutButton.alpha = 0
            self.subtotalText.alpha = 0
            self.taxText.alpha = 0
            self.feeText.alpha = 0
            self.totalText.alpha = 0
            self.subtotalLabel.alpha = 0
            self.taxLabel.alpha = 0
            self.feeLabel.alpha = 0
            self.totalLabel.alpha = 0
            
            self.emptyCartLabel.alpha = 1
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

    @IBAction func checkoutTapped(sender: Any) {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you would like to checkout these items?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let userDictionary = snapshot.value as? [String: Any] {
                        if let address = userDictionary["address"] as? String {
                            if address == "" {
                                let alert = UIAlertController(title: "Add Street Address", message: "You need to add a street address for deliveries.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddAddressVC")
                                    self.navigationController?.present(vc!, animated: false, completion: nil)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                // user has address, we can continue to make the delivery
                                let data = try! JSONSerialization.data(withJSONObject: GlobalVariables.productsInCart!, options: [])
                                let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                                if let uid = FIRAuth.auth()?.currentUser?.uid {
                                    let ref = FIRDatabase.database().reference().child("orders").childByAutoId()
                                    let key = ref.key
                                    ref.setValue(["json":GlobalVariables.productsInCart!, "uid":uid, "id":key, "active":"true", "courierUID":"", "orderTaken":"false"])
                                    
                                    let locationRef = GeoFire(firebaseRef: FIRDatabase.database().reference().child("orders_locations"))
                                    locationRef?.setLocation(GlobalVariables.location, forKey: key, withCompletionBlock: { (error) in
                                        if error != nil {
                                            print("An error occurred while saving the location of the order, \(error?.localizedDescription)")
                                            let alert = UIAlertController(title: "Error", message: "There was an issue while processing your order...", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                            self.present(alert, animated: true, completion: nil)
                                        } else {
                                            print("Saved post location")
                                        }
                                    })
                                    
                                    let alert = UIAlertController(title: "Awesome!", message: "Your order has been placed. Track your order through the orders page.", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrdersVC")
                                        self.present(vc!, animated: false, completion: nil)
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        } else {
                            // address does not exist, present alert
                            let alert = UIAlertController(title: "Add Street Address", message: "You need to add a street address for deliveries.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddAddressVC")
                                self.navigationController?.present(vc!, animated: false, completion: nil)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                })
            }
        }))
        self.present(alert, animated: true, completion: nil)
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

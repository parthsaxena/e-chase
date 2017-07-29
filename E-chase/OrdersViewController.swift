//
//  OrdersViewController.swift
//  E-chase
//
//  Created by Parth Saxena on 2/14/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import UIKit
import Firebase
import GradientCircularProgress

class OrdersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

    var orders = NSMutableArray()
    @IBOutlet weak var ordersTableView: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var blurEffectView: UIVisualEffectView!
    var progress: GradientCircularProgress!
    
    override func viewDidLoad() {
        super.viewDidLoad()                        
        
        progress = GradientCircularProgress()
        DispatchQueue.main.async {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
            self.blurEffectView = UIVisualEffectView(effect: blurEffect)
            self.blurEffectView.frame = self.view.bounds
            self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(self.blurEffectView)
            self.progress.show(style: LoadingStyle())
        }
        
        ordersTableView.delegate = self
        ordersTableView.dataSource = self
        
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items?[1]

        loadData()
        
        self.navigationController?.navigationItem.title = "Orders"
        self.navigationController?.navigationBar.alpha = 1
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto-Light", size: 24)!, NSForegroundColorAttributeName: UIColor.init(red: 49/255, green: 146/255, blue: 210/255, alpha: 1)]
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("TabBarItem selected, tag: \(item.tag)")
        if item.tag == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
            self.present(vc!, animated: false, completion: nil)
        } else if item.tag == 1 {
            // we're here
        } else if item.tag == 2 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CartVC")
            self.present(vc!, animated: false, completion: nil)
        } else if item.tag == 3 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AccountVC")
            self.present(vc!, animated: false, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.orders.count
    }

    func loadData() {
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            FIRDatabase.database().reference().child("orders").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let ordersDictionary = snapshot.value as? [String: Any] {
                    self.ordersTableView.isHidden = false
                    for order in ordersDictionary {
                        if let orderValue = order.value as? [String: Any] {
                            if let active = orderValue["active"] as? String {
                                if active == "true" {
                                    self.orders.add(order.value)
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.ordersTableView.reloadData()
                        self.progress.dismiss()
                        UIView.animate(withDuration: 0.25, animations: {
                            self.blurEffectView.effect = nil
                        }, completion: { (success) in
                            self.blurEffectView.removeFromSuperview()
                        })
                    }
                } else {
                    print("no orders")
                    DispatchQueue.main.async {
                        self.ordersTableView.reloadData()
                        self.progress.dismiss()
                        UIView.animate(withDuration: 0.25, animations: {
                            self.blurEffectView.effect = nil
                            self.emptyLabel.alpha = 1
                        }, completion: { (success) in
                            self.blurEffectView.removeFromSuperview()
                        })
                    }
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! OrderTableViewCell
        // Configure the cell...
        
        let order = self.orders[indexPath.row] as? [String: Any]
        if order?["orderTaken"] as? String == "false" {
            // order is processing
            cell.statusLabel.text = "Order Received"
        } else if order?["orderTaken"] as? String == "true" {
            // order has driver
            cell.statusLabel.text = "Driver En Route"
        }
        if let json = order?["json"] as? [Any] {
            let count = json.count
            if count == 1 {
                cell.itemsLabel.text = "\(count) item"
            } else {
                cell.itemsLabel.text = "\(count) items"
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = self.orders[indexPath.row] as? [String: Any]
        if let orderID = order?["id"] as? String {
            GlobalVariables.orderViewingID = orderID
        }
        self.navigationController?.performSegue(withIdentifier: "OrdersToOrder", sender: nil)
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

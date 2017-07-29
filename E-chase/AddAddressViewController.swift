//
//  AddAddressViewController.swift
//  E-chase
//
//  Created by Parth Saxena on 2/13/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class AddAddressViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKLocalSearchCompleterDelegate, UITextFieldDelegate, UITabBarDelegate {

    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var tabBar: UITabBar!
    
    var searchResults = [MKLocalSearchCompletion]()
    var searchCompleter: MKLocalSearchCompleter!
    var textAutoChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items?[3]
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        getAddress()
        
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter.delegate = self
        
        self.resultsTableView.layer.borderColor = UIColor(red: 184/255, green: 184/255, blue: 184/255, alpha: 1.0).cgColor
        self.resultsTableView.layer.borderWidth = 0.5
        
        self.navigationController?.navigationItem.title = "Add Address"
        self.navigationController?.navigationBar.alpha = 1
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto-Light", size: 24)!, NSForegroundColorAttributeName: UIColor.init(red: 49/255, green: 146/255, blue: 210/255, alpha: 1)]
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func getAddress() {
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let userDictionary = snapshot.value as? [String: Any] {
                    if let address = userDictionary["address"] as? String {
                        if address != "" {
                            self.addressTextField.text = address
                        } else {
                            // no address
                            self.addressTextField.becomeFirstResponder()
                        }
                    }
                }
            })
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("TabBarItem selected, tag: \(item.tag)")
        if item.tag == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
            self.present(vc!, animated: false, completion: nil)
        } else if item.tag == 1 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrdersVC")
            self.present(vc!, animated: false, completion: nil)
        } else if item.tag == 2 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CartVC")
            self.present(vc!, animated: false, completion: nil)
        } else if item.tag == 3 {
            // we're here
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
        if searchResults.count == 0 {
            // no results
            self.resultsTableView.isHidden = true
        } else {
            // there are results
            self.resultsTableView.isHidden = false
        }
        
        return self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AddressTableViewCell
        
        let searchResult = self.searchResults[indexPath.row]
        cell.addressLabel.text = searchResult.title

        return cell
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        self.resultsTableView.reloadData()
        
        if searchResults.count < 5 {
            var frame = self.resultsTableView.frame
            frame.size = self.resultsTableView.contentSize
            self.resultsTableView.frame = frame
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.resultsTableView.isHidden = true
        self.textAutoChanged = true
        let searchResult = self.searchResults[indexPath.row]
        self.addressTextField.text = searchResult.title
        self.resultsTableView.deselectRow(at: indexPath, animated: false)
        let searchQuery = self.addressTextField.text
        searchCompleter.queryFragment = searchQuery!
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        if self.resultsTableView.isHidden {
            if self.textAutoChanged == false {
                self.resultsTableView.isHidden = true
                self.textAutoChanged = false
            } else {
                self.textAutoChanged = false
            }
        }
        let searchQuery = self.addressTextField.text
        searchCompleter.queryFragment = searchQuery!
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.performSegue(withIdentifier: "AddressToAccount", sender: nil)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        if let addressText = self.addressTextField.text, let uid = FIRAuth.auth()?.currentUser?.uid {
            FIRDatabase.database().reference().child("users").child(uid).updateChildValues(["address":addressText])
            print("Updated address of user.")
            
            let alert = UIAlertController(title: "Awesome!", message: "We've added that address to your account.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                if GlobalVariables.noAddress {
                    // go to home
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
                    self.present(vc!, animated: false, completion: nil)
                } else {
                    // go back to account
                    self.navigationController?.performSegue(withIdentifier: "AddressToAccount", sender: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelTapped(sender: Any) {
        if GlobalVariables.noAddress {
            // go to home
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
            self.present(vc!, animated: false, completion: nil)
        } else {
            // go back to account
            self.navigationController?.performSegue(withIdentifier: "AddressToAccount", sender: nil)
        }
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

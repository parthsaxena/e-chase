//
//  AccountViewController.swift
//  E-chase
//
//  Created by Parth Saxena on 2/11/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AccountViewController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.delegate = self
        self.tabBar.tintColor = UIColor(red: 49/255, green: 146/255, blue: 210/255, alpha: 1.0)
        tabBar.selectedItem = tabBar.items?[3]
        
        getUserData()
        
        self.navigationController?.navigationItem.title = "Account"
        self.navigationController?.navigationBar.alpha = 1
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto-Light", size: 24)!, NSForegroundColorAttributeName: UIColor.init(red: 49/255, green: 146/255, blue: 210/255, alpha: 1)]
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUserData() {
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let userDictionary = snapshot.value as? [String: Any] {
                    if let fullName = userDictionary["fullname"] as? String {
                        self.fullNameLabel.text = fullName
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

    @IBAction func addressesTapped(_ sender: Any) {
        self.navigationController?.performSegue(withIdentifier: "AccountToAddress", sender: nil)
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you would like to log out? You will be required to log in again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            // log out
            try! FIRAuth.auth()?.signOut()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC")
            self.present(vc!, animated: false, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.view.tintColor = UIColor.red
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

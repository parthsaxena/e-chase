//
//  ViewProductsTableViewController.swift
//  E-chase
//
//  Created by Parth Saxena on 1/8/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import UIKit
import CoreLocation

class ViewProductsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UITabBarDelegate {
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var imageNavigationItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    var products = NSMutableArray()
    
    let locationManager = CLLocationManager()
    
    var foundPlaces = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.tintColor = UIColor(red: 49/255, green: 146/255, blue: 210/255, alpha: 1.0)
        self.tabBar.selectedItem = self.tabBar.items?[0]
        tabBar.delegate = self
        
        // request authorization for location
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        // place logo on navigation bar
        /*let logo = UIImage(named: "logo")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        imageView.image = logo
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        self.imageNavigationItem.titleView = imageView*/
        
        self.imageNavigationItem.title = "Search"
        self.navigationBar.alpha = 1
        self.navigationBar.barTintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto-Light", size: 24)!, NSForegroundColorAttributeName: UIColor.init(red: 49/255, green: 146/255, blue: 210/255, alpha: 1)]
        
        self.searchLabel.text = "Search Results for \"\(GlobalVariables.SEARCH_QUERY)\""
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let keyword = GlobalVariables.SEARCH_QUERY
        
        if !foundPlaces {
            foundPlaces = true
            searchKeyword(keyword: keyword, coordinate: locValue, radius: 5.0)
        }
    }
    
    func searchKeyword(keyword: String, coordinate: CLLocationCoordinate2D, radius: Double) {
        print("Searching keyword")
        let finalKeyword = keyword.replacingOccurrences(of: " ", with: "+")
        let urlString = "https://api.goodzer.com/products/v0.1/search_stores/?query=\(finalKeyword)&lat=\(coordinate.latitude)&lng=\(coordinate.longitude)&radius=\(radius)&apiKey=\(GlobalVariables.API_KEY)"
        print(urlString)
        
        var request = URLRequest(url: NSURL(string: urlString)! as URL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil && data != nil else {
                print("error = \(error)")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options:[]) as? NSDictionary {
                    if let stores = json["stores"] as? [AnyObject] {
                        for place:AnyObject in stores {
                            guard let name = place["name"] as? String else {
                                return
                            }
                            if let products = place["products"] as? [AnyObject] {
                                for product in products {
                                    if let locations = place["locations"] as? [AnyObject] {
                                        let location = locations.first
                                        let obj = [product, location!, name as AnyObject] as [AnyObject]
                                        self.products.add(obj)
                                    }
                                }
                            } else {
                                print("Couldn't cast, \(place["products"])")
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } else {
                        print("Couldn't cast, \(json["stores"])")
                    }
                }
            } catch {
                //handle error
                print("Error serializing JSON")
            }
        }
        task.resume()
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
        return self.products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProductTableViewCell
        // Configure the cell...

        print("Configuring cell")
        
        if let productBundle = self.products[indexPath.row] as? [AnyObject] {
            if let product = productBundle.first as? [String: AnyObject] {
                if let title = product["title"] as? String {
                    if let priceDouble = product["price"] as? Double {
                        if let imageURL = product["image"] as? String {
                            // got all values
                            cell.titleLabel.text = title
                            cell.priceLabel.text = "$\(String(format:"%.2f", priceDouble))"
                            cell.productImageView.sd_setImage(with: NSURL(string: imageURL) as URL!)
                        
                            UIView.animate(withDuration: 0.5, animations: {
                                cell.titleLabel.alpha = 1
                                cell.priceLabel.alpha = 1
                                cell.productImageView.alpha = 1
                            })
                        } else {
                            // couldn't get image value                            
                            cell.titleLabel.text = title
                            cell.priceLabel.text = "$\(String(format:"%.2f", priceDouble))"
                            cell.productImageView.image = UIImage(named: "image-not-available")
                        
                            UIView.animate(withDuration: 0.5, animations: {
                                cell.titleLabel.alpha = 1
                                cell.priceLabel.alpha = 1
                                cell.productImageView.alpha = 1
                            })
                        }
                    }
                }
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let product = self.products[indexPath.row] as? [AnyObject] {
            GlobalVariables.productViewing = product
            self.performSegue(withIdentifier: "ProductTappedToViewProduct", sender: nil)
        } else {
            let alert = UIAlertController(title: "Sorry!", message: "There was an error processing your request. Please contact support if this issue persists.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alert.view.tintColor = UIColor.red
            self.present(alert, animated: true, completion: nil)
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

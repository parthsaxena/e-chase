//
//  ViewOrderViewController.swift
//  E-chase
//
//  Created by Parth Saxena on 7/26/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import M13Checkbox

class ViewOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UITabBarDelegate {

    var items = NSMutableArray()
    @IBOutlet weak var driverMapView: MKMapView!
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var orderStatusImageView: UIImageView!
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        
        let image = UIImage(named: "refresh")?.withRenderingMode(.alwaysOriginal)
        refreshButton.image = image
        
        itemsTableView.delegate = self
        itemsTableView.dataSource = self        
        
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items?[1]
        
        driverMapView.mapType = .standard
        driverMapView.isZoomEnabled = true
        driverMapView.isScrollEnabled = true
        driverMapView.delegate = self
        
        self.navigationController?.navigationItem.title = "Order"
        self.navigationController?.navigationBar.alpha = 1
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto-Light", size: 24)!, NSForegroundColorAttributeName: UIColor.init(red: 49/255, green: 146/255, blue: 210/255, alpha: 1)]
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        self.items.removeAllObjects()
        loadData()
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
    
    func loadData() {        
        FIRDatabase.database().reference().child("orders").child(GlobalVariables.orderViewingID).observeSingleEvent(of: .value,with: { (snapshot) in
            if let orderDictionary = snapshot.value as? [String: Any] {
                // UPDATE MAP
                if orderDictionary["orderTaken"] as? String == "true" {
                    // order has been taken, update map
                    // get latitude and longitude values
                    
                    if orderDictionary["delivered"] as? String == "true" {
                        self.orderStatusLabel.text = "Delivered"
                    } else {
                        self.orderStatusLabel.text = "Driver En Route"
                    }
                    
                    if let latitudeValue = orderDictionary["driverLatitude"] as? CGFloat, let longitudeValue = orderDictionary["driverLongitude"] as? CGFloat {
                        let driverLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitudeValue), longitude: CLLocationDegrees(longitudeValue))
                        let region = MKCoordinateRegion(center: driverLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        
                        self.driverMapView.setRegion(region, animated: true)
                        self.driverMapView.removeAnnotations(self.driverMapView.annotations)
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = driverLocation
                        annotation.title = "Location"
                        self.driverMapView.addAnnotation(annotation)
                        
                        print("Updated map.")
                    }
                } else {
                    self.orderStatusLabel.text = "Order Processing"
                }
                
                // GET ITEMS
                if let itemsArray = orderDictionary["json"] as? NSArray {
                    var i = 0
                    for itemRaw in itemsArray {
                        var itemPickedUp = false
                        if orderDictionary["item\(i)PickedUp"] as? String == "true" {
                            // item has been picked up
                            itemPickedUp = true
                        }
                        if let item = itemRaw as? NSArray {
                            // [0] IS PRODUCT
                            // [1] IS STORE
                            // [2] IS STORE-NAME AS STRING
                            
                            var productValue: [String: Any]!
                            var storeValue: [String: Any]!
                            var storeNameValue: String!
                            
                            if let product = item[0] as? [String: Any] {
                                print(product)
                                productValue = product
                            }
                            if let store = item[1] as? [String: Any] {
                                print(store)
                                storeValue = store
                            }
                            if let storeName = item[2] as? String {
                                print(storeName)
                                storeNameValue = storeName
                            }
                            
                            self.items.add([productValue, storeValue, storeNameValue, itemPickedUp])
                        }
                        i+=1
                    }
                    // LOAD CONTENT ONTO TABLEVIEW
                    self.itemsTableView.reloadData()
                    self.itemsTableView.tableFooterView = UIView()
                }
            }
        })
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
        return self.items.count
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let pinImage = UIImage(named: "annotation")
        annotationView!.image = pinImage
        
        return annotationView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ViewOrderItemsTableViewCell
        // Configure the cell...
        
        let orderItem = self.items[indexPath.row] as? NSArray
        
        if let product = orderItem?[0] as? [String: Any] {
            if let imageAddressString = product["image"] as? String {
                let imageURL = URL(string: imageAddressString)
                let imageData: Data!
                do {
                    try imageData = Data(contentsOf: imageURL!)
                    cell.itemImageView.image = UIImage(data: imageData)
                } catch {
                    // no image available
                    cell.itemImageView.image = UIImage(named: "image-not-available")
                }
            } else {
                // no image available
                cell.itemImageView.image = UIImage(named: "image-not-available")
            }
            if let titleString = product["title"] as? String {
                cell.itemTitleLabel.text = titleString
            }
        }
        
        cell.itemCheckbox.isUserInteractionEnabled = false
        if orderItem?.lastObject as? Bool == true {
            cell.itemCheckbox._IBCheckState = M13Checkbox.CheckState.checked.rawValue
            cell.itemCheckbox.stateChangeAnimation = M13Checkbox.Animation.fade(.fill)
            
            cell.itemStatusLabel.text = "Item Status: Picked Up"
        } else {
            cell.itemCheckbox._IBCheckState = M13Checkbox.CheckState.unchecked.rawValue
            cell.itemCheckbox.stateChangeAnimation = M13Checkbox.Animation.fill
            
            cell.itemStatusLabel.text = "Item Status: Not Yet Picked Up"
        }

        return cell
    }

    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.performSegue(withIdentifier: "OrderToOrders", sender: nil)
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

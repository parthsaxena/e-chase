//
//  MainViewController.swift
//  E-chase
//
//  Created by Parth Saxena on 1/8/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import UIKit
import SDWebImage
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
    
    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var imageNavigationItem: UINavigationItem!
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    let locationManager = CLLocationManager()
    var places = NSMutableArray()
    var products = NSMutableArray()
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
        
        placesTableView.delegate = self
        placesTableView.dataSource = self
        
        // place logo on navigation bar
        /*let logo = UIImage(named: "logo")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        imageView.image = logo
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        self.imageNavigationItem.titleView = imageView*/
        
        self.imageNavigationItem.title = "E-chase"
        self.navigationBar.alpha = 1
        self.navigationBar.barTintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto-Light", size: 24)!, NSForegroundColorAttributeName: UIColor.init(red: 49/255, green: 146/255, blue: 210/255, alpha: 1)]
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("TabBarItem selected, tag: \(item.tag)")
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
        if !foundPlaces {
            foundPlaces = true
            fetchPlacesNearCoordinate(coordinate: locValue, radius: 5000.0, name: "")
        }
    }
    
    func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, name : String){
        //var urlString = "https://api.goodzer.com/products/v0.1/store_locations/?query= %20%20&lat=\(coordinate.latitude)&lng=\(coordinate.longitude)&radius=\(radius)&apiKey=\(GlobalVariables.API_KEY)"
        var baseURL = GlobalVariables.MAPS_LOCATION_QUERY_URL
        var variablesURL = "key=\(GlobalVariables.MAPS_API_KEY)&radius=\(radius)&location=\(coordinate.latitude),\(coordinate.longitude)&type=store"
        var stringURL = baseURL.appending(variablesURL)
        print(stringURL)
        
        var request = URLRequest(url: NSURL(string: stringURL)! as URL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil && data != nil else {
                print("error = \(error)")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but it \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options:[]) as? NSDictionary {
                    if let results = json["results"] as? [AnyObject] {
                        for rawPlace:AnyObject in results {
                            self.places.add(rawPlace)
                        }
                        DispatchQueue.main.async {
                            self.placesTableView.reloadData()
                        }
                    } else {
                        print("Couldn't cast, \(json["locations"])")
                    }
                }
            } catch {
                //handle error
            }
            
            //let responseString = String(data: data!, encoding: String.Encoding.utf8)
            //print("responseString = \(responseString)")
        }
        task.resume()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PlaceTableViewCell
        // Configure the cell...
     
        print("Configuring one cell.")
        
        if let place = self.places[indexPath.row] as? [String: AnyObject] {
            if let name = place["name"] as? String {
                if let photos = (place["photos"] as? [AnyObject])?[0] {
                    if let photoReference = photos["photo_reference"] as? String {
                        let imageURL = "\(GlobalVariables.PHOTO_URL)key=\(GlobalVariables.MAPS_API_KEY)&photoreference=\(photoReference)&maxheight=500"
                        print(imageURL)
                        cell.placeTitleLabel.text = name
                        cell.placeImageView.sd_setImage(with: URL(string: imageURL))
                        UIView.animate(withDuration: 0.5, animations: {
                            cell.placeImageView.alpha = 1
                            cell.placeTitleLabel.alpha = 1
                            cell.placeOpenLabel.alpha = 1
                        })
                    }
                }
            }
        }
        
        return cell
     }
            
    @IBAction func searchTapped(sender: Any) {
        if let searchQuery = self.searchTextField.text {
            GlobalVariables.SEARCH_QUERY = searchQuery
            self.performSegue(withIdentifier: "SearchTappedToViewProducts", sender: nil)
        }
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

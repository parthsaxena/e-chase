//
//  GlobalVariables.swift
//  E-chase
//
//  Created by Parth Saxena on 1/8/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import Foundation

struct GlobalVariables {
    static let API_KEY = "6c9b3cba9a84f288d1ded430ba3bd8c4"
    static let MAPS_API_KEY = "AIzaSyCtgojzsJqo_Rqj_hAklK6-v2rGnMvBSfA"
    static let PHOTO_URL = "https://maps.googleapis.com/maps/api/place/photo?"
    static let MAPS_LOCATION_QUERY_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    static var SEARCH_QUERY = ""
    
    static var productViewing: [AnyObject]!
    static var productsInCart: [AnyObject]?
}

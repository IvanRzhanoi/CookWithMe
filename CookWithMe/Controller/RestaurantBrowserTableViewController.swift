//
//  RestaurantBrowserTableViewController.swift
//  CookWithMe
//
//  Created by Ivan Rzhanoi on 23/09/2018.
//  Copyright © 2018 Ivan Rzhanoi. All rights reserved.
//

import UIKit
import CoreLocation

class RestaurantBrowserTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var currentLocationNavigationItem: UINavigationItem!

    let client_id = "2CTCDE2PRGWACS5CCRDBNI3IGISE51FL2RG5QQEZ54H2XFDP"
    let client_secret = "2YZEVDU1S0431BJB4HEZRBNMUZYCGJ4NT1VG2OHI4KHOODFU"
    
    var searchResults = [JSON]()
    var currentLocation:CLLocationCoordinate2D!
    
    var tags: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        
        // snap to current location
        snapToPlace()
        
        // search for coffee nearby
        searchRestaurants()
    }
    
    
    // MARK: - venues/search endpoint
    
    // https://developer.foursquare.com/docs/venues/search
    func snapToPlace() {
        let url = "https://api.foursquare.com/v2/venues/search?ll=\(currentLocation.latitude),\(currentLocation.longitude)&v=20160607&intent=checkin&limit=1&radius=4000&client_id=\(client_id)&client_secret=\(client_secret)"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, err -> Void in
            
            var currentVenueName:String?
            
            let json = JSON(data: data!)
            currentVenueName = json["response"]["venues"][0]["name"].string
            
            // set label name and visible
            DispatchQueue.main.async {
                if let venue = currentVenueName {
                    self.currentLocationNavigationItem.title = "\(venue)"
                }
//                self.currentLocationLabel.isHidden = false
            }
        })
        
        task.resume()
    }
    
    // MARK: - search/recommendations endpoint
    
    // https://developer.foursquare.com/docs/search/recommendations
    func searchRestaurants() {
        // TODO: Implement search by all the tags
        tags[0] = "ChineseRestaurant"
        
        let url = "https://api.foursquare.com/v2/search/recommendations?ll=\(currentLocation.latitude),\(currentLocation.longitude)&v=20160607&intent=\(tags[0])&limit=15&client_id=\(client_id)&client_secret=\(client_secret)"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, err -> Void in
            
            let json = JSON(data: data!)
            self.searchResults = json["response"]["group"]["results"].arrayValue
            
            DispatchQueue.main.async {
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        })
        
        task.resume()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Set up the RestaurantBrowserCells with data from the searchResults array
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell") as! RestaurantBrowserTableViewCell
        
        cell.title.text = searchResults[(indexPath as NSIndexPath).row]["venue"]["name"].string
//        cell.rating.text = String(format: "%.1f", searchResults[(indexPath as NSIndexPath).row]["venue"]["rating"].doubleValue) + "⭐️"
//        cell.distance.text = "\(searchResults[(indexPath as NSIndexPath).row]["venue"]["location"]["distance"].intValue)m"
//        cell.address.text = searchResults[(indexPath as NSIndexPath).row]["venue"]["location"]["address"].string
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show the DetailController
        performSegue(withIdentifier: "toRestaurantLocation", sender: self)
    }


    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check if segue is to the DetailsController
        if segue.identifier == "toRestaurantLocation" {
            
            let destinationViewController = segue.destination as! RestaurantMapViewController
            let selectedCell = tableView.indexPathForSelectedRow!
            
            // Set the title on the details controller and deselect tableview cell
            destinationViewController.venueName = searchResults[(selectedCell as NSIndexPath).row]["venue"]["name"].string
            let latitude = searchResults[(selectedCell as NSIndexPath).row]["venue"]["location"]["lat"].doubleValue
            let longitude = searchResults[(selectedCell as NSIndexPath).row]["venue"]["location"]["lng"].doubleValue
            destinationViewController.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            destinationViewController.venueId = searchResults[(selectedCell as NSIndexPath).row]["venue"]["id"].stringValue
            
            tableView.deselectRow(at: selectedCell, animated: false)
        }
    }
}

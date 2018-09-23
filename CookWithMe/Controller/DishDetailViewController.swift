//
//  DishDetailViewController.swift
//  CookWithMe
//
//  Created by Ivan Rzhanoi on 22/09/2018.
//  Copyright © 2018 Ivan Rzhanoi. All rights reserved.
//

import UIKit
import FirebaseStorage
import CoreLocation


fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class DishDetailViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var dishNameNavigationItem: UINavigationItem!
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var dishTagsLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var instructionsTextView: UITextView!
    
    var dish: Dish!
    var dishImage: UIImage!
    
    let locationManager = CLLocationManager()
    var currentLocation:CLLocationCoordinate2D!
    var flag = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Downloading full image again, because the previous one was cropped 16:9
        let reference = Storage.storage().reference(forURL: dish.imageReference)
        reference.getData(maxSize: 1000000, completion: { (data, error) in
            if error != nil {
                print("We couldn't download the image")
            } else {
                if let imageData = data {
                    if let image = UIImage(data: imageData) {
                        self.dishImageView?.image = image
                    }
                }
            }
        })
//        dishImageView.image = dishImage
        
        dishNameNavigationItem.title = dish.name
        dishTagsLabel.text = dish.tags.joined(separator: "")
        difficultyLabel.text = String(dish.difficulty)
        averageRatingLabel.text = String(calculateMedian(array: dish.ratings!))
        ingredientsTextView.text = dish.ingredients.joined(separator: "\n")
        instructionsTextView.text = dish.instructions.joined(separator: "\n")
        
        // set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    // Find where the user is
    func getCurrentLocation() {
        // check if access is granted
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            default:
                showLocationAlert()
            }
        } else {
            showLocationAlert()
        }
    }
    
    // MARK: - Location manager delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // show the activity indicator
        
        if locations.last?.timestamp.timeIntervalSinceNow < -30.0 || locations.last?.horizontalAccuracy > 80 {
            return
        }
        
        // set a flag so segue is only called once
        if flag {
            currentLocation = locations.last?.coordinate
            locationManager.stopUpdatingLocation()
            flag = false
            performSegue(withIdentifier: "toRestaurantBrowser", sender: self)
        }
    }

    func calculateMedian(array: [Float]) -> Float {
        let sorted = array.sorted()
        if sorted.count % 2 == 0 {
            return Float((sorted[(sorted.count / 2)] + sorted[(sorted.count / 2) - 1])) / 2
        } else {
            return Float(sorted[(sorted.count - 1) / 2])
        }
    }
    
    @IBAction func orderFood(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
        flag = true
        getCurrentLocation()
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the latitude and longitude to the new view controller
        if segue.identifier == "toRestaurantBrowser" {
            let destinationViewController = segue.destination as! RestaurantBrowserTableViewController
            destinationViewController.currentLocation = currentLocation
            destinationViewController.tags = dish.ingredients
//            print(currentLocation)
        }
     
    }

    // MARK: - Helpers
    
    func showLocationAlert() {
        let alert = UIAlertController(title: "Location Disabled", message: "Please enable location for CookWithMe", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

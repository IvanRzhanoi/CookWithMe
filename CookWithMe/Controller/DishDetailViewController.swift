//
//  DishDetailViewController.swift
//  CookWithMe
//
//  Created by Ivan Rzhanoi on 22/09/2018.
//  Copyright © 2018 Ivan Rzhanoi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import CoreLocation
import SwiftKeychainWrapper


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


class DishDetailViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    

    @IBOutlet weak var dishNameNavigationItem: UINavigationItem!
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var dishTagsLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var ratingTextField: UITextField!
    
    var dish: Dish!
    var document: DocumentSnapshot!
    var dishImage: UIImage!
    var ratingPicker: UIPickerView!
    
    let locationManager = CLLocationManager()
    var currentLocation:CLLocationCoordinate2D!
    var flag = true
    
    let ratingPickerValues = ["1", "2", "3", "4", "5"]
    
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
        dishTagsLabel.text = dish.tags.joined(separator: " ")
        difficultyLabel.text = String(dish.difficulty)
        averageRatingLabel.text = String(calculateMedian(array: Array(dish.ratings!.values)))
        ingredientsTextView.text = dish.ingredients.joined(separator: "\n")
        instructionsTextView.text = dish.instructions.joined(separator: "\n")
        
        // set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        self.ingredientsTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.ingredientsTextView.layer.borderWidth = 0.3
        self.ingredientsTextView.layer.cornerRadius = 8
        self.instructionsTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.instructionsTextView.layer.borderWidth = 0.3
        self.instructionsTextView.layer.cornerRadius = 8
        
        ratingPicker = UIPickerView()
        ratingPicker.dataSource = self
        ratingPicker.delegate = self
        
        ratingTextField.inputView = ratingPicker
        ratingTextField.text = ratingPickerValues[0]
        
        // Getting the rating given by user earlier
        let db = Firestore.firestore()
        guard let uid = KeychainWrapper.standard.string(forKey: "uid") else {
            displayAlertMessage(messageToDisplay: "Couldn't get your user identification. Maybe you are not logged in")
            return
        }
        
        db.collection("dishes").document(document.documentID).getDocument{ (document, error) in
            if let document = document, document.exists {
                let dataDescription = Dish(dictionary: document.data()!)
                if let rating = dataDescription?.ratings![uid] {
                    self.ratingTextField.text = String(rating)
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ratingPickerValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ratingPickerValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        ratingTextField.text = ratingPickerValues[row]
        self.view.endEditing(true)
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
    
    @IBAction func giveRating(_ sender: Any) {
        guard let uid = KeychainWrapper.standard.string(forKey: "uid") else {
            displayAlertMessage(messageToDisplay: "Couldn't get your user identification. Maybe you are not logged in")
            return
        }
        let db = Firestore.firestore()
        db.collection("dishes").document(document.documentID).setData(["ratings": [uid: Int(ratingTextField.text!)]], merge: true)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the latitude and longitude to the new view controller
        if segue.identifier == "toRestaurantBrowser" {
            let destinationViewController = segue.destination as! RestaurantBrowserTableViewController
            destinationViewController.currentLocation = currentLocation
            destinationViewController.tags = dish.tags
        }
     
    }

    // MARK: - Helpers
    
    func displayAlertMessage(messageToDisplay: String) {
        let alertController = UIAlertController(title: "Alert", message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            // Code in this block will trigger when OK button tapped.
            print("Ok button tapped");
        }
        
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
    func showLocationAlert() {
        let alert = UIAlertController(title: "Location Disabled", message: "Please enable location for CookWithMe", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

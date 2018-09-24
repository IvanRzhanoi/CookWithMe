//
//  DishBrowserTableViewController.swift
//  CookWithMe
//
//  Created by Ivan Rzhanoi on 20/09/2018.
//  Copyright © 2018 Ivan Rzhanoi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SwiftKeychainWrapper

class DishBrowserTableViewController: UITableViewController, FavoriteButtonDelegate {
    
    var database: Firestore!
    var selectedDishDetails: Dish!
    var document: DocumentSnapshot!
    var selectedDishImage: UIImage!
    
    let backgroundView = UIImageView()
    
    private var dishes: [Dish] = []
    private var documents: [DocumentSnapshot] = []
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
    }
    
    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        query = baseQuery()
        tableView.dataSource = self
        tableView.delegate = self
        
        database = Firestore.firestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        observeQuery()
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dishes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dishCell", for: indexPath) as! DishBrowserTableViewCell
        let dish = dishes[indexPath.row]
        cell.delegate = self
        cell.indexPath = indexPath
        cell.configureCell(dish: dish)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        selectedDishDetails = dishes[indexPath.row]
        document = documents[indexPath.row]
        performSegue(withIdentifier: "toDishDetail", sender: nil)
        
// Not used at the moment. Instead we fetch the new image
//        let currentCell = tableView.cellForRow(at: indexPath)
//        selectedDishImage = (currentCell as! DishBrowserTableViewCell).dishImageView.image
    }
    
    
    // MARK: - Firestore
    fileprivate func observeQuery() {
        guard let query = query else { return }
        stopObserving()
        
        // Display data from Firestore, part one
        listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            let models = snapshot.documents.map { (document) -> Dish in
//                print(document)
                if let model = Dish(dictionary: document.data()) {
                    return model
                } else {
                    // Don't use fatalError here in a real app.
                    fatalError("Unable to initialize type \(Dish.self) with dictionary \(document.data())")
                }
            }
            
            self.dishes = models
            self.documents = snapshot.documents
            
            if self.documents.count > 0 {
                self.tableView.backgroundView = nil
            } else {
                self.tableView.backgroundView = self.backgroundView
            }
            
            self.tableView.reloadData()
        }
    }
    
    fileprivate func stopObserving() {
        listener?.remove()
    }
    
    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("dishes").limit(to: 50)
    }
    
    func favoriteTapped(at indexPath: IndexPath) {
        print("I am calling something")
        
        // Marking dish as favorite in the database
        let db = Firestore.firestore()
        guard let uid = KeychainWrapper.standard.string(forKey: "uid") else {
            displayAlertMessage(messageToDisplay: "Couldn't get your user identification for saving the data. Maybe you are not logged in")
            return
        }
        
        print(documents[indexPath.row].documentID)
        
        db.collection("dishes").document(documents[indexPath.row].documentID).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = Dish(dictionary: document.data()!)
                if dataDescription?.favorites![uid] != nil {//(dataDescription?.favorites?.contains(uid))! {
                    // At the moment Firestore doesn't support the full list of operations with arrays
                    // We need to use dictionary
                    db.collection("dishes").document(document.documentID).updateData([
                        "favorites.\(uid)": FieldValue.delete()
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                } else {
                    db.collection("dishes").document(document.documentID).setData(["favorites": [uid: 2]], merge: true)
                }
            }
        }
//
//        db.collection("dishes").document(document.documentID).getDocument{ (document, error) in
//            if let document = document, document.exists {
//                let dataDescription = Dish(dictionary: document.data()!)
//                if let rating = dataDescription?.ratings![uid] {
//                    self.ratingTextField.text = String(rating)
//                }
//            } else {
//                print("Document does not exist")
//            }
//        }
//        db.collection("dishes").document(document.documentID).setData(["favorites": [uid]], merge: true)
    }
    
    
    // MARK: - Navigation
    
    @IBAction func addDish(_ sender: Any) {
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
            performSegue(withIdentifier: "toDishUpload", sender: nil)
        } else {
            performSegue(withIdentifier: "toLogin", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? DishDetailViewController {
            destinationViewController.dish = selectedDishDetails
            destinationViewController.document = document
//            destinationViewController.dishImage = selectedDishImage
        }
    }
    
    
    // MARK: - Helpers
    
    func displayAlertMessage(messageToDisplay: String) {
        let alertController = UIAlertController(title: "Alert", message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            // Code in this block will trigger when OK button tapped.
            self.performSegue(withIdentifier: "toLogin", sender: nil)
        }
        
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
}

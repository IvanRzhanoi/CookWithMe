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

class DishBrowserTableViewController: UITableViewController {
    
    var database: Firestore!
    var selectedDishDetails: Dish!
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.configureCell(dish: dish)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)
        
        selectedDishDetails = dishes[indexPath.row]
        selectedDishImage = (currentCell as! DishBrowserTableViewCell).dishImageView.image
        
        performSegue(withIdentifier: "toDishDetail", sender: nil)
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
                print(document)
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
    
    @IBAction func markFavorite(_ sender: Any) {
        print("Marked as favorite")
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
//            destinationViewController.dishImage = selectedDishImage
        }
    }
}

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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        print(dishes)
        return dishes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dishCell", for: indexPath) as! DishBrowserTableViewCell
        let dish = dishes[indexPath.row]
        cell.configureCell(dish: dish)
        return cell
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
    
    // MARK: - Navigation
    @IBAction func addDish(_ sender: Any) {
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
            performSegue(withIdentifier: "toDishUpload", sender: nil)
        } else {
            performSegue(withIdentifier: "toLogin", sender: nil)
        }
    }
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

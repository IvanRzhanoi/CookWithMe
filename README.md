# CookWithMe

An app for users to share and upload their dishes

## Requirements

Xcode 9, iOS 11

To run the app

1. Build the pod file either with CocoaPods or through Terminal
2. Open newly created workspace 
3. Change developer team in general settings
4. Launch through Xcode and start exploring

## File overview (Controllers)

### LoginViewController

Either logs the user into the system or takes him to SignupViewController

### SignupViewController

Allows the user to register on the platform. The user is then taken back to the DishBrowserTableViewController

### DishBrowserTableViewController

Fetches the list of dishes from the server and displays them in the form of cards. Allows the user to favorite dishes. Dish has favorites as a list

We create a listener observeQuery(), which updates the databse live

```swift

guard let query = query else { return }
stopObserving()

// Display data from Firestore, part one
listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
    guard let snapshot = snapshot else {
        print("Error fetching snapshot results: \(error!)")
        return
    }

    let models = snapshot.documents.map { (document) -> Dish in
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

```

"Plus" sign takes to AddDishViewController

If the user taps on one of the cards they are taken to DishDetailViewController

### AddDishViewController

The user can upload a dish. He must input the the name, tags, difficulty, ingredients, instructions and picture. Picture can be either fetched from the photo library or taken with camera

Writing the data to Firestore

```swift

let collection = Firestore.firestore().collection("dishes")

let dish = Dish(name: name, posterUID: posterUID, imageReference: imageReference,
	tags: tags, difficulty: difficulty, ratings: nil,
	favorites: nil, ingredients: ingredients, instructions: instructions)

collection.addDocument(data: dish.dictionary)

```

### DishDetailViewController

Displays the information of dish. Allows the users to rank it. Users can order it. They will be taken to RestaurantBrowserTableViewController

### RestaurantBrowserTableViewController

Displays the list of restaurants in the proximity. It uses the dish tags passed from DishDetailViewController to fetch the data from FourSquare

```swift

for tag in tags {
    let url = "https://api.foursquare.com/v2/search/recommendations?ll=\(currentLocation.latitude),\(currentLocation.longitude)&v=20160607&query=\(tag)&limit=15&client_id=\(client_id)&client_secret=\(client_secret)"

    let request = NSMutableURLRequest(url: URL(string: url)!)
    let session = URLSession.shared

    request.httpMethod = "GET"

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, err -> Void in

        let json = JSON(data: data!)
        self.searchResults.append(contentsOf: json["response"]["group"]["results"].arrayValue)

        DispatchQueue.main.async {
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    })
    task.resume()
}

```

### RestaurantMapViewController

Displays the map with the pin of the selected restaurant. The user can eihter read more information on foursquare website or use the directions on AppleMaps

## Data Model (Dish, SwiftyJSON, RestaurantPin)

Firestore has two Collections: users and dishes. “users” collection has username and user image, which is stored with FireStorage

Dish.swift is the data structure class for our program for Firebase Firestore. It defines the information for dishes. Each dish carries the name, image reference (for the image stored on FireStorage), tags, difficulty, ratings, favourites (user IDs of those who like it), ingredients and instructions. Ratings and favorites can be equal to “nil” as they can’t be given on creation of the dish

It is also supposed to include posterUID, but for some reason it does not save it, which needs to be fixed. We don’t know who has posted a dish

SwiftyJSON provided by Ruoyu Fu, Pinglin Tang (2014 - 2016)

RestaurantPin places the pin on the map and was based on CoffeePin provided by Ryan Kotzebue for Foursquare sample project mrJitters (2016)

## APIs

Google Firebase, Firestore are used for the database, which stores users accounts and dishes. For some reason Firestore doesn't allow to store the UID of poster. This is a bug that needs fixing. Another downside is that Firestore is very limited when it comes to array. We can't update the singular values.


Foursquare is used to fetch the venues with tags corresponding to dishes. During the development of prototype it was impossible to find simple solution for multiple queries with OR logic (e.g. the dish can be associated either with Chinese or Japanese cuisine). Due to that it is necessary to perform multilple requests.

## Made by 

Ivan Rzhanoi 2018

For more infomation on other projects visit http://ivanrz.com
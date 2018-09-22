//
//  DishDetailViewController.swift
//  CookWithMe
//
//  Created by Ivan Rzhanoi on 22/09/2018.
//  Copyright © 2018 Ivan Rzhanoi. All rights reserved.
//

import UIKit
import FirebaseStorage


class DishDetailViewController: UIViewController {

    @IBOutlet weak var dishNameNavigationItem: UINavigationItem!
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var dishTagsLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var instructionsTextView: UITextView!
    
    var dish: Dish!
    var dishImage: UIImage!
    
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
    }

    func calculateMedian(array: [Float]) -> Float {
        let sorted = array.sorted()
        if sorted.count % 2 == 0 {
            return Float((sorted[(sorted.count / 2)] + sorted[(sorted.count / 2) - 1])) / 2
        } else {
            return Float(sorted[(sorted.count - 1) / 2])
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

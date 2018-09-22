//
//  DishBrowserTableViewCell.swift
//  CookWithMe
//
//  Created by Ivan Rzhanoi on 22/09/2018.
//  Copyright © 2018 Ivan Rzhanoi. All rights reserved.
//

import UIKit
import FirebaseStorage

class DishBrowserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dishName: UILabel!
    @IBOutlet weak var dishImageView: UIImageView!
    
    var dish: Dish!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(dish: Dish) {
        self.dish = dish
        dishName.text = dish.name
        
//        dishImage = dish.imageReference
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
    }
}

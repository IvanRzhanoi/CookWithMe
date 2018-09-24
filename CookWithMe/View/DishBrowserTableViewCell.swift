//
//  DishBrowserTableViewCell.swift
//  CookWithMe
//
//  Created by Ivan Rzhanoi on 22/09/2018.
//  Copyright © 2018 Ivan Rzhanoi. All rights reserved.
//

import UIKit
import FirebaseStorage
import SwiftKeychainWrapper

protocol FavoriteButtonDelegate {
    func favoriteTapped(at index:IndexPath)
}

class DishBrowserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dishNameLabel: UILabel!
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var dish: Dish!
    var delegate: FavoriteButtonDelegate!
    var indexPath: IndexPath!
    
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
        dishNameLabel.text = dish.name
        
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
        
        // Check if the user marked it as favorite
        guard let uid = KeychainWrapper.standard.string(forKey: "uid") else {
            return
        }
        
        if dish.favorites?[uid] != nil {
            favoriteButton.setImage(#imageLiteral(resourceName: "heart_filled"), for: .normal)
        }
    }
    
    @IBAction func markFavorite(_ sender: UIButton) {
//        favoriteButton.imageView?.image = #imageLiteral(resourceName: "heart_filled")
        if favoriteButton.imageView?.image == #imageLiteral(resourceName: "heart_outlined") {
            favoriteButton.setImage(#imageLiteral(resourceName: "heart_filled"), for: .normal)
        } else {
            favoriteButton.setImage(#imageLiteral(resourceName: "heart_outlined"), for: .normal)
        }
        self.delegate.favoriteTapped(at: indexPath)
    }
}

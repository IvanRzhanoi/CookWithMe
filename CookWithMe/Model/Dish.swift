//
//  Dish.swift
//  CookWithMe
//
//  Created by Ivan Rzhanoi on 20/09/2018.
//  Copyright © 2018 Ivan Rzhanoi. All rights reserved.
//

import Foundation

protocol DocumentSerializable {
    init?(dictionary: [String: Any])
}


struct Dish {
    var name: String
    var posterUID: String
    var imageReference: String
    var tags: [String]
    var difficulty: Int
    var ratings: [String: Float]?
    var favorites: [String: Int]?
    var ingredients: [String]
    var instructions: [String]
    
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "imageReference": imageReference,
            "tags": tags,
            "difficulty": difficulty,       // From 1 to 5
            "ratings": ratings ?? ["user": 3.0], // From 1 to 5
            "favorites": favorites ?? ["none": 1],
            "ingredients": ingredients,
            "instructions": instructions
        ]
    }
}

extension Dish: DocumentSerializable {
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
        let imageReference = dictionary["imageReference"] as? String,
        let tags = dictionary["tags"] as? [String],
        let difficulty = dictionary["difficulty"] as? Int,
        let ingredients = dictionary["ingredients"] as? [String],
        let instructions = dictionary["instructions"] as? [String] else {
            return nil
        }
        
        let posterUID = dictionary["posterUID"] as? String
        let posterUIDChecked: String = posterUID ?? "none"
        
        let ratings = dictionary["ratings"] as? [String: Float]
        let ratingsChecked: [String: Float] = ratings ?? ["user": 3.0]
        
        let favorites = dictionary["favorites"] as? [String: Int]
        let favoritesChecked: [String: Int] = favorites ?? ["none": 3]
        
        self.init(name: name, posterUID: posterUIDChecked, imageReference: imageReference, tags: tags, difficulty: difficulty, ratings: ratingsChecked, favorites: favoritesChecked, ingredients: ingredients, instructions: instructions)
    }
}

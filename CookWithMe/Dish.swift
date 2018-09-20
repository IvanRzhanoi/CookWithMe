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
    var imageReference: URL
    var tags: [String]
    var difficulty: Int
    var averageRating: Float?
    var ingredients: [String]
    var instructions: String
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "imageReference": imageReference,
            "tags": tags,
            "difficulty": difficulty,       // From 1 to 5
            "averageRating": averageRating as Any, // From 1 to 5
            "ingredients": ingredients,
            "instructions": instructions
        ]
    }
}

extension Dish: DocumentSerializable {
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
        let imageReference = dictionary["imageReference"] as? URL,
        let tags = dictionary["tags"] as? [String],
        let difficulty = dictionary["difficulty"] as? Int,
        let ingredients = dictionary["ingredients"] as? [String],
        let instructions = dictionary["instructions"] as? String else {
            return nil
        }
        
        let averageRating = dictionary["averageRating"] as? Float
        
        self.init(name: name, imageReference: imageReference, tags: tags, difficulty: difficulty, averageRating: averageRating, ingredients: ingredients, instructions: instructions)
    }
}

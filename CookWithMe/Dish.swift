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
    
    var dictionary: [String: Any] {
        return [
            "name": name
        ]
    }
}

extension Dish: DocumentSerializable {
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String else { return nil }
        self.init(name: name)
    }
}

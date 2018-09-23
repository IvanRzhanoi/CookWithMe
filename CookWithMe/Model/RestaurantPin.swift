//
//  RestaurantPin.swift
//  CookWithMe
//
//  Created by Ivan Rzhanoi on 23/09/2018.
//  Copyright © 2018 Ivan Rzhanoi. All rights reserved.
//


import Foundation
import MapKit
import Contacts

class RestaurantPin: NSObject, MKAnnotation {
    let title: String?
    let name: String
    let foursquareId: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, name: String, foursquareId: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.name = name
        self.foursquareId = foursquareId
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return name
    }
    
    func mapItem() -> MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        
        return mapItem
    }
}

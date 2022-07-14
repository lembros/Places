//
//  Place.swift
//  Places
//
//  Created by Егор Губанов on 13.07.2022.
//

import UIKit

struct Place {
    var name: String
    var location: String?
    var image: UIImage?
    var type: PlaceType?
    
    enum PlaceType: String {
        case restaurant = "Ресторан"
        case bar = "Бар"
        
        // Temporary solution, google how to change!!
        static let values = [Place.PlaceType.bar, Place.PlaceType.restaurant]
    }
    
    static let restaurantNames = ["Christian",
                                  "Mercedes Bar",
                                  "Sixty",
                                  "Buono",
                                  "Карлсон",
                                  "Эларджи",
                                  "Проснись и Пой",
                                  "Цыцыла"]
    
    static func getPlaces() -> [Place] {
        var places = [Place]()
        
        for name in restaurantNames {
            places.append(Place(name: name, location: "Москва", image: UIImage(named: name), type: .restaurant))
        }
        
        return places
    }
}

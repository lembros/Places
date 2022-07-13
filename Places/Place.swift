//
//  Place.swift
//  Places
//
//  Created by Егор Губанов on 13.07.2022.
//

import Foundation

struct Place {
    var name: String
    var location: String
    var image: String
    var type: PlaceType
    
    enum PlaceType: String {
        case restaurant = "Ресторан"
        case bar = "Бар"
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
            places.append(Place(name: name, location: "Москва", image: name, type: .restaurant))
        }
        
        return places
    }
}

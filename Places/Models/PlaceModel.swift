//
//  Place.swift
//  Places
//
//  Created by Егор Губанов on 13.07.2022.
//

import UIKit
import RealmSwift

protocol PlaceProtocol {
    var name: String        { get set }
    var location: String?   { get set }
    var imageData: Data?    { get set }
    var type: String?       { get set }
    var date: Date          { get set }
    var rating: Int         { get set }
    
    var hasLocation: Bool   { get }
    var hasType: Bool       { get }
}

class Place: Object, PlaceProtocol {
    @Persisted var name = ""
    @Persisted var location: String?
    @Persisted var imageData: Data?
    @Persisted var type: String?
    @Persisted var date = Date()
    @Persisted var rating: Int
    
    var hasLocation: Bool {
        return location != nil && !(location!.isEmpty)
    }
    
    var hasType: Bool {
        return type != nil && !(type!.isEmpty)
    }
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Int) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }
}

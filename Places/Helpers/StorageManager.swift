//
//  StorageManager.swift
//  Places
//
//  Created by Егор Губанов on 14.07.2022.
//

import RealmSwift


class StorageManager {
    static let realm = try! Realm()
    static var places = realm.objects(Place.self)
    
    // If class for storing places changes, just change it here
    typealias PlaceToStore = Place
    
    static func add(object: PlaceProtocol) {
        try! realm.write {
            realm.add(object as! PlaceToStore)
        }
    }
    
    static func delete(object: PlaceProtocol) {
        try! realm.write {
            realm.delete(object as! PlaceToStore)
        }
    }
    
    // Remember to add properies here when data model expands
    static func replace(object: PlaceProtocol, with newObject: PlaceProtocol) {
        try! realm.write {
            guard let object = object as? PlaceToStore, let newObject = newObject as? PlaceToStore else { return }
            object.name      = newObject.name
            object.location  = newObject.location
            object.type      = newObject.type
            object.imageData = newObject.imageData
            object.rating    = newObject.rating
        }
    }
}

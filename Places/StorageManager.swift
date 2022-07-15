//
//  StorageManager.swift
//  Places
//
//  Created by Егор Губанов on 14.07.2022.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    static func add(object: Place) {
        try! realm.write {
            realm.add(object)
        }
    }
    
    static func delete(object: Place) {
        try! realm.write {
            realm.delete(object)
        }
    }
    
    static func replace(object: Place, with newObject: Place) {
        try! realm.write {
            object.name = newObject.name
            object.location = newObject.location
            object.type = newObject.type
            object.imageData = newObject.imageData
        }
    }
    
}

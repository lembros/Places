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
    
}

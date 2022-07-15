//
//  Place.swift
//  Places
//
//  Created by Егор Губанов on 13.07.2022.
//

import UIKit
import RealmSwift

class Place: Object {
    @Persisted var name = ""
    @Persisted var location: String?
    @Persisted var imageData: Data?
    @Persisted var type: String?
    @Persisted var date = Date()
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
    }
}

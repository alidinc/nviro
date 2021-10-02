//
//  CollectionDataModel.swift
//  nviro
//
//  Created by Ali Dinç on 05/09/2021.
//

import Foundation
import RealmSwift
import CoreLocation

class SavedPlace: Object {
    //@objc dynamic var imageURL: String?
    @objc dynamic var locationName: String?
    @objc dynamic var savedPlaceId: String = UUID().uuidString
    @objc dynamic var imageData: Data?
    @objc dynamic var locationId: String?
    @objc dynamic var isFavorite = false
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    
//    convenience init(imageURL: String?, locationName: String?, id: String?, imageData: Data?) {
//        self.init()
//        self.locationName = locationName
//        self.imageURL = imageURL
//        self.imageData = imageData
//    }
//
//
    override static func primaryKey() -> String? {
        return "savedPlaceId"
    }
}

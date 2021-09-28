//
//  CollectionDataModel.swift
//  nviro
//
//  Created by Ali Dinç on 05/09/2021.
//

import Foundation
import RealmSwift

class SavedPlace: Object {
    @objc dynamic var imageURL: String?
    @objc dynamic var locationName: String?
    @objc dynamic var id: String?
    @objc dynamic var imageData: Data?
    
//    override static func primaryKey() -> String? {
//        return "savedPlaceId"
//    }
}

//
//  RealmManager.swift
//  nviro
//
//  Created by Ali Dinç on 27/09/2021.
//

import Realm
import RealmSwift

struct PersistenceError: Error {

    enum ErorsCodes: Int {
        case objectMissing = 0

        func getDescription() -> String {
            switch self {
            case .objectMissing:
                return "Realm object is missing"
            }
        }
    }

    var code: Int
    var description: String
}

protocol RealmPersistenceManager {

    func set<T>(_ objects: [T]) where T: Object
    func set<T>(_ object: T) where T: Object

    func get(_ type: Object.Type) -> [Object]?
    func get<T>(_ type: T.Type, predicate: NSPredicate) -> [T]? where T: Object

    func update<T>(_ objects: [T]) throws where T: Object

    func remove<T>(_ objects: [T]) where T: Object
    func remove<T>(_ object: T) where T: Object
    func removeAllOf<T>(_ type: T.Type) where T: Object

    func isExist<T>(_ object: T.Type) -> Bool where T: Object

    func removeAll()
}

class RealmManager: RealmPersistenceManager {

    typealias CompletionHandler = (() -> Void)?

    private var realm: Realm {
        // swiftlint:disable:next force_try
        return try! Realm()
    }

    static let sharedInstance = RealmManager()

    func set<T>(_ objects: [T]) where T: Object {
        // swiftlint:disable:next force_try
        try! realm.write {
            realm.add(objects, update: Realm.UpdatePolicy.all)
        }
    }

    func set<T>(_ object: T) where T: Object {
        // swiftlint:disable:next force_try
        try! realm.write {
            realm.add(object, update: Realm.UpdatePolicy.all)
        }
    }

    func get(_ type: Object.Type) -> [Object]? {
        guard let realm = try? Realm() else { return nil }
        let results = realm.objects(type)
        return Array(results)
    }

    func get<T>(_ type: T.Type, predicate: NSPredicate) -> [T]? where T: Object {
        guard let realm = try? Realm() else { return nil }
        return Array(realm.objects(type).filter(predicate))
    }

    func remove<T>(_ objects: [T]) where T: Object {
        if let realm = try? Realm() {
            try? realm.write {
                realm.delete(objects)
            }
        }
    }

    func remove<T>(_ object: T) where T: Object {
        if let realm = try? Realm() {
            try? realm.write {
                realm.delete(object)
            }
        }
    }

    func removeAllOf<T>(_ type: T.Type) where T: Object {
        if let realm = try? Realm() {
            try? realm.write {
                realm.delete(realm.objects(T.self))
            }
        }
    }

    func removeAll() {
        if let realm = try? Realm() {
            try? realm.write({
                realm.deleteAll()
            })
        }
    }

    func update<T>(_ objects: [T]) throws where T: Object {
        if let realm = try? Realm() {

            let primaryKeys = objects.map({ element -> Any in
                return element.value(forKey: T.primaryKey()!) as Any
            })

            let response = realm.objects(T.self).filter("%@ IN %@", T.primaryKey()!, primaryKeys)

            if response.count != objects.count {
                let erorrDescription = PersistenceError.ErorsCodes.objectMissing
                throw PersistenceError(code: erorrDescription.rawValue,
                                       description: erorrDescription.getDescription())
            }

            try? realm.write {
                realm.add(objects, update: Realm.UpdatePolicy.all)
            }
        }
    }

    func updateSavedPlace(_ object: SavedPlace, objectId: String) {
        if let realm = try? Realm() {
            let result = realm.objects(SavedPlace.self).filter("savedPlaceId == %@", objectId)

            if let savedPlace = result.first {
                try! realm.write { // swiftlint:disable:this force_try
                    savedPlace.locationName = object.locationName
                    savedPlace.imageData = object.imageData
                }
            }
        }
    }


    func isExist<T>(_ object: T.Type) -> Bool where T: Object {
        let object = realm.objects(object)

        if object.first != nil {
            return true
        } else {
            return false
        }
    }
}

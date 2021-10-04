////
////  Venue.swift
////  nviro
////
////  Created by Ali Dinç on 27/09/2021.
////
//
//import Foundation
//
//// MARK: - Response
//struct Response: Codable {
//    let groups: [Group]?
//    
//    enum CodingKeys: String, CodingKey {
//        case groups = "groups"
//    }
//}
//
//// MARK: - Group
//struct Group: Codable {
//    let type: String?
//    let name: String?
//    let items: [GroupItem]?
//
//}
//
//// MARK: - GroupItem
//struct GroupItem: Codable {
//    let venue: Venue
//}
//
//// MARK: - Venue
//struct Venue: Codable {
//    let id, name: String
//    let location: Location
//    let categories: [Category]
//    let popularityByGeo: Double
//    let venuePage: VenuePage
//}
//
//// MARK: - Category
//struct Category: Codable {
//    let id, name, pluralName, shortName: String
//    let primary: Bool
//}
//
//// MARK: - Location
//struct Location: Codable {
//    let address, crossStreet: String?
//    let lat, lng: Double
//    let labeledLatLngs: [LabeledLatLng]
//    let distance: Int
//    let postalCode, cc, city, state: String
//    let country: String
//    let formattedAddress: [String]
//}
//
//// MARK: - LabeledLatLng
//struct LabeledLatLng: Codable {
//    let label: String
//    let lat, lng: Double
//}
//
//// MARK: - VenuePage
//struct VenuePage: Codable {
//    let id: String
//}
//
//// MARK: - SuggestedBounds
//struct SuggestedBounds: Codable {
//    let ne, sw: Ne
//}
//
//// MARK: - Ne
//struct Ne: Codable {
//    let lat, lng: Double
//}
//
//// MARK: - Warning
//struct Warning: Codable {
//    let text: String
//}

//
//  Restaurants.swift
//  nviro
//
//  Created by Ali Dinç on 26/09/2021.
//

import Foundation

// MARK: - Restaurants
struct Restaurants: Codable {
    let response: Response?
}

struct Response: Codable {
    let venues: [Venue]?
}

// MARK: - Venue
struct Venue: Codable {
    let id, name: String?
    let location: Location?
    let categories: [Category]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case location = "location"
        case categories
    }
}

// MARK: - Category
struct Category: Codable {
    let id, name, pluralName, shortName: String
}

// MARK: - Location
struct Location: Codable {
    let address: String?
    let lat, lng: Double?
    let postalCode, cc, city, state: String?
    let country: String?
    let formattedAddress: [String]

    enum CodingKeys: String, CodingKey {
        case address
        case lat, lng
        case postalCode, cc, city, state
        case country
        case formattedAddress
    }
}


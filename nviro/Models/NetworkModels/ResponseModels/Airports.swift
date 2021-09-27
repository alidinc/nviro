//
//  Airports.swift
//  nviro
//
//  Created by Ali Dinç on 21/09/2021.
//

import Foundation

// MARK: - Airports
struct Airports: Codable {
    let page: Page
    let content: [Content]
    
    enum CodingKeys: String, CodingKey {
        case content
        case page
    }
}

// MARK: - Content
struct Content: Codable {
    let aid: String?
    let icao, iata: String?
    let faa: String?
    let name: String
    let coordinates: Coordinates?
    let servedCity: String?
    let country: Country?
    let timeZone: String?
    
    enum CodingKeys: String, CodingKey {
        case aid, icao, iata, faa
        case name
        case coordinates
        case servedCity
        case country
        case timeZone
    }
}

// MARK: - Coordinates
struct Coordinates: Codable {
    let latitude, longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
}

// MARK: - Country
struct Country: Codable {
    let iso3, iso2: String
    let isoNumeric: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case iso3, iso2
        case isoNumeric
        case name
    }
}

// MARK: - Page
struct Page: Codable {
    let number, size, totalPages, totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case number, size, totalPages, totalResults
    }
}

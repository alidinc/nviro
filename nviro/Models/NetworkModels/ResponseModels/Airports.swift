//
//  Airports.swift
//  nviro
//
//  Created by Ali Dinç on 10/09/2021.
//

import Foundation

struct Airports: Codable {
    let icao, iata, name, location: String
    let country, countryCode, longitude, latitude: String
    let link: String
    let status: Int

    enum CodingKeys: String, CodingKey {
        case icao
        case iata
        case name
        case location
        case country
        case countryCode = "country_code"
        case longitude
        case latitude
        case link
        case status
    }
}

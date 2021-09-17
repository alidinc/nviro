//
//  Airports.swift
//  nviro
//
//  Created by Ali Dinç on 02/09/2021.
//

import Foundation

// MARK: - Datum
struct AirportData : Codable{
    
    let data : [Airport]
    enum CodingKeys : String, CodingKey {
        case data
    }
}

struct Airport: Codable {
    
    let name, detailedName: String
    let id: String
    let timeZoneOffset, iataCode: String
    let geoCode: GeoCode
    let address: Address
    
    enum CodingKeys : String, CodingKey {
        case name
        case id
        case timeZoneOffset
        case iataCode
        case geoCode
        case address
        case detailedName
    }
    
}

// MARK: - Address
struct Address: Codable {
    let cityName, cityCode, countryName, countryCode, regionCode: String
}

// MARK: - GeoCode
struct GeoCode: Codable {
    let latitude, longitude: Double
}



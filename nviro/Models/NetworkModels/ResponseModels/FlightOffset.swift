//
//  FlightOffset.swift
//  nviro
//
//  Created by Ali Dinç on 15/09/2021.
//

import Foundation

struct FlightOffset : Codable {
    let data : Datum
    enum CodingKeys: String, CodingKey {
        case data
    }
}

struct Datum: Codable {
    let distance, carbonLoad: String
    let leg1 : Flight
    let requires, cost: String
    
    enum CodingKeys: String, CodingKey {
        case distance
        case carbonLoad = "carbon_load"
        case leg1, requires, cost
    }
}

// MARK: - Leg
struct Flight: Codable {
    let distance, carbonLoad: String
    
    enum CodingKeys: String, CodingKey {
        case distance
        case carbonLoad = "carbon_load"
    }
}

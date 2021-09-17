//
//  NetworkingModels.swift
//  nviro
//
//  Created by Ali Dinç on 31/08/2021.
//

import Foundation


// MARK: - CarbonInterface Model
struct CarbonData: Codable {
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let id, type: String
    let attributes: Attributes
}

// MARK: - Attributes
struct Attributes: Codable {
    let passengers: Int
    let legs: [Leg]
    let estimated_at: String
    let carbon_g: Int
    let carbon_lb, carbon_kg, carbon_mt: Double
    let distance_unit: String
    let distance_value: Double
}

// MARK: - TravelLeg
struct Leg: Codable {
    let departure_airport: String
    let destination_airport: String
}

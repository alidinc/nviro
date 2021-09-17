//
//  FlightOffsetRequest.swift
//  nviro
//
//  Created by Ali Dinç on 15/09/2021.
//

import Foundation

struct FlightOffsetRequest: Codable {
    let travelMode: String = "multileg"
    let legsCount: String = "1"
    let leg1: LegForFlight
    let numberOfPassengers: String = "1"
    let apiKeyL1: String = "d95fead6-e8a6-4547-9fb9-7835101a3960"
    let apiKeyL2: String = "c60f8db5-7204-4427-960d-27400c38b166"

    enum CodingKeys: String, CodingKey {
        case travelMode = "travel_mode"
        case legsCount = "legs_count"
        case leg1
        case numberOfPassengers = "number_of_passengers"
        case apiKeyL1 = "apiKey_l1"
        case apiKeyL2 = "apiKey_l2"
    }
}

// MARK: - Leg
struct LegForFlight: Codable {
    let originAirportCode, destinationAirportCode: String
    let travelClass: String = "Economy"

    enum CodingKeys: String, CodingKey {
        case originAirportCode = "origin_airport_code"
        case destinationAirportCode = "destination_airport_code"
        case travelClass = "travel_class"
    }
}

//
//  Location.swift
//  nviro
//
//  Created by Ali Dinç on 07/09/2021.
//

import Foundation

// MARK: - Custom Model (Request model)
struct TravelRequest: Codable {
    var type: String = "flight"
    let passengers: Int
    let legs: [Leg]
}

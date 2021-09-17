//
//  AirQuality.swift
//  nviro
//
//  Created by Ali Dinç on 03/09/2021.
//

import Foundation


// MARK: - AirQuality
struct CityData: Codable {
    let status: String
    let data: AirQ
}

// MARK: - DataClass
struct AirQ: Codable {
    let city, state: String
    let location: Location
    //let forecasts: [Forecast]
    let current: Current
}

// MARK: - Current
struct Current: Codable {
    let weather: Weather
    let pollution: Pollution
}

// MARK: - Pollution
struct Pollution: Codable {
    let ts: String
    let aqius: Int
    let mainus: String
    let aqicn: Int
    let maincn: String
}

struct Weather: Codable {
    let ts: String
    let tp, pr, hu : Int
    // let ws: Int?
    let wd: Int?
    let ic: String
    
    enum CodingKeys : String, CodingKey {
        case ts
        case tp, pr, hu
        // case ws
        case wd
        case ic
    }
}

// MARK: - Forecast
struct Forecast: Codable {
    let ts: String
    let aqius, aqicn: Int
    let tp, tpMin, pr, hu: Int?
    let ws, wd: Int?
    let ic: String?
    
    enum CodingKeys: String, CodingKey {
        case ts, aqius, aqicn, tp
        case tpMin = "tp_min"
        case pr, hu, ws, wd, ic
    }
}


// MARK: - Location
struct Location: Codable {
    let type: String
    let coordinates: [Double]
}

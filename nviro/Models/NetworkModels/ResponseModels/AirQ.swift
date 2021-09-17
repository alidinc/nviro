//
//  AirQ.swift
//  nviro
//
//  Created by Ali Dinç on 07/09/2021.
//

import Foundation

// MARK: - AirQuality
struct AirQuality: Codable {
    let list: [AirQList]
    
    enum CodingKeys : String, CodingKey {
        case list
    }
}

// MARK: - List
struct AirQList: Codable {
    let dt: Int
    let main: Main
    let components: Components
    
    enum CodingKeys : String, CodingKey {
        case dt
        case main
        case components
    }
}

struct Components: Codable{
    let co: Double
    let no: Double
    let no2: Double
    let o3: Double
    let so2: Double
    let pm25:Double
    let pm10: Double
    let nh3: Double
    
    enum CodingKeys: String, CodingKey {
        case co
        case no
        case no2
        case o3
        case so2
        case pm25 = "pm2_5"
        case pm10
        case nh3
    }
}

// MARK: - Main
struct Main: Codable {
    let aqi: Int
    
    enum CodingKeys : String, CodingKey {
        case aqi
    }
}

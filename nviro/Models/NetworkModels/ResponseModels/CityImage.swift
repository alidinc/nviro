//
//  CityImage.swift
//  nviro
//
//  Created by Ali Dinç on 07/09/2021.
//

import Foundation

struct UnsplashTopLevel: Codable {
    let results: [UnsplashImage]
}

struct UnsplashImage: Codable {
    let width, height, likes: Int
    let urls: UnsplashImageURLs
    let user: UnsplashUser
}

struct UnsplashImageURLs: Codable {
    let regularURL: URL
    
    enum CodingKeys: String, CodingKey {
        case regularURL = "regular"
    }
}

struct UnsplashUser: Codable {
    let username: String
    let profileImage: UnsplashProfileImages
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
        case username
    }
}

struct UnsplashProfileImages: Codable {
    let mediumImageURL: URL
    
    enum CodingKeys: String, CodingKey {
        case mediumImageURL = "medium"
    }
}

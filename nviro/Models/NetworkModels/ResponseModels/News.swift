//
//  News.swift
//  nviro
//
//  Created by Ali Dinç on 22/09/2021.
//

import Foundation


// MARK: - News
struct News: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
    
    enum CodingKeys: String, CodingKey {
        case status
        case totalResults
        case articles
    }
}

// MARK: - Article
struct Article: Codable {
    let source: Source
    let author: String?
    let title, articleDescription: String
    let url: String
    let urlToImage: String?
    //let publishedAt: Date
    let content: String

    enum CodingKeys: String, CodingKey {
        case source, author, title
        case articleDescription = "description"
        case url, urlToImage, content
    }
}

// MARK: - Source
struct Source: Codable {
    let id: String?
    let name: String
}

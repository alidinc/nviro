//
//  Endpoints.swift
//  nviro
//
//  Created by Ali Dinç on 02/09/2021.
//

import Foundation

struct Endpoint {
    let scheme: Scheme
    let host: String
    let path: String
    let queryItems: [URLQueryItem]
}

extension Endpoint {
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = "\(scheme)"
        components.host = host
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
}


enum Scheme: String {
    case http = "http"
    case https = "https"
}


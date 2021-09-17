//
//  NetworkError.swift
//  nviro
//
//  Created by Ali Dinç on 30/08/2021.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case serverError(Error)
    case noData
    case thrownError(Error)
    case noImage
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "the call URL is invalid"
        case .serverError(let error):
            return "The server has returned an error: \(error.localizedDescription)."
        case .noData:
            return "The server has returned no data."
        case .thrownError(let error):
            return "Thrown error while decoding JSON from the server: \(error.localizedDescription)"
        case .noImage:
            return "Could not create UIImage from data."
        }
    }
}

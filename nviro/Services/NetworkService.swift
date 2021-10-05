//
//  NetworkService.swift
//  nviro
//
//  Created by Ali Dinç on 30/08/2021.
//

import UIKit
import CoreLocation

class NetworkService: NSObject {
    static func showNetworkResponse(data : Data){
        do {
            if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                print(jsonResult)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    static func flightOffset(flightOffsetRequest: FlightOffsetRequest, completion: @escaping (Result<FlightOffset, NetworkError>) -> Void) {
        let baseURLForClimateKuul = "http://api.climatekuul.com:8000/footprint"
        
        guard let baseURL = URL(string: baseURLForClimateKuul) else { return completion(.failure(.invalidURL)) }
        let multilegURL = baseURL.appendingPathComponent("airtravelMultileg")
        
        var components = URLComponents(url: multilegURL, resolvingAgainstBaseURL: true)
        let apiKey1Query = URLQueryItem(name: "apiKey_l1", value: Constants.ApiKeys.flightOffsetDeveloperKey)
        let apiKey2Query = URLQueryItem(name: "apiKey_l2", value: Constants.ApiKeys.flightOffsetPartnerKey)
        
        components?.queryItems = [apiKey1Query, apiKey2Query]
        guard let finalURL = components?.url else { return completion(.failure(.invalidURL)) }
        
        do {
            let jsonRequest = try JSONEncoder().encode(flightOffsetRequest.self)
            
            var request = URLRequest(url: finalURL)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonRequest
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                } else {
                    guard let data = data else { return }
                    
                    do {
                        let decoder = JSONDecoder()
                        let jsonResponse = try decoder.decode(FlightOffset.self, from: data)
                        completion(.success(jsonResponse))
                    } catch {
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    }
                }
            }
            task.resume()
        } catch {
            completion(.failure(.serverError(error)))
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
    }
    static func getAirQuality(with coordinate: CLLocationCoordinate2D, completion: @escaping (Result<[AirQList], NetworkError>) -> Void) {
        // http://api.openweathermap.org/data/2.5/air_pollution?lat={lat}&lon={lon}&appid={API key}
        
        let endpoint = Endpoint(scheme: .http, host: "api.openweathermap.org", path: "/data/2.5/air_pollution", queryItems: [
            URLQueryItem(name: "lat", value: "\(coordinate.latitude)"),
            URLQueryItem(name: "lon", value: "\(coordinate.longitude)"),
            URLQueryItem(name: "appid", value: "23200eaebcdb74727978506347ca77ab")
        ])
        guard let finalUrl = endpoint.url else { return completion(.failure(.invalidURL)) }
        
        var request = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.thrownError(error)))
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            guard let data = data else { return completion(.failure(.noData)) }
            do {
                let jsonResponse = try JSONDecoder().decode(AirQuality.self, from: data)
                let airQList = jsonResponse.list
                completion(.success(airQList))
            } catch {
                completion(.failure(.serverError(error)))
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
        task.resume()
    }
    static func fetchUnsplashImages(with searchTerm: String, completion: @escaping (Result<[UnsplashImage], NetworkError>) -> Void) {
        let clientIDKey = "client_id"
        let clientIDValue = "t6bj36SI6JgZfShK21D-hTRnfseTefPn_w6bK1gMBXs"
        let searchTermKey = "query"
        let itemQuantityKey = "per_page"
        let itemQuantityValue = "100"
        
        let endpoint = Endpoint(scheme: .https, host: "api.unsplash.com", path: "/search/photos", queryItems: [
            URLQueryItem(name: clientIDKey, value: clientIDValue),
            URLQueryItem(name: searchTermKey, value: searchTerm),
            URLQueryItem(name: itemQuantityKey, value: itemQuantityValue)
        ])
        
        guard let finalURL = endpoint.url else { return completion(.failure(.invalidURL)) }
        
        let task = URLSession.shared.dataTask(with: finalURL) { data, _, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.serverError(error)))
            }
            guard let data = data else { return completion(.failure(.noData)) }
            do {
                let unsplashImagesTopLevel = try JSONDecoder().decode(UnsplashTopLevel.self, from: data)
                completion(.success(unsplashImagesTopLevel.results))
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.thrownError(error)))
            }
        }
        task.resume()
    }
    static func fetchImage(with url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        let cache = NSCache<NSString, UIImage>()
        let cacheKey = NSString(string: url.absoluteString)
        if let image = cache.object(forKey: cacheKey) {
            completion(.success(image))
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.serverError(error)))
            }
            guard let data = data else { return completion(.failure(.noData)) }
            guard let image = UIImage(data: data) else { return completion(.failure(.noImage))}
            image.jpegData(compressionQuality: 0.5)
            cache.setObject(image, forKey: cacheKey) // if it's not in the cache, download a new image
            completion(.success(image))
        }
        task.resume()
    }
    static func getAirports(with searchTerm: String, completion: @escaping (Result<[Content], NetworkError>) -> Void) {
        
        //https://api.aviowiki.com/free/airports/search?query=Los%20Angeles
        
        let endpoint = Endpoint(scheme: .https, host: "api.aviowiki.com", path: "/free/airports/search", queryItems: [URLQueryItem(name: "query", value: searchTerm)])
        
        guard let finalURL = endpoint.url else { return completion(.failure(.invalidURL)) }
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.invalidURL))
            }
            guard let data = data else { return completion(.failure(.noData)) }
            do {
                let results = try JSONDecoder().decode(Airports.self, from: data)
                completion(.success(results.content))
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.thrownError(error)))
            }
        }
        task.resume()
    }
    
    static func getNews(with searchTerm: String, completion: @escaping (Result<[Article], NetworkError>) -> Void) {
        //https://newsapi.org/v2/everything?q=climatechange&apiKey=97341e5bfacc46d6972c0fa3ebaf2de5
        
        let endpoint = Endpoint(scheme: .https, host: "newsapi.org", path: "/v2/everything", queryItems: [
            URLQueryItem(name: "q", value: searchTerm),
            URLQueryItem(name: "apiKey", value: "97341e5bfacc46d6972c0fa3ebaf2de5"),
            URLQueryItem(name: "pageSize", value: "100"),
            URLQueryItem(name: "sortBy", value: "relevancy"),
            URLQueryItem(name: "excludeDomains", value: "wired.com,engadget.com,techcrunch.com,gizmodo.com,azocleantech.com,ctvnew.ca,euroweeklynews.com")])
        
        guard let finalURL = endpoint.url else { return completion(.failure(.invalidURL)) }
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.invalidURL))
            }
            guard let data = data else { return completion(.failure(.noData)) }
            do {
                let results = try JSONDecoder().decode(News.self, from: data)
                completion(.success(results.articles))
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.thrownError(error)))
            }
        }
        task.resume()
    }
    
    static func getVenues(with searchTerm: String, completion: @escaping (Result<[Venue], NetworkError>) -> Void) {
        // https://api.foursquare.com/v2/venues/search?near=aberdeen&categoryId=+4bf58dd8d48988d1d3941735&client_id=GX4NHXFVDOAQSQERRTHS1FM2KD2OS5T51E5UEN1ABEVEIXT0&client_secret=N4HWDWO1GR2RIO3CDYBM31KS23KUYMIZNJZ1EZRWNIEH4N0M&v=20210926

        let endpoint = Endpoint(scheme: .https, host: "api.foursquare.com", path: "/v2/venues/search", queryItems: [
            URLQueryItem(name: "categoryId", value: "+4bf58dd8d48988d1d3941735"),
            URLQueryItem(name: "v", value: Date().dateStringForForsquare()),
            URLQueryItem(name: "near", value: searchTerm),
            URLQueryItem(name: "client_id", value: Constants.ApiKeys.foursquareClientId),
            URLQueryItem(name: "client_secret", value: Constants.ApiKeys.foursquareClientScreet),
            URLQueryItem(name: "limit", value: "50")])

        guard let finalURL = endpoint.url else { return completion(.failure(.invalidURL)) }
        print(finalURL)
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.invalidURL))
            }
            guard let data = data else { return completion(.failure(.noData)) }
            do {
                let results = try JSONDecoder().decode(Restaurants.self, from: data)
                guard let venues = results.response?.venues else { return }
                completion(.success(venues))
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.thrownError(error)))
            }
        }
        task.resume()
    }
    
//    static func getVenues(with searchTerm: String, completion: @escaping (Result<[Venue], NetworkError>) -> Void) {
//        //  https://api.foursquare.com/v2/venues/explore?near=NYC
//
//        let endpoint = Endpoint(scheme: .https, host: "api.foursquare.com", path: "/v2/venues/explore", queryItems: [
//            URLQueryItem(name: "categoryId", value: "+4bf58dd8d48988d1d3941735"),
//            URLQueryItem(name: "v", value: Date().dateStringForForsquare()),
//            URLQueryItem(name: "near", value: searchTerm),
//            URLQueryItem(name: "client_id", value: Constants.ApiKeys.foursquareClientId),
//            URLQueryItem(name: "client_secret", value: Constants.ApiKeys.foursquareClientScreet),
//            URLQueryItem(name: "limit", value: "50")])
//
//        guard let finalURL = endpoint.url else { return completion(.failure(.invalidURL)) }
//        print(finalURL)
//        var request = URLRequest(url: finalURL)
//        request.httpMethod = "GET"
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
//                completion(.failure(.invalidURL))
//            }
//            guard let data = data else { return completion(.failure(.noData)) }
//            do {
//                showNetworkResponse(data: data)
//                let results = try JSONDecoder().decode(Group.self, from: data)
//                guard let groupItems = results.items else { return }
//                let venues = groupItems.map({$0.venue})
//                completion(.success(venues))
//            } catch {
//                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
//                completion(.failure(.thrownError(error)))
//            }
//        }
//        task.resume()
//    }
    
    static func purchaseTrees(with amount: Int, from name: String, completion: @escaping (Result<TreePurchase, NetworkError>) -> Void) {
        let endpoint = Endpoint(scheme: .https, host: "ecologi.com", path: "/impact/trees", queryItems: [
            URLQueryItem(name: "number", value: "\(amount)"),
            URLQueryItem(name: "name", value: "\(name)"),
            URLQueryItem(name: "test", value: "true")])
        
        guard let finalURL = endpoint.url else { return completion(.failure(.invalidURL)) }
        var request = URLRequest(url: finalURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(Constants.ApiKeys.ecologi)", forHTTPHeaderField: "authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.thrownError(error)))
            }
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(TreePurchase.self, from: data)
                    completion(.success(result))
                } catch {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(.failure(.noData))
                }
            }
        }
        task.resume()
    }
}

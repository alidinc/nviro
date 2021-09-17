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
    
    static func getAirports(for searchKeywordForCity: String, completion: @escaping (Result<[Airport], NetworkError>) -> Void) {
        
        let apiKey = "ZUOIoZ42YSA7V0kRdBU2k4oLGcE9"
        //https://test.api.amadeus.com/v1/reference-data/locations?subType=AIRPORT&keyword=LON&sort=analytics.travelers.score&view=FULL
    
        let baseURLForAmadeus = "test.api.amadeus.com"
        let pathForAmadeus = "/v1/reference-data/locations"
        
        let typeQueryKey = "subType"
        let typeQueryValue = "AIRPORT"
        let searchQueryKey = "keyword"
        let sortQueryKey = "sort"
        let sortQueryValue = "analytics.travelers.score"
        let viewQueryKey = "view"
        let viewQueryValue = "FULL"
        
        let endpoint = Endpoint(scheme: .https, host: baseURLForAmadeus, path: pathForAmadeus, queryItems: [
            URLQueryItem(name: typeQueryKey, value: typeQueryValue),
            URLQueryItem(name: searchQueryKey, value: searchKeywordForCity),
            URLQueryItem(name: sortQueryKey, value: sortQueryValue),
            URLQueryItem(name: viewQueryKey, value: viewQueryValue)
        ])
        
        guard let finalURL = endpoint.url else { return completion(.failure(.invalidURL)) }
        print(finalURL)
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.thrownError(error)))
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            } else {
                guard let data = data else { return completion(.failure(.noData)) }
                do {
                    NetworkService.showNetworkResponse(data: data)
                    
                    let airport = try JSONDecoder().decode(AirportData.self, from: data)
                    completion(.success(airport.data))
                } catch {
                    completion(.failure(.serverError(error)))
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
        task.resume()
    }
    
    static func flightOffset(flightOffsetRequest: FlightOffsetRequest, completion: @escaping (Result<FlightOffset, NetworkError>) -> Void) {
        let apiKeyValueForClimateKuul = "9e7f65db-6e3d-4643-b30b-1f4e66f25b3f"
        let apiKeyForPartner = "90f093ec-0cfe-4b27-9ba2-58bd4de65a95"
        let baseURLForClimateKuul = "http://api.climatekuul.com:8000/footprint"

        guard let baseURL = URL(string: baseURLForClimateKuul) else { return completion(.failure(.invalidURL)) }
        let multilegURL = baseURL.appendingPathComponent("airtravelMultileg")
        
        var components = URLComponents(url: multilegURL, resolvingAgainstBaseURL: true)
        let apiKey1Query = URLQueryItem(name: "apiKey_l1", value: apiKeyValueForClimateKuul)
        let apiKey2Query = URLQueryItem(name: "apiKey_l2", value: apiKeyForPartner)
        
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
    
    static func carbonDetails(request: TravelRequest, completion: @escaping (Result<CarbonData, NetworkError>) -> Void) {
        
        let baseURLforCarbonInterface = "https://www.carboninterface.com/api/v1/estimates"
        let apiKeyforCarbonInterface = "sZXkdO4XIwUABywJgy7Ww"
        
        do {
            let jsonRequest = try JSONEncoder().encode(request.self)
            guard let baseURL = URL(string: baseURLforCarbonInterface) else { return completion(.failure(.invalidURL)) }
            
            var request = URLRequest(url: baseURL)
            request.addValue("Bearer \(apiKeyforCarbonInterface)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonRequest
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(.failure(.thrownError(error)))
                }
                let code = response as! HTTPURLResponse
                print("Code: \(code.statusCode)")
                guard let data = data else { return completion(.failure(.noData)) }
                do {
                    let decoder = JSONDecoder()
                    let jsonResponse = try decoder.decode(CarbonData.self, from: data)
                    completion(.success(jsonResponse))
                } catch {
                    completion(.failure(.serverError(error)))
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
            task.resume()
        }  catch {
            completion(.failure(.serverError(error)))
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
    }
    
    static func getCityAirQuality(with searchTerm: String, completion: @escaping (Result<CityData, NetworkError>) -> Void) {
        
        //http://api.airvisual.com/v2/city?city=LosAngeles&state=California&country=USA&key={{YOUR_API_KEY}}
        
        let endpoint = Endpoint(scheme: .https, host: "api.airvisual.com", path: "/v2/city", queryItems: [
            URLQueryItem(name: "city", value: searchTerm),
            URLQueryItem(name: "state", value: "England"),
            URLQueryItem(name: "country", value: "UK"),
            URLQueryItem(name: "key", value: "c7545dd5-be7c-435c-9d05-a9be37d847b5")
        ])
        
        guard let finalURL = endpoint.url else { return }
        print(finalURL)
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            guard let data = data else { return }
            do {
                NetworkService.showNetworkResponse(data: data)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonResponse = try decoder.decode(CityData.self, from: data)
                completion(.success(jsonResponse))
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.serverError(error)))
            }
        }
        task.resume()
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
            
            cache.setObject(image, forKey: cacheKey) // if it's not in the cache, download a new image
            completion(.success(image))
        }
        task.resume()
    }
    
    static func getAirportCity(with searchTerm: String, completion: @escaping (Result<Airports, NetworkError>) -> Void) {
        let endpoint = Endpoint(scheme: .https, host: "www.airport-data.com", path: "/api/ap_info.json", queryItems: [URLQueryItem(name: "iata", value: searchTerm)])
        guard let finalURL = endpoint.url else { return completion(.failure(.invalidURL)) }
        
        let request = URLRequest(url: finalURL)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.thrownError(error)))
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            guard let data = data else { return completion(.failure(.noData)) }
            do {
                let jsonResponse = try JSONDecoder().decode(Airports.self, from: data)
                completion(.success(jsonResponse))
            } catch {
                completion(.failure(.serverError(error)))
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
        task.resume()
    }
}




//
//  WeatherService.swift
//  JPMCWeatherApp
//
//  Created by Neha Dhawal on 8/16/24.
//

import UIKit

///Subclass of BaseService for performing Location search, Coordinated Search and Icon download
///The service methods are asynchronous, using async/await . The ViewModel can await the results of these operations without blocking the main thread, ensuring a responsive UI.
///This class can be further enhanced to reciever base url from Config, SInce the Urls are different everytime I am keep it simple

class WeatherService: BaseService {

    private let apiKey = "e6bdff4d5c42dd65ec7f5007c402093d"
    private let baseUrl = "https://api.openweathermap.org"

    // Seach location from Search bar and return object of type [Location]
    func getLocations(for location: String) async throws -> [Location] {
        guard !location.isEmpty else {
            throw NetworkError.badURL
        }
        
        let urlString = "\(baseUrl)/geo/1.0/direct?q=\(location)&limit=5&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.badURL
        }
        return try await performRequest(url: url, expecting: [Location].self)
    }
    
    /// Search Weather based on Coordinates recieved from previous call and returns object of type WeatherResponse
    func fetchWeather(for coordinates: Coordinates) async throws -> WeatherResponse {
        let urlString = "\(baseUrl)/data/2.5/weather?lat=\(coordinates.lat)&lon=\(coordinates.lon)&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.badURL
        }
        return try await performRequest(url: url, expecting: WeatherResponse.self)
    }
    
    
    /// Fetch Icon based on icon code. Icon code is returned from the weather response.
    /// - Parameter iconCode: icon code of the image
    /// - Returns: image Data
    func fetchIcon(iconCode: String) async throws -> Data? {
        
        guard let iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png") else {
            return nil
        }
        // If not in cache, download the image
        return try await performRequest(url: iconURL, expecting: Data?.self)

    }
    
}

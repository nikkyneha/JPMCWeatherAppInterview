//
//  MockWeatherService.swift
//  JPMCWeatherAppTests
//
//  Created by Neha Dhawal on 8/16/24.
//

import XCTest
import Combine
@testable import JPMCWeatherApp

// Mock WeatherService
class MockWeatherService: WeatherService {
    var mockWeather: WeatherResponse?
    var mockLocations: [Location]?
    var shouldThrowError = false

    override func fetchWeather(for location: Coordinates) async throws -> WeatherResponse {
        if shouldThrowError {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock Error"])
        }
        
        guard let mockWeather = mockWeather else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No mock data"])
        }
        
        return mockWeather
    }

    override func getLocations(for city: String) async throws -> [Location] {
        if shouldThrowError {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock Error"])
        }
        
        // Provide mock data or an empty array if not set
        return mockLocations ?? []
    }
}


// Mock ImageCache

class MockImageCache: ImageCache {
    var mockData: Data?
    
    // Public initializer
    override init() {
        super.init() // Call the super class's initializer if necessary
    }
    
    override func loadImage(from iconCode: String, completion: @escaping (Data?) -> Void) {
        completion(mockData) // Return the mock data instead of loading from disk
    }
    
    override func saveImageToDisk(_ data: Data, with fileName: String) {
        mockData = data
    }
}


//// Mock UserDefaultsManager
class MockUserDefaultsManager: UserDefaultsManager {
    var mockCoordinates: Coordinates?
    
    override init() {
        super.init()
    }
    
    override func loadCoordinates() -> Coordinates? {
        return mockCoordinates
    }
    
    override func saveCoordinates(_ coordinates: Coordinates) {
        mockCoordinates = coordinates
    }
}

//
//  UserDefaultManager.swift
//  JPMCWeatherApp
//
//  Created by Neha Dhawal on 8/16/24.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let lastSearchedCityKey = "LastSearchedCityLocation"
     
    ///Function to save the Coordinates to be used on next launch as default location
    func saveCoordinates(_ coordinates: Coordinates) {
        let encoder = JSONEncoder()
        if let encodedCoordinates = try? encoder.encode(coordinates) {
            UserDefaults.standard.set(encodedCoordinates, forKey: lastSearchedCityKey)
        }
    }
    
    ///Helper function for testing removing the defaults
    func removeCoordinates() {
        UserDefaults.standard.removeObject(forKey: lastSearchedCityKey)
    }
    
    /// Function to load the coordinated in Coordinates format
    func loadCoordinates() -> Coordinates? {
        if let savedCoordinatesData = UserDefaults.standard.data(forKey: lastSearchedCityKey) {
            let decoder = JSONDecoder()
            if let coordinates = try? decoder.decode(Coordinates.self, from: savedCoordinatesData) {
                return coordinates
            }
        }
        return nil
    }
}

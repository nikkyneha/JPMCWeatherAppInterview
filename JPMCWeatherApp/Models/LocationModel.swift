//
//  LocationModel.swift
//  JPMCWeatherApp
//
//  Created by Neha Dhawal on 8/15/24.
//

import Foundation

//The model is expected response format when a location search is made
struct Location: Codable {
    let name: String?
    let localNames: [String: String]?
    let lat: Double
    let lon: Double
    let country: String?
    let state: String?
}

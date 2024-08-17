//
//  WeatherServiceTest.swift
//  JPMCWeatherAppTests
//
//  Created by Neha Dhawal on 8/16/24.
//

import XCTest
import Foundation
@testable import JPMCWeatherApp

class WeatherServiceTests: XCTestCase {

    var weatherService: WeatherService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        weatherService = WeatherService()
    }

    override func tearDownWithError() throws {
        weatherService = nil
        try super.tearDownWithError()
    }

    func testGetLocationsSuccess() async {
        let expectation = self.expectation(description: "Fetch results failure")
        let locations = try? await weatherService.getLocations(for: "London")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(locations?.count, 5)
        XCTAssertEqual(locations?.first?.name, "London")
        XCTAssertEqual(locations?.first?.lat, 51.5073219)
        XCTAssertEqual(locations?.first?.lon, -0.1276474)
    }

    func testGetLocationsBadURL() async throws {
        do {
            _ = try await weatherService.getLocations(for: "")
            XCTFail("Expected error, but no error was thrown")
        } catch {
            XCTAssertEqual(error as? NetworkError, .badURL)
        }
    }

    func testFetchWeatherSuccess() async throws {
        let coordinates = Coordinates(lat: 51.5074, lon: -0.1278)
        let weatherResponse = try await weatherService.fetchWeather(for: coordinates)
        XCTAssertEqual(weatherResponse.name, "London")
        XCTAssertNotNil(weatherResponse.main.temp)
        XCTAssertNotNil(weatherResponse.weather.first?.icon)
    }
}

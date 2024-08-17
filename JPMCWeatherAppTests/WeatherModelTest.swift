//
//  WeatherModelTest.swift
//  JPMCWeatherAppTests
//
//  Created by Neha Dhawal on 8/16/24.
//

import XCTest
@testable import JPMCWeatherApp

final class WeatherModelTest: XCTestCase {
    var viewModel: WeatherViewModel!
    var mockWeatherService: MockWeatherService!
    var mockImageCache: MockImageCache!
    var mockUserDefaultsManager: MockUserDefaultsManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockWeatherService = MockWeatherService()
        mockImageCache = MockImageCache()
        UserDefaultsManager.shared.removeCoordinates()
        mockUserDefaultsManager = MockUserDefaultsManager()
        mockUserDefaultsManager.removeCoordinates()
        viewModel = WeatherViewModel(weatherService: mockWeatherService)
        
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockWeatherService = nil
        mockImageCache = nil
        mockUserDefaultsManager = nil
        try super.tearDownWithError()
    }

    func testInitializationLoadsLastSearchedCityWeather() {
        let expectedCoordinates = Coordinates(lat: 37.7749, lon: -122.4194)
        mockUserDefaultsManager.saveCoordinates(expectedCoordinates)
        
        let savedCoordinates = mockUserDefaultsManager.loadCoordinates()
        XCTAssertEqual(expectedCoordinates, savedCoordinates)
    }

    func testFetchResultsSuccess() {
        let expectation = self.expectation(description: "Fetch results success")
        let expectedLocation = Location(name: "San Francisco", localNames: nil, lat: 37.7749, lon: -122.4194, country: nil, state: nil)
        mockWeatherService.mockLocations = [expectedLocation]
        
        viewModel.fetchResults(for: "San Francisco")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
        
        XCTAssertEqual(viewModel.locationResults.first?.name, "San Francisco")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchResultsFailure() {
        let expectation = self.expectation(description: "Fetch results failure")
        mockWeatherService.shouldThrowError = true
        
        viewModel.fetchResults(for: "San Francisco")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.locationResults.isEmpty)
    }

    func testFetchWeatherForSuccess() {
        let expectation = self.expectation(description: "Fetch weather success")
        guard let path = Bundle(for: type(of: self)).path(forResource: "MockResponse", ofType: "json") else {
            XCTFail("Failed to find JSON file.")
            return
        }
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        let expectedWeather = try? decoder.decode(WeatherResponse.self, from: data ?? Data())
        
        mockWeatherService.mockWeather = expectedWeather
        let coordinates = Coordinates(lat: 37.7749, lon: -122.4194)
        
        viewModel.fetchWeatherFor(for: coordinates)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
        XCTAssertEqual(viewModel.selectedCityWeather?.name, "San Francisco")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchWeatherForFailure() {
        let expectation = self.expectation(description: "Fetch weather failure")
        mockWeatherService.shouldThrowError = true
        let coordinates = Coordinates(lat: 37.7749, lon: -122.4194)
        
        viewModel.fetchWeatherFor(for: coordinates)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.selectedCityWeather)
    }

    func testFetchWeatherIconFromCache() {
        let expectation = self.expectation(description: "Fetch icon and save to cache")
        
        viewModel.fetchWeatherIcon(iconCode: "01d")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
        mockImageCache.saveImageToDisk(viewModel.weatherIconData ?? Data(), with: "01d")
        var savedImage: Data?
        mockImageCache.loadImage(from: "01d") { data in
            savedImage = data
        }
        XCTAssertEqual(viewModel.weatherIconData, savedImage)
    }
    func testGetIconFromURL() {
        let expectation = self.expectation(description: "Get icon")
        
        viewModel.getIconFromURL(iconCode: "01d")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    
        XCTAssertNotNil(viewModel.weatherIconData)
    }
}

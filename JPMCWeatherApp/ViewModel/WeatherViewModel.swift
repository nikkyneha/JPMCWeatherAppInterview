//
//  WeatherViewModel.swift
//  JPMCWeatherApp
//
//  Created by Neha Dhawal on 8/16/24.
//

import Combine
import Foundation
import CoreLocation

///ViewModel Acting between WeatherViewCOntroller , WeatherServices and other helper functions keeping business logic intact
/// Enhancement : allow user to convert Ferheniet to celsius and Vise Versa
class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate{
    @Published var locationResults: [Location] = []
    @Published var selectedCityWeather: WeatherResponse?
    @Published var weatherIconData: Data?
    @Published var errorMessage: String?
    
    private let weatherService: WeatherService
    private var cancellables = Set<AnyCancellable>()
    
    //Location manager
    //For simplicity its added to Viewmodel but for enhancement Location manager can be decoupled for reusability
    let locationManager = CLLocationManager()
    
    init(weatherService: WeatherService) {
        
        self.weatherService = weatherService
        super.init()
        // Load the last searched city coordinates using UserDefaultsManager
        if let lastSearchedCity = UserDefaultsManager.shared.loadCoordinates() {
            fetchWeatherFor(for: lastSearchedCity)
        }
        
    }
    
    /// Fetch Locations for a city entered in Search bar
    /// - Parameter city: city to be looked up
    func fetchResults(for city: String) {
        Task {
            do {
                let locationResults = try await weatherService.getLocations(for: city)
                self.locationResults = locationResults
                
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Fetch Weather for selected City
    /// - Parameter location: the coordinated of the selected city
    func fetchWeatherFor(for location: Coordinates) {
        Task {
            do {
                let weather = try await weatherService.fetchWeather(for: location)
                self.selectedCityWeather = weather
                // Save the last searched city to UserDefaults
                UserDefaultsManager.shared.saveCoordinates(location)
                self.fetchWeatherIcon(iconCode: weather.weather.first?.icon ?? "")
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    /// To Fectch Weather icon from CAche or Url and save to disk
    /// - Parameter iconCode: weather code for the location
    func fetchWeatherIcon(iconCode: String) {
        
        // First, check if the image is in the disk storage
        ImageCache.shared.loadImage(from: iconCode) { [weak self] data in
            guard let self = self else { return }
            
            if let data = data {
                debugPrint("Got image from cache")
                self.weatherIconData = data
                return
            } else {
                // If not in cache, download the image
                self.getIconFromURL(iconCode: iconCode)
            }
        }
    }
    
    /// Fecth data from Url
    func getIconFromURL(iconCode: String) {
        Task {
            do {
                let data = try await weatherService.fetchIcon(iconCode: iconCode)
                // Update the UI on the main thread
                // Check if data was received
                if let data = data {
                    // Update your UI with the downloaded data, e.g., setting an image view
                    ImageCache.shared.saveImageToDisk(data, with: iconCode)
                    self.weatherIconData = data
                    debugPrint("Data downloaded and saved successfully.")
                } else {
                    debugPrint("No data was returned by the request.")
                }
            } catch  {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    //MARK: Location Manager
    ///View model is delegate to location services
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    ///Check for Location Authorization and return status
    func checkLocationAuthorization(completion: @escaping (Bool) -> Void) {
        let authorizationStatus: CLAuthorizationStatus
        
        if #available(iOS 14, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        handleAuthorizationStatus(authorizationStatus) { status in
            completion(status)
        }
    }
    
    /// Wait for Futher action on Authorization from User and determine access level
    func handleAuthorizationStatus(_ authorizationStatus: CLAuthorizationStatus, completion: @escaping (Bool) -> Void) {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            completion(false)
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status: CLAuthorizationStatus
        
        if #available(iOS 14, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        handleAuthorizationStatus(status) { success in
            if !success {
                // Location authorization was denied
                self.errorMessage = "Location authorization was denied."
            }
        }
    }
    
    /// Invoked when current location is updated
    /// - Parameters:
    ///   - manager: location manager
    ///   - locations: locations of type CLLocation
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // Stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            // Fetch weather for current location
            fetchWeatherFor(for: Coordinates(lat: latitude, lon: longitude))
        }
    }
    
    /// Error Delegate
    /// - Parameters:
    ///   - manager:  location manager
    ///   - error: Error details
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle location errors
        errorMessage = error.localizedDescription
    }
}

//
//  WeatherViewController.swift
//  JPMCWeatherApp
//
//  Created by Neha Dhawal on 8/16/24.
//

import UIKit
import Combine
import UIKit

class WeatherViewController: UIViewController {
    
    private var viewModel: WeatherViewModel!
    private var weatherView: WeatherView!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = WeatherViewModel(weatherService: WeatherService())
        //Setup Custom View to present Weather condition
        weatherView = WeatherView()
        view = weatherView
        weatherView.searchBar.delegate = self
        weatherView.tableView.delegate = self
        weatherView.tableView.dataSource = self
        weatherView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cityCell")
        weatherView.currentLocationButton.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
        
        bindViewModel()
        
    }
    
    ///This checks for Location Permissions
    /// If Access is granted Current location weather is presented
    /// //If failed Alert is presented to user
    @objc func currentLocationButtonTapped() {
        debugPrint("Current Location button tapped")
        weatherView.searchBar.text = ""
        viewModel.setupLocationManager()
        viewModel.checkLocationAuthorization() {[weak self] success in
            if !success {
                // Handle the case where the user denied or restricted location access
                let alert = UIAlertController(title: "Location Access Denied",
                                              message: "Location access is needed to fetch weather for your current location. Please enable in Settings.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    /// Bind View model elements to make approproate action
    private func bindViewModel() {
        
        //reload table view when city serach fetches locations(set to max 5)
        viewModel.$locationResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.weatherView.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        //On selection of a city update WeatherView to present the details
        viewModel.$selectedCityWeather
            .combineLatest(viewModel.$weatherIconData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (weather, iconData) in
                guard let self = self, let weather = weather else { return }
                self.weatherView.updateWeatherDetails(
                    city: weather.name,
                    temperature: "\(weather.main.temp)°F",
                    description: weather.weather.first?.description.capitalized ?? "",
                    iconData: iconData
                )
            }
            .store(in: &cancellables)
        
        //In case of error gracefully present alert
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let self = self, let errorMessage = errorMessage else { return }
                // Handle the error (e.g., show an alert)
                weatherView.showError(errorMessage)
            }
            .store(in: &cancellables)
    }
}

//MARK: SearchBar Delegates

extension WeatherViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            weatherView.tableView.isHidden = true
            return
        }
        weatherView.bringSubviewToFront(weatherView.tableView)
        
        weatherView.tableView.isHidden = false
        viewModel.fetchResults(for: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

//MARK: TableView Delegates and datasource

extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.locationResults.count
    }
    
    //Forming the cell with the location details available to display
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        let weather = viewModel.locationResults[indexPath.row]
        var locationText = ""
        if let name = weather.name, !name.isEmpty {
            locationText += name
        }
        if let state = weather.state, !state.isEmpty {
            if !locationText.isEmpty {
                locationText += ", "
            }
            locationText += state
        }
        if let country = weather.country, !country.isEmpty {
            if !locationText.isEmpty {
                locationText += ", "
            }
            locationText += country
        }
        
        cell.textLabel?.text = locationText
        return cell
    }
    
    //Selection of a cell will fetch the Weather response for the Coordinates
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = viewModel.locationResults[indexPath.row]
        viewModel.fetchWeatherFor(for: Coordinates(lat: selectedCity.lat, lon: selectedCity.lon))
        tableView.deselectRow(at: indexPath, animated: true)
        weatherView.searchBar.text = ""
    }
}

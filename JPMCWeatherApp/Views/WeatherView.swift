//
//  WeatherView.swift
//  JPMCWeatherApp
//
//  Created by Neha Dhawal on 8/16/24.
//

import UIKit

//Enables conforming class to update the weather details in the UI and handle errors appropriately.
protocol  WeatherViewProtocol{
    func updateWeatherDetails(city: String, temperature: String, description: String, iconData: Data?)
    func showError(_ error: String)
}


/// Custom View to present the Weather of Selected City
/// List the searched locations in a table
/// Allow user to check the weather oof current location
/// Supports Portrait and Landscape mode
class WeatherView: UIView, WeatherViewProtocol {
    
    // MARK: - UI Elements
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Enter city name"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true // Hidden by default
        return tableView
    }()
    
    let cityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.isHidden = true // Hidden by default
        return label
    }()
    
    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.isHidden = true // Hidden by default
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.isHidden = true // Hidden by default
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true // Hidden by default
        return imageView
    }()
    
    let currentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📍", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(searchBar)
        addSubview(tableView)
        addSubview(cityLabel)
        addSubview(temperatureLabel)
        addSubview(descriptionLabel)
        addSubview(iconImageView)
        addSubview(currentLocationButton)
        
        setupConstraints()
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Search bar constraints
            searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: currentLocationButton.leadingAnchor, constant: -10),
            
            currentLocationButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            currentLocationButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            currentLocationButton.widthAnchor.constraint(equalToConstant: 44),
            currentLocationButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Table view constraints
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            // City label constraints
            cityLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            cityLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cityLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Temperature label constraints
            temperatureLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 10),
            temperatureLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            temperatureLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Description label constraints
            descriptionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Icon image view constraints
            iconImageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 100),
            iconImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // MARK: - Methods to Update UI after service
    func updateWeatherDetails(city: String, temperature: String, description: String, iconData: Data?) {
        cityLabel.text = city
        temperatureLabel.text = temperature
        descriptionLabel.text = description
        if let data = iconData {
            iconImageView.image = UIImage(data: data)
        } else {
            iconImageView.image = nil
        }
        
        // Show the weather details
        cityLabel.isHidden = false
        temperatureLabel.isHidden = false
        descriptionLabel.isHidden = false
        iconImageView.isHidden = false
        
        // Hide the table view when details are ready to be presented
        tableView.isHidden = true
    }
    
    // MARK: - WeatherViewProtocol methods
    func showError(_ error: String) {
        // Handle error display, e.g., show an alert or a label
        print("Error: \(error)")
        //Can be enhanced to present a message on screen to user
    }
}

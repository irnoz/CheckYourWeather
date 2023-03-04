//
//  ViewController.swift
//  MyWeather
//
//  Created by Irakli Nozadze on 08.01.23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    // MARK: Declaration
    @IBOutlet var table: UITableView!
    var models = [DailyWeatherEntry]()
    var hourlyModels = [HourlyWeatherEntry]()
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var currentLocation: CLLocation?
    var address: String?
    var currentWeather: CurrentWeather?
    let backGroundColorBlue = #colorLiteral(red: 0, green: 0.3402611613, blue: 0.7605063319, alpha: 1)
    let defaultFont = UIFont(name: "Helvetica-Bold", size: 20)
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // registering 2 cells
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        
        table.backgroundColor = backGroundColorBlue
        view.backgroundColor = backGroundColorBlue
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLocation()
    }
    
    // MARK: Location
    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestAddressForLocation()
            requestWeatherForLocation()
        }
    }
    
    func requestAddressForLocation() {
        guard let currentLocation = currentLocation else { return }
        
        var locality = ""
        var administrativeArea = ""
        var country = ""
        
        geocoder.reverseGeocodeLocation(currentLocation, completionHandler: {(placemarks, error) in
                if (error != nil) {
                    print("Error in reverseGeocode")
                    }

                let placemark = placemarks! as [CLPlacemark]
                if placemark.count > 0 {
                    let placemark = placemarks![0]
                    locality = placemark.locality!
                    administrativeArea = placemark.administrativeArea!
                    country = placemark.country!
                }

            print("\(locality), \(administrativeArea), \(country)")
            self.address = "\(locality), \(administrativeArea), \(country)"

            
                // Update User Interface (must be done on main queue)
                DispatchQueue.main.async {
                    self.table.reloadData()
                    
                    self.table.tableHeaderView = self.createTableHeader()
                }
            
        })
    }
    
    // MARK: API Request
    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
        let longitude = currentLocation.coordinate.longitude
        let latitude = currentLocation.coordinate.latitude
        
        let url = "https://api.darksky.net/forecast/ddcc4ebb2a7c9930b90d9e59bda0ba7a/\(latitude),\(longitude)?exclude=[flags,minutely]"
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            
            // Validate Data
            guard let data = data, error == nil else {
                print("Data could not be validated, something went wrong!")
                return
            }
            
            // Convert Data to models(object)
            var json: WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            } catch {
                print("Error decoding the API response!\nerror: \(error)")
            }
            
            guard let result = json else {
                print("Error getting decoded json")
                return
            }
            
            let entries = result.daily.data
            self.models.append(contentsOf: entries)
            
            let current = result.currently
            self.currentWeather = current
            
            self.hourlyModels = result.hourly.data
            
        }).resume()
    }
    
    // MARK: Header
    func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height/4))
        
        headerView.backgroundColor = backGroundColorBlue
        
        let locationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width-20, height: headerView.frame.size.height/3))
        let summaryLabel = UILabel(frame: CGRect(x: 0, y: 20+locationLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let temperatureLabel = UILabel(frame: CGRect(x: 0, y: 20+locationLabel.frame.size.height+summaryLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/2))
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(summaryLabel)
        headerView.addSubview(temperatureLabel)
        
        locationLabel.textAlignment = .center
        summaryLabel.textAlignment = .center
        temperatureLabel.textAlignment = .center
        
        guard let currentWeather = self.currentWeather else {
            print("Error validating Current Weather")
            return UIView()
        }
        
        temperatureLabel.font = defaultFont
        locationLabel.font = defaultFont
        summaryLabel.font = defaultFont
        
        guard let validatedAddress = address else {
            print("Error validating address")
            return headerView
        }
        
        DispatchQueue.main.async {
            temperatureLabel.text = "\(Int(currentWeather.temperature))°" // Current Temperature
            locationLabel.text = "\(String(describing: validatedAddress))"
            summaryLabel.text = currentWeather.summary // Summary
        }
        
        return headerView
    }
    
    // MARK: Table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // one cell that is collectionViewCell
            return 1
        }
        // return models count
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
            cell.configure(with: hourlyModels)
            cell.backgroundColor = backGroundColorBlue
                
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        cell.backgroundColor = backGroundColorBlue
            
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

// MARK: Codables
struct WeatherResponse: Codable {
    let latitude: Float
    let longitude: Float
    let timezone: String
    let currently: CurrentWeather
    let hourly: HourlyWeather
    let daily: DailyWeather
    let offset: Float
}

struct CurrentWeather: Codable {
    let time: Int
    let summary: String
    let icon: String
    let temperature: Double
}

struct DailyWeather: Codable {
    let summary: String
    let icon: String
    let data: [DailyWeatherEntry]
}

struct DailyWeatherEntry: Codable {
    let time: Int
    let summary: String
    let icon: String
    let temperatureHigh: Double
    let temperatureLow: Double
}

struct HourlyWeather: Codable {
    let summary: String
    let icon: String
    let data: [HourlyWeatherEntry]
}

struct HourlyWeatherEntry: Codable {
    let time: Int
    let summary: String
    let icon: String
    let temperature: Double
}

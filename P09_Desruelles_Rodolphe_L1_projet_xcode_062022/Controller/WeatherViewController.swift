//
//  WeatherViewController.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rodolphe Desruelles on 06/07/2022.
//

import UIKit

// Class for the weather of one town

class TownWeatherInterface {
    var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:MM"
        return df
    }()
    
    var timeLabel: UILabel
    var weatherIcon: UIImageView
    var weatherDescriptionLabel: UILabel
    var temperatureLabel: UILabel
    var loadingIndicator: UIActivityIndicatorView
    
    init(timeLabel: UILabel,
         weatherIcon: UIImageView,
         weatherDescriptionLabel: UILabel,
         temperatureLabel: UILabel,
         loadingIndicator: UIActivityIndicatorView)
    {
        self.timeLabel = timeLabel
        self.weatherIcon = weatherIcon
        self.weatherDescriptionLabel = weatherDescriptionLabel
        self.temperatureLabel = temperatureLabel
        self.loadingIndicator = loadingIndicator
    }
    
    func clear() {
        timeLabel.text = " "
        weatherIcon.isHidden = true
        loadingIndicator.isHidden = false
        weatherDescriptionLabel.text = " "
        temperatureLabel.text = " "
    }
    
    func update(data: WeatherData) {
        dateFormatter.timeZone = TimeZone(secondsFromGMT: data.timezone)
        let dataDate = Date(timeIntervalSince1970: TimeInterval(data.timestamp))
        
        timeLabel.text = dateFormatter.string(from: dataDate)
        weatherIcon.image = UIImage(named: data.weatherArray[0].icon)
        weatherIcon.isHidden = false
        loadingIndicator.isHidden = true
        weatherDescriptionLabel.text = data.weatherArray[0].description
        temperatureLabel.text = String(Int(data.temperature.rounded())) + " ºC"
    }
}

// Town data

struct Town {
    let name: String
    let latitude: Double
    let longitude: Double
}

// Controller

class WeatherViewController: UIViewController {
    var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:MM"
        return df
    }()
    
    // Model //
    // -------//
    
    let weatherLoader = APIRequestLoader(apiRequest: WeatherRequest())

    // Interface state //
    // -----------------//
    
    let originTown = Town(name: "Paris", latitude: 48.8588897, longitude: 2.3200410217200766)
    let destinationTown = Town(name: "New-York", latitude: 40.7127281, longitude: -74.0060152)
            
    var originWeatherInterface: TownWeatherInterface!
    var destinationWeatherInterface: TownWeatherInterface!
    
    // View components //
    // -----------------//

    let weatherLoadingFailureAlert = ControllerHelper.simpleAlert(message: "Impossible de récupérer les données de météo.")
    
    @IBOutlet var originTownLabel: UILabel!
    @IBOutlet var originTimeLabel: UILabel!
    @IBOutlet var originWeatherIcon: UIImageView!
    @IBOutlet var originWeatherDescriptionLabel: UILabel!
    @IBOutlet var originTemperatureLabel: UILabel!
    @IBOutlet var originLoadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet var destinationTownLabel: UILabel!
    @IBOutlet var destinationTimeLabel: UILabel!
    @IBOutlet var destinationWeatherIcon: UIImageView!
    @IBOutlet var destinationWeatherDescriptionLabel: UILabel!
    @IBOutlet var destinationTemperatureLabel: UILabel!
    @IBOutlet var destinationLoadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet var refreshButton: UIBarButtonItem!
    
    // Events //
    // --------//
    
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        loadWeather()
    }
    
    // Logic //
    // -------//

    // Loading state
    
    var loadings = 0
    
    func initLoadings() {
        refreshButton.isEnabled = false
        loadings = 2
    }
    
    func loadingEnded() {
        loadings -= 1
        if loadings == 0 {
            refreshButton.isEnabled = true
        }
    }
    
    // Weather loading
    
    func loadWeather() {
        initLoadings()
        
        originWeatherInterface.clear()
        destinationWeatherInterface.clear()
        
        loadTownWeather(for: originTown, completionHandler: originWeatherInterface.update)
        loadTownWeather(for: destinationTown, completionHandler: destinationWeatherInterface.update)
    }
    
    func loadTownWeather(for town: Town, completionHandler: @escaping (WeatherData) -> Void) {
        let requestInputData = WeatherRequestInputData(latitude: town.latitude, longitude: town.longitude)
        weatherLoader.load(requestInputData) { weatherData in
            DispatchQueue.main.async {
                guard let weatherData = weatherData else {
                    self.present(self.weatherLoadingFailureAlert, animated: true, completion: nil)
                    return
                }

                completionHandler(weatherData)
                
                self.loadingEnded()
            }
        }
    }
    
    // Init
    
    func initInterface() {
        originTownLabel.text = originTown.name
        destinationTownLabel.text = destinationTown.name
        
        originWeatherInterface = TownWeatherInterface(
            timeLabel: originTimeLabel,
            weatherIcon: originWeatherIcon,
            weatherDescriptionLabel: originWeatherDescriptionLabel,
            temperatureLabel: originTemperatureLabel,
            loadingIndicator: originLoadingIndicator)
        
        destinationWeatherInterface = TownWeatherInterface(
            timeLabel: destinationTimeLabel,
            weatherIcon: destinationWeatherIcon,
            weatherDescriptionLabel: destinationWeatherDescriptionLabel,
            temperatureLabel: destinationTemperatureLabel,
            loadingIndicator: destinationLoadingIndicator)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initInterface()
        
        loadWeather()
    }
    
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}

//
//  WeatherViewController.swift
//  LeBaluchon
//
//  Created by Rodolphe Desruelles on 06/07/2022.
//

import UIKit

// Controller part for managing the weather UI of one town

class TownWeatherUI {
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

// Controller

class WeatherViewController: UIViewController {
    var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:MM"
        return df
    }()
    
    // Model //
    // ----- //
    
    let weatherLoader = APIRequestLoader(apiRequest: WeatherRequest())

    // UI state //
    // -------- //
    
    let originTown = Config.shared.originPlace
    let destinationTown = Config.shared.destinationPlace
            
    var originWeatherUI: TownWeatherUI!
    var destinationWeatherUI: TownWeatherUI!
    
    // View components //
    // --------------- //

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
    // ------ //
    
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        loadWeather()
    }
    
    // Logic //
    // ----- //

    // Loading state
    
    var loadings = 0
    
    func initLoadings() {
        refreshButton.isEnabled = false
        loadings = 2
    }
    
    func OneLoadingDidEnd() {
        loadings -= 1
        if loadings == 0 {
            refreshButton.isEnabled = true
        }
    }
    
    // Weather loading
    
    func loadWeather() {
        initLoadings()
        
        originWeatherUI.clear()
        destinationWeatherUI.clear()
        
        loadTownWeather(for: originTown, completionHandler: originWeatherUI.update)
        loadTownWeather(for: destinationTown, completionHandler: destinationWeatherUI.update)
    }
    
    func loadTownWeather(for town: Place, completionHandler: @escaping (WeatherData) -> Void) {
        let requestInputData = WeatherRequestInputData(latitude: town.latitude, longitude: town.longitude)
        
        weatherLoader.load(requestInputData) { weatherData in
            DispatchQueue.main.async {
                guard let weatherData = weatherData else {
                    self.present(self.weatherLoadingFailureAlert, animated: true, completion: nil)
                    return
                }

                completionHandler(weatherData)
                
                self.OneLoadingDidEnd()
            }
        }
    }
    
    // Init
    
    func initUI() {
        originTownLabel.text = originTown.name
        destinationTownLabel.text = destinationTown.name
        
        originWeatherUI = TownWeatherUI(
            timeLabel: originTimeLabel,
            weatherIcon: originWeatherIcon,
            weatherDescriptionLabel: originWeatherDescriptionLabel,
            temperatureLabel: originTemperatureLabel,
            loadingIndicator: originLoadingIndicator)
        
        destinationWeatherUI = TownWeatherUI(
            timeLabel: destinationTimeLabel,
            weatherIcon: destinationWeatherIcon,
            weatherDescriptionLabel: destinationWeatherDescriptionLabel,
            temperatureLabel: destinationTemperatureLabel,
            loadingIndicator: destinationLoadingIndicator)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
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

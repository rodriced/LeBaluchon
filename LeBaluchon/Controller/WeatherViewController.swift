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
    
    var town: Place
    
    var timeLabel: UILabel
    var weatherIcon: UIImageView
    var weatherDescriptionLabel: UILabel
    var temperatureLabel: UILabel
    var loadingIndicator: UIActivityIndicatorView
    var errorImage: UIImageView
    
    init(town: Place,
         timeLabel: UILabel,
         weatherIcon: UIImageView,
         weatherDescriptionLabel: UILabel,
         temperatureLabel: UILabel,
         loadingIndicator: UIActivityIndicatorView,
         errorImage: UIImageView
    )
    {
        self.town = town
        self.timeLabel = timeLabel
        self.weatherIcon = weatherIcon
        self.weatherDescriptionLabel = weatherDescriptionLabel
        self.temperatureLabel = temperatureLabel
        self.loadingIndicator = loadingIndicator
        self.errorImage = errorImage
    }
    
    func clear() {
        timeLabel.text = " "
        weatherIcon.isHidden = true
        loadingIndicator.isHidden = false
        errorImage.isHidden = true
        weatherDescriptionLabel.text = " "
        temperatureLabel.text = " "
    }
    
    func displayError() {
        timeLabel.text = " "
        weatherIcon.isHidden = true
        loadingIndicator.isHidden = true
        errorImage.isHidden = false
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
    @IBOutlet var originErrorImage: UIImageView!
    
    @IBOutlet var destinationTownLabel: UILabel!
    @IBOutlet var destinationTimeLabel: UILabel!
    @IBOutlet var destinationWeatherIcon: UIImageView!
    @IBOutlet var destinationWeatherDescriptionLabel: UILabel!
    @IBOutlet var destinationTemperatureLabel: UILabel!
    @IBOutlet var destinationLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet var destinationErrorImage: UIImageView!
    
    @IBOutlet var refreshButton: UIBarButtonItem!
    
    // Events //
    // ------ //
    
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        loadWeather()
    }
    
    // Logic //
    // ----- //

    // Loading state
    
    var loadingsInProgress = 0
    
    func loadingsStrating() {
        refreshButton.isEnabled = false
        loadingsInProgress = 2
    }
    
    func OneLoadingSuccessfull() {
        loadingsInProgress -= 1
        if loadingsInProgress == 0 {
            refreshButton.isEnabled = true
        }
    }
    
    func OneLoadingEndingWithError(for ui: TownWeatherUI) {
        loadingsInProgress -= 1
        ui.displayError()

        if !weatherLoadingFailureAlert.isBeingPresented {
            self.present(self.weatherLoadingFailureAlert, animated: true) {
                if self.loadingsInProgress == 0 {
                    self.refreshButton.isEnabled = true
                }
            }
        }
    }
        
    // Weather loading
    
    func loadWeather() {
        loadingsStrating()

        originWeatherUI.clear()
        destinationWeatherUI.clear()

        loadTownWeather(for: originWeatherUI, completionHandler: originWeatherUI.update)
        loadTownWeather(for: destinationWeatherUI, completionHandler: destinationWeatherUI.update)
    }

    func loadTownWeather(for ui: TownWeatherUI, completionHandler: @escaping (WeatherData) -> Void) {
        let requestInputData = WeatherRequestInputData(latitude: ui.town.latitude, longitude: ui.town.longitude)

        weatherLoader.load(requestInputData) { weatherData in
            DispatchQueue.main.async {
                guard let weatherData = weatherData else {
                    self.OneLoadingEndingWithError(for: ui)
                    return
                }

                completionHandler(weatherData)

                self.OneLoadingSuccessfull()
            }
        }
    }

    // Init
    
    func initUI() {
        originTownLabel.text = originTown.name
        destinationTownLabel.text = destinationTown.name
        
        originWeatherUI = TownWeatherUI(
            town: originTown,
            timeLabel: originTimeLabel,
            weatherIcon: originWeatherIcon,
            weatherDescriptionLabel: originWeatherDescriptionLabel,
            temperatureLabel: originTemperatureLabel,
            loadingIndicator: originLoadingIndicator,
            errorImage: originErrorImage
        )
        
        destinationWeatherUI = TownWeatherUI(
            town: destinationTown,
            timeLabel: destinationTimeLabel,
            weatherIcon: destinationWeatherIcon,
            weatherDescriptionLabel: destinationWeatherDescriptionLabel,
            temperatureLabel: destinationTemperatureLabel,
            loadingIndicator: destinationLoadingIndicator,
            errorImage: destinationErrorImage
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        loadWeather()
    }
    
}

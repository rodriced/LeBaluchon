//
//  Weather.swift
//  LeBaluchon
//
//  Created by Rodolphe Desruelles on 20/06/2022.
//

import Foundation

// The current weather for a town is retrieve with the Openweather API

// API Request Result Data

struct WeatherDataElement: Equatable, Decodable {
    let description: String
    let icon: String
}

struct WeatherData: Equatable {
    var timestamp: Int
    var timezone: Int
    var weatherArray: [WeatherDataElement]
    var temperature: Double

    enum CodingKeys: String, CodingKey {
        case dt
        case timezone
        case weather
        case main
    }

    enum MainKeys: String, CodingKey {
        case temp
    }
}

extension WeatherData: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try values.decode(Int.self, forKey: .dt)
        timezone = try values.decode(Int.self, forKey: .timezone)
        weatherArray = try values.decode([WeatherDataElement].self, forKey: .weather)

        let mainValues = try values.nestedContainer(keyedBy: MainKeys.self, forKey: .main)
        temperature = try mainValues.decode(Double.self, forKey: .temp)
    }
}

// API Request input data

struct WeatherRequestInputData {
    let latitude: Double
    let longitude: Double
}

// API Request

enum WeatherRequestError: Error {
    case missingApiKey
}

struct WeatherRequest: APIRequest {
    static let decoder = JSONDecoder()

    var apiKey: String?

    init(apiKey: String? = Bundle.main.infoDictionary?["OPENWEATHER_API_KEY"] as? String) {
        self.apiKey = apiKey
    }

    func makeRequest(from inputData: WeatherRequestInputData) throws -> URLRequest {
        guard let apiKey = apiKey else {
            print("Error: Missing API Key")
            throw WeatherRequestError.missingApiKey
        }

        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!

        components.queryItems = [
            URLQueryItem(name: "lat", value: String(inputData.latitude)),
            URLQueryItem(name: "lon", value: String(inputData.longitude)),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "fr"),
            URLQueryItem(name: "appid", value: apiKey)
        ]

        return URLRequest(url: components.url!, timeoutInterval: 10.0)
    }

    func parseResponse(data: Data) throws -> WeatherData {
        return try Self.decoder.decode(WeatherData.self, from: data)
    }
}

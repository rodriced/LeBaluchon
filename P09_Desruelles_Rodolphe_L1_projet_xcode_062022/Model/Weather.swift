//
//  Weather.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rodolphe Desruelles on 20/06/2022.
//

import Foundation

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

class InvalidWeatherData: Error {}

struct WeatherRequestInputData {
    let latitude: Double
    let longitude: Double
}

struct WeatherRequest: APIRequest {
    static let decoder = JSONDecoder()

    static let apiKey = Bundle.main.infoDictionary?["OPENWEATHER_API_KEY"] as? String

    func makeRequest(from inputData: WeatherRequestInputData) throws -> URLRequest {
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!

        var queryItems = [
            URLQueryItem(name: "lat", value: String(inputData.latitude)),
            URLQueryItem(name: "lon", value: String(inputData.longitude)),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "fr")
        ]

        if let apiKey = Self.apiKey {
            queryItems.append(URLQueryItem(name: "appid", value: apiKey))
        }

        components.queryItems = queryItems

        let request = URLRequest(url: components.url!)
        print(request)
        return request
    }

    func parseResponse(data: Data) throws -> WeatherData {
        return try Self.decoder.decode(WeatherData.self, from: data)
    }
}

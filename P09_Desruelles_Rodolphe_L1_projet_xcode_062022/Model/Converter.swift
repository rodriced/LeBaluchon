//
//  Rates.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rodolphe Desruelles on 20/06/2022.
//

import Foundation

struct RatesData: Decodable, Equatable {
    let success: Bool
    let timestamp: Int
    let base: String
    let date: String
    let rates: [String: Double]
    
    static func getSample() -> RatesData {
        return RatesData(
            success: true,
            timestamp: 1656070863,
            base: "EUR",
            date: "2022-06-24",
            rates: ["USD": 1.053507]
        )
    }
}

class InvalidRatesData: Error {}

struct RatesRequestData {
    let baseCurrency: String
    let targetCurrencies: [String]
    
    init(baseCurrency: String, targetCurrency:String) {
        self.baseCurrency = baseCurrency
        self.targetCurrencies = [targetCurrency]
    }
}

struct RatesRequest: APIRequest {
    static let decoder = JSONDecoder()

    static let apiKey = Bundle.main.infoDictionary?["FIXER_IO_API_KEY"] as? String

    func makeRequest(from data: RatesRequestData) throws -> URLRequest {
        var components = URLComponents(string: "https://api.apilayer.com/fixer/latest")!
        components.queryItems = [
            URLQueryItem(name: "base", value: data.baseCurrency),
            URLQueryItem(name: "symbols", value: data.targetCurrencies.joined(separator: ","))
        ]

        var request = URLRequest(url: components.url!)
        Self.apiKey.map {
            request.addValue($0, forHTTPHeaderField: "apikey")
        }

        return request
    }

    func parseResponse(data: Data) throws -> RatesData {
        let ratesData = try Self.decoder.decode(RatesData.self, from: data)
        if !ratesData.success {
            throw InvalidRatesData()
        }
        return ratesData
    }
}


class Converter {
    let baseCurrency: String
    let targetCurrency: String

    let rate: Double
    let rateDate: String
    
    convenience init?(ratesData: RatesData) {
        guard ratesData.rates.count == 1, let (targetCurrency, rate) = ratesData.rates.first else {
            return nil
        }
        
        self.init(baseCurrency: ratesData.base, targetCurrency: targetCurrency, rate: rate, rateDate: ratesData.date)
    }

    init(baseCurrency: String, targetCurrency: String, rate: Double, rateDate: String) {
        self.baseCurrency = baseCurrency
        self.targetCurrency = targetCurrency
        self.rate = rate
        self.rateDate = rateDate
    }

    public func convert(_ amount: Double) -> Double {
        return amount * rate
    }
}

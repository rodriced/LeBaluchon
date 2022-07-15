//
//  Rates.swift
//  LeBaluchon
//
//  Created by Rodolphe Desruelles on 20/06/2022.
//

import Foundation

// API Request result data

struct RatesData: Decodable, Equatable {
    let success: Bool
    let timestamp: Int
    let base: String
    let date: String
    let rates: [String: Double]
}

// API Request input data

struct RatesRequestInputData {
    let baseCurrency: String
    let targetCurrencies: [String]

    init(baseCurrency: String, targetCurrency: String) {
        self.baseCurrency = baseCurrency
        self.targetCurrencies = [targetCurrency]
    }
}

// API Request

enum RatesRequestError: Error {
    case missingApiKey
    case missingParameter
    case invalidRatesData
}

struct RatesRequest: APIRequest {
    static let decoder = JSONDecoder()

    private var apiKey: String?

    init(apiKey: String? = Bundle.main.infoDictionary?["FIXER_IO_API_KEY"] as? String) {
        self.apiKey = apiKey
    }

    func makeRequest(from inputData: RatesRequestInputData) throws -> URLRequest {
        guard let apikey = apiKey else {
            throw RatesRequestError.missingApiKey
        }

        guard
            !inputData.baseCurrency.isEmpty,
            !inputData.targetCurrencies.isEmpty
        else {
            throw RatesRequestError.missingParameter
        }

        var components = URLComponents(string: "https://api.apilayer.com/fixer/latest")!
        components.queryItems = [
            URLQueryItem(name: "base", value: inputData.baseCurrency),
            URLQueryItem(name: "symbols", value: inputData.targetCurrencies.joined(separator: ","))
        ]

        var request = URLRequest(url: components.url!)
        request.addValue(apikey, forHTTPHeaderField: "apikey")

        return request
    }

    func parseResponse(data: Data) throws -> RatesData {
        let ratesData = try Self.decoder.decode(RatesData.self, from: data)
        if !ratesData.success {
            throw RatesRequestError.invalidRatesData
        }
        return ratesData
    }
}

// Converter

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

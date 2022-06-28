//
//  Rates.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rodolphe Desruelles on 20/06/2022.
//

import Foundation

struct Rates: Decodable {
    let success: Bool
    let timestamp: Int
    let base: String
    let date: String
    let rates: [String: Double]
    
    static var decoder = JSONDecoder()
}

// class RatesService {
//    static let shared = RatesService()
//    private init() {}
//
//    static let ratesBaseUrl = "https://api.apilayer.com/fixer/latest"
//    static let rateUrl = { (base: String, target: String) in "\(RatesService.ratesBaseUrl)?base=\(base)&symbols=\(target)"}
//
//    static let fetcher = NetworkJsonFetcher()
//
//    func getRatesSample() -> Rates {
//        return Rates(
//            success: true,
//            timestamp: 1656070863,
//            base: "EUR",
//            date: "2022-06-24",
//            rates: ["USD": 1.053507]
//        )
//    }
//
//    func getRates(baseCurrency: String, targetCurrency: String, completionHandler: @escaping (Rates?) -> Void) {
//        completionHandler(self.getRatesSample())
//
// //        Self.fetcher.fetchJson(Self.rateUrl(, headers: ["apikey": ""])
// //            { rates in
// //                completionHandler(rates)
// //            }
//    }
// }

class ConverterService {
    let testing = true

    static let shared = ConverterService()
    
    private init() {
        apiKey = Bundle.main.infoDictionary?["FIXER_IO_API_KEY"] as? String
    }
    
    private let apiKey: String?
    
    static let ratesBaseUrl = "https://api.apilayer.com/fixer/latest"
    static let rateUrl = { (base: String, target: String) in "\(ConverterService.ratesBaseUrl)?base=\(base)&symbols=\(target)" }

    static let ratesFetcher = NetworkJsonFetcher()
    
    func fetchRates(baseCurrency: String, targetCurrency: String, completionHandler: @escaping (Rates?) -> Void) {
        guard !testing else {
            completionHandler(getRatesSample())
            return
        }
        
        guard let apiKey = apiKey else {
            print("Error : No fixer.io api key defined")
            return
        }
        
        let url = Self.rateUrl(baseCurrency, targetCurrency)
        
        Self.ratesFetcher.fetchJson(url, headers: ["apikey": apiKey])
            { rates in
                completionHandler(rates)
            }
    }
    
    func getConverter(baseCurrency: String, targetCurrency: String, completionHandler: @escaping (Converter?) -> Void) {
        fetchRates(baseCurrency: baseCurrency, targetCurrency: targetCurrency) { rates in
            guard let rates = rates else {
                print("Converter not ready")
                completionHandler(nil)
                return
            }

            let rate = rates.rates[targetCurrency]!
            let converter = Converter(baseCurrency: baseCurrency, targetCurrency: targetCurrency, rate: rate, rateDate: rates.date)

            completionHandler(converter)
        }
    }
    
    func getRatesSample() -> Rates {
        return Rates(
            success: true,
            timestamp: 1656070863,
            base: "EUR",
            date: "2022-06-24",
            rates: ["USD": 1.053507]
        )
    }

}

class Converter {
    let baseCurrency: String
    let targetCurrency: String
    
    let rate: Double
    let rateDate: String
    
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

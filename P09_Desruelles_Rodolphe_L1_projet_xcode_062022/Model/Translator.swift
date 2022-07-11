//
//  Translator.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rodolphe Desruelles on 03/07/2022.
//

import Foundation

struct TranslationDataTranslation: Decodable, Equatable {
    let to: String
    let text: String
}

struct TranslationDataTranslations: Decodable, Equatable {
    let translations: [TranslationDataTranslation]
}

typealias TranslationData = [TranslationDataTranslations]

struct TranslationRequestInputData {
    let targetLanguage: String
    let sourceLanguage: String
    let text: String
}

enum TranslationRequestError: Error {
    case missingParameter
}

struct TranslationRequest: APIRequest {
    static let decoder = JSONDecoder()

    static let subscriptionKey = Bundle.main.infoDictionary?["MICROSOFT_TRANSLATOR_SUBSCRIPTION_KEY"] as? String
    static let subscriptionRegion = Bundle.main.infoDictionary?["MICROSOFT_TRANSLATOR_SUBSCRIPTION_REGION"] as? String

    func makeRequest(from inputData: TranslationRequestInputData) throws -> URLRequest {
        guard let subscriptionKey = Self.subscriptionKey,
              let subscriptionRegion = Self.subscriptionRegion,
              !inputData.sourceLanguage.isEmpty,
              !inputData.targetLanguage.isEmpty
        else {
            throw TranslationRequestError.missingParameter
        }

        var components = URLComponents(string: "https://api.cognitive.microsofttranslator.com/")!
        components.path = "/translate"
        components.queryItems = [
            URLQueryItem(name: "from", value: inputData.sourceLanguage),
            URLQueryItem(name: "to", value: inputData.targetLanguage),
            URLQueryItem(name: "api-version", value: "3.0"),
            URLQueryItem(name: "textType", value: "plain"),
//            URLQueryItem(name: "model", value: "nmt"),
        ]

        let jsonTexts = try JSONEncoder().encode([["Text": inputData.text]])

        var request = URLRequest(url: components.url!)
        request.httpBody = jsonTexts

        request.addValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.addValue(subscriptionRegion, forHTTPHeaderField: "Ocp-Apim-Subscription-Region")
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-type")
        request.addValue(String(jsonTexts.count), forHTTPHeaderField: "Content-length")
        request.httpMethod = "POST"

//        print(String(data:request.httpBody!, encoding: .utf8)!)
//        print()
//        print(request.allHTTPHeaderFields!)
//        print()

        return request
    }

    func parseResponse(data: Data) throws -> TranslationData {
        return try Self.decoder.decode(TranslationData.self, from: data)
    }
}

//
//  Translator.swift
//  LeBaluchon
//
//  Created by Rodolphe Desruelles on 03/07/2022.
//

import Foundation

// The translation is retrieve with the Microsoft translator API

// API Request result data

struct TranslationDataElement: Decodable, Equatable {
    let to: String
    let text: String
}

struct TranslationDataElements: Decodable, Equatable {
    let translations: [TranslationDataElement]
}

typealias TranslationData = [TranslationDataElements]

typealias TranslationRequestResultData = String

// API Request input Data

struct TranslationRequestInputData {
    let targetLanguage: String
    let sourceLanguage: String
    let text: String
}

// API Request

enum TranslationRequestError: Error {
    case missingApiKey
    case missingParameter
}

struct TranslationRequest: APIRequest {
    static let decoder = JSONDecoder()

    var subscriptionKey: String?
    var subscriptionRegion: String?

    init(subscriptionKey: String? = Bundle.main.infoDictionary?["MICROSOFT_TRANSLATOR_SUBSCRIPTION_KEY"] as? String,
         subscriptionRegion: String? = Bundle.main.infoDictionary?["MICROSOFT_TRANSLATOR_SUBSCRIPTION_REGION"] as? String)
    {
        self.subscriptionKey = subscriptionKey
        self.subscriptionRegion = subscriptionRegion
    }

    func makeRequest(from inputData: TranslationRequestInputData) throws -> URLRequest {
        guard let subscriptionKey = subscriptionKey,
              let subscriptionRegion = subscriptionRegion
        else {
            throw TranslationRequestError.missingApiKey
        }

        guard !inputData.sourceLanguage.isEmpty,
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

    func parseResponse(data: Data) throws -> TranslationRequestResultData {
        let translationData = try Self.decoder.decode(TranslationData.self, from: data)
        return translationData[0].translations[0].text
    }
}

//
//  Translator.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rod on 03/07/2022.
//

import Foundation

struct TranslationResultTranslation: Decodable, Equatable {
    let to: String
    let text: String
}

struct TranslationResultTranslations: Decodable, Equatable {
    let translations: [TranslationResultTranslation]
}

typealias TranslationResult = [TranslationResultTranslations]

struct TranslationRequestData {
    let targetLanguage: String
    let sourceLanguage: String
    let text: String
}

struct TranslationRequest: APIRequest {
    static let decoder = JSONDecoder()

    static let subscriptionKey = Bundle.main.infoDictionary?["MICROSOFT_TRANSLATOR_SUBSCRIPTION_KEY"] as? String
    static let subscriptionRegion = Bundle.main.infoDictionary?["MICROSOFT_TRANSLATOR_SUBSCRIPTION_REGION"] as? String

    func makeRequest(from data: TranslationRequestData) throws -> URLRequest {
        var components = URLComponents(string: "https://api.cognitive.microsofttranslator.com/")!
        components.path = "/translate"
        components.queryItems = [
            URLQueryItem(name: "from", value: data.sourceLanguage),
            URLQueryItem(name: "to", value: data.targetLanguage),
            URLQueryItem(name: "api-version", value: "3.0"),
            URLQueryItem(name: "textType", value: "plain"),
//            URLQueryItem(name: "model", value: "nmt"),
        ]

        let jsonTexts = try JSONEncoder().encode([["Text": data.text]])

        var request = URLRequest(url: components.url!)
        request.httpBody = jsonTexts

        Self.subscriptionKey.map {
            request.addValue($0, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        }
        Self.subscriptionRegion.map {
            request.addValue($0, forHTTPHeaderField: "Ocp-Apim-Subscription-Region")
        }
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-type")
        request.addValue(String(jsonTexts.count), forHTTPHeaderField: "Content-length")
        request.httpMethod = "POST"

//        print(String(data:request.httpBody!, encoding: .utf8)!)
//        print()
//        print(request.allHTTPHeaderFields!)
//        print()

        return request
    }

    func parseResponse(data: Data) throws -> TranslationResult {
        return try Self.decoder.decode(TranslationResult.self, from: data)
    }
}

// struct TranslateTextResponseTranslation: Decodable, Equatable {
////    let detectedSourceLanguage: String
////    let model: String
//    let translatedText: String
// }
//
// struct TranslateTextResponseList: Decodable, Equatable {
//    let translations: [TranslateTextResponseTranslation]
// }
//
// struct TranslateData: Decodable, Equatable {
//    let data: TranslateTextResponseList
// }
//
// struct TranslateRequestData {
//    let inputText: String
//    let targetLanguage: String
//    let sourceLanguage: String
// }
//
// struct TraslateRequest: APIRequest {
//    static let decoder = JSONDecoder()
//
//    static let apiKey = Bundle.main.infoDictionary?["GOOGLE_TRANSLATE_API_KEY"] as? String
//
//    func makeRequest(from data: TranslateRequestData) throws -> URLRequest {
//        var components = URLComponents(string: "https://translation.googleapis.com/language/translate/v2")!
//        components.queryItems = [
//            URLQueryItem(name: "q", value: data.inputText),
//            URLQueryItem(name: "target", value: data.targetLanguage),
//            URLQueryItem(name: "format", value: "text"),
//            URLQueryItem(name: "source", value: data.sourceLanguage),
////            URLQueryItem(name: "model", value: "nmt"),
//        ]
//
//        Self.apiKey.map { components.queryItems!.append(URLQueryItem(name: "key", value: $0)) }
//
//        var request = URLRequest(url: components.url!)
//        request.httpMethod = "POST"
//        return request
//    }
//
//    func parseResponse(data: Data) throws -> TranslateData {
//        return try Self.decoder.decode(TranslateData.self, from: data)
//    }
// }

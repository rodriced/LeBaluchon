//
//  FakeResponseData.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022Tests
//
//  Created by Rod on 29/06/2022.
//

import Foundation

class FakeResponseDataError : Error {}

class FakeResponseData {

    static func dataFromRessource(_ resource: String) -> Data? {
        let bundle = Bundle(for: FakeResponseData.self)
        let url = bundle.url(forResource: resource, withExtension: "json")!
        return try? Data(contentsOf: url)
    }
    
    init(dataResourceOK: String) {
        dataOK = Self.dataFromRessource(dataResourceOK)!
        responseOK = Self.httpResponse(statusCode: 200)
        responseKO = Self.httpResponse(statusCode: 500)
    }

    var dataOK: Data
    let badJsondata = "bad json".data(using: .utf8)!
    
    let responseOK: HTTPURLResponse
    let responseKO: HTTPURLResponse

    static func httpResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://openclassrooms.com")!, statusCode: statusCode, httpVersion: nil, headerFields: [:])!
    }

//    private let response = { HTTPURLResponse(url: URL(string: "https://openclassrooms.com")!, statusCode: $0, httpVersion: nil, headerFields: [:])! }
//
//    lazy var responseOK = response(200)
//    lazy var responseKO = response(500)

    static let error = FakeResponseDataError()

}

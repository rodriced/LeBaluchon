//
//  FakeResponseData.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022Tests
//
//  Created by Rod on 29/06/2022.
//

import Foundation

class FakeResponseDataError : Error {}

class FakeResponseData {

    static func getDataFromResource(_ resource: String) -> Data? {
        let bundle = Bundle(for: FakeResponseData.self)
        let url = bundle.url(forResource: resource, withExtension: "json")!
        return try? Data(contentsOf: url)
    }
    
    init(resourceOK: String, resourceKO: String) {
        dataOK = Self.getDataFromResource(resourceOK)
        dataKO = Self.getDataFromResource(resourceKO)
    }
    
    var dataOK: Data?
    var dataKO: Data?
    
    var dataBadJson: Data? { "bad json".data(using: .utf8) }
    
    private let response = { HTTPURLResponse(url: URL(string: "https://openclassrooms.com")!, statusCode: $0, httpVersion: nil, headerFields: [:])! }

    lazy var responseOK = response(200)
    lazy var responseKO = response(500)

    let error = FakeResponseDataError()

}

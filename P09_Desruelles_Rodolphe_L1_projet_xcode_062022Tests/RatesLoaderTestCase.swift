//
//  RatesLoaderTestCase.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022Tests
//
//  Created by Rod on 03/07/2022.
//

@testable import P09_Desruelles_Rodolphe_L1_projet_xcode_062022

import XCTest

class RatesLoaderTestCase: XCTestCase {
    var loader: APIRequestLoader<RatesRequest>!

    static let fakeResponseData = FakeResponseData(resourceOK: "RatesDataOK", resourceKO: "RatesDataKO")
    
    override func setUp() {
        let apiRequest = RatesRequest()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        self.loader = APIRequestLoader(apiRequest: apiRequest, urlSession: urlSession)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoaderSuccess() {
        let requestData = RatesRequestData(baseCurrency: "EUR", targetCurrency: "USD")
        let responseData = Self.fakeResponseData.dataOK!
        let response = Self.fakeResponseData.responseOK
        let expectedRates =
            RatesData(
                success: true,
                timestamp: 1656512403,
                base: "EUR",
                date: "2022-06-29",
                rates: ["USD": 1.048361]
            )
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.query?.contains("base=EUR"), true)
            return (response, responseData)
        }
        
        let expectation = XCTestExpectation(description: "response")
        self.loader.load(requestData: requestData) { rates in
            XCTAssertEqual(rates, expectedRates)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testLoaderFailureWhenRatesDataIsNotValid() {
        let requestData = RatesRequestData(baseCurrency: "EUR", targetCurrency: "USD")
        let responseData = Self.fakeResponseData.dataKO!
        let response = Self.fakeResponseData.responseOK
        
        MockURLProtocol.requestHandler = { request in
            return (response, responseData)
        }
        
        let expectation = XCTestExpectation(description: "response")
        self.loader.load(requestData: requestData) { rates in
            XCTAssertEqual(rates, nil)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testLoaderFailureWhenDataIsBadJson() {
        let requestData = RatesRequestData(baseCurrency: "EUR", targetCurrency: "USD")
        let responseData = Self.fakeResponseData.dataBadJson!
        let response = Self.fakeResponseData.responseOK
        
        MockURLProtocol.requestHandler = { request in
            return (response, responseData)
        }
        
        let expectation = XCTestExpectation(description: "response")
        self.loader.load(requestData: requestData) { rates in
            XCTAssertEqual(rates, nil)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testLoaderFailureWhenHTTPResponseStatusCodeIsNot200() {
        let requestData = RatesRequestData(baseCurrency: "EUR", targetCurrency: "USD")
        let responseData = Self.fakeResponseData.dataOK!
        let response = Self.fakeResponseData.responseKO

        MockURLProtocol.requestHandler = { request in
            return (response, responseData)
        }
        
        let expectation = XCTestExpectation(description: "response")
        self.loader.load(requestData: requestData) { rates in
            XCTAssertEqual(rates, nil)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    class FakeError: Error {}
    
    func testLoaderFailureWhenErrorIsThrownDuringLoading() {
        let requestData = RatesRequestData(baseCurrency: "EUR", targetCurrency: "USD")

        MockURLProtocol.requestHandler = { request in
            throw FakeError()
        }
        
        let expectation = XCTestExpectation(description: "response")
        self.loader.load(requestData: requestData) { rates in
            XCTAssertEqual(rates, nil)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

}

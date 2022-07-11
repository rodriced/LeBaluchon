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

    static let fakeResponseData = FakeResponseData(dataResourceOK: "RatesDataOK")
    static let responseDataWithNoSuccess = FakeResponseData.dataFromRessource("RatesDataNoSuccess")!
    static let responseDataWithMissingField = FakeResponseData.dataFromRessource("RatesDataMissingField")!

    static let ratesDataOK = RatesData(
        success: true,
        timestamp: 1656512403,
        base: "EUR",
        date: "2022-06-29",
        rates: ["USD": 1.048361]
    )

    static let ratesDataWithNotOnlyOneRate = RatesData(
        success: true,
        timestamp: 1656512403,
        base: "EUR",
        date: "2022-06-29",
        rates: ["USD": 1.048361,
                "GBP": 1.12007]
    )

    override func setUp() {
        let apiRequest = RatesRequest()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        loader = APIRequestLoader(apiRequest: apiRequest, urlSession: urlSession)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoaderSuccess() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: RatesRequestInputData(baseCurrency: "EUR", targetCurrency: "USD"),
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: Self.ratesDataOK
        )
        wait(for: [expectation], timeout: 1)
    }

    func testLoaderFailureWithMissingValueInRequestInputData() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: RatesRequestInputData(baseCurrency: "", targetCurrency: "USD"),
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testLoaderFailureWhenRatesDataHasNoSuccess() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: RatesRequestInputData(baseCurrency: "EUR", targetCurrency: "USD"),
            responseData: Self.responseDataWithNoSuccess,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
//        let requestInputData = RatesRequestInputData(baseCurrency: "EUR", targetCurrency: "USD")
//        let responseData = Self.responseDataWithNoSuccess
//        let response = Self.fakeResponseData.responseOK
//
//        MockURLProtocol.requestHandler = { _ in
//            (response, responseData)
//        }
//
//        let expectation = XCTestExpectation(description: "response")
//        self.loader.load(requestInputData: requestInputData) { rates in
//            XCTAssertEqual(rates, nil)
//            expectation.fulfill()
//        }
        wait(for: [expectation], timeout: 1)
    }

    func testLoaderFailureWhenResponseDataHasMissingField() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: RatesRequestInputData(baseCurrency: "EUR", targetCurrency: "USD"),
            responseData: Self.responseDataWithMissingField,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testLoaderFailureWhenDataIsBadJson() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: RatesRequestInputData(baseCurrency: "EUR", targetCurrency: "USD"),
            responseData: Self.fakeResponseData.badJsondata,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
//        let requestInputData = RatesRequestInputData(baseCurrency: "EUR", targetCurrency: "USD")
//        let responseData = Self.fakeResponseData.badJsondata
//        let response = Self.fakeResponseData.responseOK
//
//        MockURLProtocol.requestHandler = { _ in
//            (response, responseData)
//        }
//
//        let expectation = XCTestExpectation(description: "response")
//        self.loader.load(requestInputData: requestInputData) { rates in
//            XCTAssertEqual(rates, nil)
//            expectation.fulfill()
//        }
        wait(for: [expectation], timeout: 1)
    }

    func testLoaderFailureWhenHTTPResponseStatusCodeIsNot200() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: RatesRequestInputData(baseCurrency: "EUR", targetCurrency: "USD"),
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseKO,
            expectedResultData: nil
        )
//        let requestInputData = RatesRequestInputData(baseCurrency: "EUR", targetCurrency: "USD")
//        let responseData = Self.fakeResponseData.dataOK
//        let response = Self.fakeResponseData.responseKO
//
//        MockURLProtocol.requestHandler = { _ in
//            (response, responseData)
//        }
//
//        let expectation = XCTestExpectation(description: "response")
//        self.loader.load(requestInputData: requestInputData) { rates in
//            XCTAssertEqual(rates, nil)
//            expectation.fulfill()
//        }
        wait(for: [expectation], timeout: 1)
    }

    func testLoaderFailureWhenErrorIsThrownDuringLoading() {
        let expectation = TestsHelper.testLoaderFailureWhenErrorIsThrownDuringLoading(
            loader,
            requestInputData: RatesRequestInputData(baseCurrency: "EUR", targetCurrency: "USD"),
            thrownError: FakeResponseData.error
        )
//        let requestInputData = RatesRequestInputData(baseCurrency: "EUR", targetCurrency: "USD")
//
//        MockURLProtocol.requestHandler = { _ in
//            throw FakeError()
//        }
//
//        let expectation = XCTestExpectation(description: "response")
//        self.loader.load(requestInputData: requestInputData) { rates in
//            XCTAssertEqual(rates, nil)
//            expectation.fulfill()
//        }
        wait(for: [expectation], timeout: 1)
    }

    func testConverter() {
        let converter = Converter(ratesData: Self.ratesDataOK)!

        XCTAssertEqual(converter.convert(1.5), 1.5725415000000003)
    }

    func testConverterInitializationFailure() {
        let converter = Converter(ratesData: Self.ratesDataWithNotOnlyOneRate)

        XCTAssertNil(converter)
    }
}

//
//  ConverterTestCase.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022Tests
//
//  Created by Rodolphe Desruelles on 03/07/2022.
//

@testable import P09_Desruelles_Rodolphe_L1_projet_xcode_062022

import XCTest

class ConverterTestCase: XCTestCase {
    var loader: APIRequestLoader<RatesRequest>!

    static let fakeResponseData = FakeResponseData(dataResourceOK: "RatesDataOK")
    static let responseDataWithNoSuccess = FakeResponseData.dataFromRessource("RatesDataNoSuccess")!
    static let responseDataWithMissingField = FakeResponseData.dataFromRessource("RatesDataMissingField")!

    static let requestResultDataOK = RatesData(
        success: true,
        timestamp: 1656512403,
        base: "EUR",
        date: "2022-06-29",
        rates: ["USD": 1.048361]
    )

    static let ratesRequestResultDataWithNotOnlyOneRate = RatesData(
        success: true,
        timestamp: 1656512403,
        base: "EUR",
        date: "2022-06-29",
        rates: ["USD": 1.048361,
                "GBP": 1.12007]
    )
    
    static let requestInputDataOK = RatesRequestInputData(baseCurrency: "EUR", targetCurrency: "USD")
    static let requestInputDataWithMissingValue = RatesRequestInputData(baseCurrency: "", targetCurrency: "USD")

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

    func testRatesLoaderSuccess() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: Self.requestResultDataOK
        )
        wait(for: [expectation], timeout: 1)
    }

    func testRatesLoaderFailureWithMissingValueInRequestInputData() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataWithMissingValue,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testRatesLoaderFailureWhenRatesDataHasNoSuccess() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.responseDataWithNoSuccess,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testRatesLoaderFailureWhenResponseDataHasMissingField() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.responseDataWithMissingField,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testRatesLoaderFailureWhenDataIsBadJson() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.badJsondata,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testRatesLoaderFailureWhenHTTPResponseStatusCodeIsNot200() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseKO,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testRatesLoaderFailureWhenErrorIsThrownDuringLoading() {
        let expectation = TestsHelper.testLoaderFailureWhenErrorIsThrownDuringLoading(
            loader,
            requestInputData: Self.requestInputDataOK,
            thrownError: FakeResponseData.error
        )
        wait(for: [expectation], timeout: 1)
    }

    func testConverterInitializationAndConputation() {
        let converter = Converter(ratesData: Self.requestResultDataOK)!

        XCTAssertEqual(converter.convert(1.5), 1.5725415000000003)
    }

    func testConverterInitializationFailure() {
        let converter = Converter(ratesData: Self.ratesRequestResultDataWithNotOnlyOneRate)

        XCTAssertNil(converter)
    }
}

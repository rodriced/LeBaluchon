//
//  ConverterTestCase.swift
//  LeBaluchonTests
//
//  Created by Rodolphe Desruelles on 03/07/2022.
//

@testable import LeBaluchon

import XCTest

class ConverterTestCase: XCTestCase {
    // Data for tests

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

    // RatesLoader tests

    func testRatesLoaderSuccess() {
        let loader = TestsHelper.buildTestLoader(RatesRequest())

        let expectation = TestsHelper.testLoaderExpectedResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: Self.requestResultDataOK
        )
        wait(for: [expectation], timeout: 1)
    }

    func testWeatherLoaderFailureWhenMissingApiKey() {
        let apiRequest = RatesRequest(apiKey: nil)
        let loader = TestsHelper.buildTestLoader(apiRequest)

        let expectation = TestsHelper.testLoaderExpectedResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testRatesLoaderFailureWhenInputParameterHasMissingValue() {
        let loader = TestsHelper.buildTestLoader(RatesRequest())

        let expectation = TestsHelper.testLoaderExpectedResultData(
            loader,
            requestInputData: Self.requestInputDataWithMissingValue,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testRatesLoaderFailureWhenRatesDataHasNoSuccess() {
        let loader = TestsHelper.buildTestLoader(RatesRequest())

        let expectation = TestsHelper.testLoaderExpectedResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.responseDataWithNoSuccess,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testRatesLoaderFailureWhenResponseDataHasMissingField() {
        let loader = TestsHelper.buildTestLoader(RatesRequest())

        let expectation = TestsHelper.testLoaderExpectedResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.responseDataWithMissingField,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testRatesLoaderFailureWhenDataIsBadJson() {
        let loader = TestsHelper.buildTestLoader(RatesRequest())

        let expectation = TestsHelper.testLoaderExpectedResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.badJsondata,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testRatesLoaderFailureWhenHTTPResponseStatusCodeIsNot200() {
        let loader = TestsHelper.buildTestLoader(RatesRequest())

        let expectation = TestsHelper.testLoaderExpectedResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseKO,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testRatesLoaderFailureWhenErrorIsThrownDuringLoading() {
        let loader = TestsHelper.buildTestLoader(RatesRequest())

        let expectation = TestsHelper.testLoaderExpectedFailureWhenErrorIsThrownDuringLoading(
            loader,
            requestInputData: Self.requestInputDataOK,
            thrownError: FakeResponseData.error
        )
        wait(for: [expectation], timeout: 1)
    }

    // Converter tests

    func testConverterInitializationAndConputation() {
        let converter = Converter(ratesData: Self.requestResultDataOK)!

        XCTAssertEqual(converter.convert(1.5), 1.5725415000000003)
    }

    func testConverterInitializationFailure() {
        let converter = Converter(ratesData: Self.ratesRequestResultDataWithNotOnlyOneRate)

        XCTAssertNil(converter)
    }
}

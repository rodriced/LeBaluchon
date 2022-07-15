//
//  WeatherTestCase.swift
//  LeBaluchonTests
//
//  Created by Rodolphe Desruelles on 03/07/2022.
//

@testable import LeBaluchon

import XCTest

class WeatherTestCase: XCTestCase {
    // Data for tests

    static let fakeResponseData = FakeResponseData(dataResourceOK: "WeatherDataOK")

    static let responseDataWithMissingMainField = FakeResponseData.dataFromRessource("WeatherDataMissingMainField")!

    static let requestResultDataOK = WeatherData(
        timestamp: 1657550317,
        timezone: 7200,
        weatherArray: [WeatherDataElement(description: "ciel dégagé", icon: "01d")], temperature: 29.63
    )

    static let requestInputDataOK = WeatherRequestInputData(
        latitude: 48.8588897,
        longitude: 2.3200410217200766
    )

    // WeatherLoader tests

    func testWeatherLoaderSuccess() {
        let loader = TestsHelper.buildTestLoader(WeatherRequest())

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
        let apiRequest = WeatherRequest(apiKey: nil)
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

    func testWeatherLoaderFailureWhenResponseDataHasMissingField() {
        let loader = TestsHelper.buildTestLoader(WeatherRequest())

        let expectation = TestsHelper.testLoaderExpectedResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.responseDataWithMissingMainField,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testWeatherLoaderFailureWhenDataIsBadJson() {
        let loader = TestsHelper.buildTestLoader(WeatherRequest())

        let expectation = TestsHelper.testLoaderExpectedResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.badJsondata,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testWeatherLoaderFailureWhenHTTPResponseStatusCodeIsNot200() {
        let loader = TestsHelper.buildTestLoader(WeatherRequest())

        let expectation = TestsHelper.testLoaderExpectedResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseKO,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testWeatherLoaderFailureWhenErrorIsThrownDuringLoading() {
        let loader = TestsHelper.buildTestLoader(WeatherRequest())

        let expectation = TestsHelper.testLoaderExpectedFailureWhenErrorIsThrownDuringLoading(
            loader,
            requestInputData: Self.requestInputDataOK,
            thrownError: FakeResponseData.error
        )
        wait(for: [expectation], timeout: 1)
    }
}

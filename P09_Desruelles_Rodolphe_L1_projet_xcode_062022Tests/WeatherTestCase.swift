//
//  WeatherTestCase.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022Tests
//
//  Created by Rodolphe Desruelles on 03/07/2022.
//

@testable import P09_Desruelles_Rodolphe_L1_projet_xcode_062022

import XCTest

class WeatherTestCase: XCTestCase {
    var loader: APIRequestLoader<WeatherRequest>!

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

    override func setUp() {
        loader = TestsHelper.buildTestLoader(WeatherRequest())
    }

    func testWeatherLoaderSuccess() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: Self.requestResultDataOK
        )
        wait(for: [expectation], timeout: 1)
    }

   func testWeatherLoaderFailureWithMissingApiKey() {
        //Overriding common initialized loader
        let apiRequest = WeatherRequest(apiKey: nil)
        loader = TestsHelper.buildTestLoader(apiRequest)

        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testWeatherLoaderFailureWhenResponseDataHasMissingField() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.responseDataWithMissingMainField,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testWeatherLoaderFailureWhenDataIsBadJson() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.badJsondata,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testWeatherLoaderFailureWhenHTTPResponseStatusCodeIsNot200() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseKO,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testWeatherLoaderFailureWhenErrorIsThrownDuringLoading() {
        let expectation = TestsHelper.testLoaderFailureWhenErrorIsThrownDuringLoading(
            loader,
            requestInputData: Self.requestInputDataOK,
            thrownError: FakeResponseData.error
        )
        wait(for: [expectation], timeout: 1)
    }
}


//
//  TranslatorTestCase.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022Tests
//
//  Created by Rodolphe Desruelles on 03/07/2022.
//

@testable import P09_Desruelles_Rodolphe_L1_projet_xcode_062022

import XCTest

class TranslatorTestCase: XCTestCase {
    var loader: APIRequestLoader<TranslationRequest>!

    static let fakeResponseData = FakeResponseData(dataResourceOK: "TranslationDataOK")

    static let responseDataWithMissingField = FakeResponseData.dataFromRessource("RatesDataMissingField")!
    static let requestResultDataOK = [
        TranslationDataTranslations(translations: [
            TranslationDataTranslation(to: "en", text: "Hello how are you doing?")
        ])
    ]

    static let requestInputDataOK = TranslationRequestInputData(
        targetLanguage: "en",
        sourceLanguage: "fr",
        text: "Bonjour, comment allez-vous ?"
    )

    static let requestInputDataWithMissingValue = TranslationRequestInputData(
        targetLanguage: "",
        sourceLanguage: "fr",
        text: "Bonjour, comment allez-vous ?"
    )

    override func setUp() {
        let apiRequest = TranslationRequest()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        loader = APIRequestLoader(apiRequest: apiRequest, urlSession: urlSession)
    }

    func testTranslationLoaderSuccess() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: Self.requestResultDataOK
        )
        wait(for: [expectation], timeout: 1)
    }

    func testTranslationLoaderFailureWithMissingValueInRequestInputData() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataWithMissingValue,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

   func testTranslationLoaderFailureWhenResponseDataHasMissingField() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.responseDataWithMissingField,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testTranslationLoaderFailureWhenDataIsBadJson() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.badJsondata,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testTranslationLoaderFailureWhenHTTPResponseStatusCodeIsNot200() {
        let expectation = TestsHelper.testLoaderResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseKO,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testTranslationLoaderFailureWhenErrorIsThrownDuringLoading() {
        let expectation = TestsHelper.testLoaderFailureWhenErrorIsThrownDuringLoading(
            loader,
            requestInputData: Self.requestInputDataOK,
            thrownError: FakeResponseData.error
        )
        wait(for: [expectation], timeout: 1)
    }
}

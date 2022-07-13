//
//  TranslatorTestCase.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022Tests
//
//  Created by Rodolphe Desruelles on 03/07/2022.
//

@testable import P09_Desruelles_Rodolphe_L1_projet_xcode_062022

import XCTest

class TranslatorTestCase: XCTestCase {
    // Data for tests
    
    static let fakeResponseData = FakeResponseData(dataResourceOK: "TranslationDataOK")

    static let responseDataWithMissingField = FakeResponseData.dataFromRessource("RatesDataMissingField")!
    static let requestResultDataOK = "Hello how are you doing?"

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

     // Loader tests

    func testTranslationLoaderSuccess() {
        let loader = TestsHelper.buildTestLoader(TranslationRequest())

        let expectation = TestsHelper.testLoaderExpectedResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: Self.requestResultDataOK
        )
        wait(for: [expectation], timeout: 1)
    }

    func testTranslationLoaderFailureWhenMissingApiKey() {
        let apiRequest = TranslationRequest(subscriptionKey: nil)
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

    func testTranslationLoaderFailureWhenInputParameterHasMissingValue() {
        let loader = TestsHelper.buildTestLoader(TranslationRequest())
        
        let expectation = TestsHelper.testLoaderExpectedResultData(
            loader,
            requestInputData: Self.requestInputDataWithMissingValue,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

   func testTranslationLoaderFailureWhenResponseDataHasMissingField() {
       let loader = TestsHelper.buildTestLoader(TranslationRequest())

       let expectation = TestsHelper.testLoaderExpectedResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.responseDataWithMissingField,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testTranslationLoaderFailureWhenDataIsBadJson() {
        let loader = TestsHelper.buildTestLoader(TranslationRequest())
        
        let expectation = TestsHelper.testLoaderExpectedResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.badJsondata,
            response: Self.fakeResponseData.responseOK,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testTranslationLoaderFailureWhenHTTPResponseStatusCodeIsNot200() {
        let loader = TestsHelper.buildTestLoader(TranslationRequest())
        
        let expectation = TestsHelper.testLoaderExpectedResultData(
            loader,
            requestInputData: Self.requestInputDataOK,
            responseData: Self.fakeResponseData.dataOK,
            response: Self.fakeResponseData.responseKO,
            expectedResultData: nil
        )
        wait(for: [expectation], timeout: 1)
    }

    func testTranslationLoaderFailureWhenErrorIsThrownDuringLoading() {
        let loader = TestsHelper.buildTestLoader(TranslationRequest())

        let expectation = TestsHelper.testLoaderExpectedFailureWhenErrorIsThrownDuringLoading(
            loader,
            requestInputData: Self.requestInputDataOK,
            thrownError: FakeResponseData.error
        )
        wait(for: [expectation], timeout: 1)
    }
}

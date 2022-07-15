//
//  TestsHelper.swift
//  LeBaluchonTests
//
//  Created by Rodolphe Desruelles on 11/07/2022.
//

@testable import LeBaluchon

import XCTest


class TestsHelper {
    
    // Creating an APILoader with fake URLSession for testing without using network access
    static func buildTestLoader<T: APIRequest>(_ apiRequest: T) -> APIRequestLoader<T> {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        return APIRequestLoader(apiRequest: apiRequest, urlSession: urlSession)
    }
    
    // Reusable loader test functions
    
    static func testLoaderExpectedResultData<T: APIRequest>(
        _ loader: APIRequestLoader<T>,
        requestInputData: T.InputDataType,
        responseData: Data,
        response: HTTPURLResponse,
        expectedResultData: T.ResultDataType?
    ) -> XCTestExpectation {
        MockURLProtocol.requestHandler = { _ in
            (response, responseData)
        }

        let expectation = XCTestExpectation(description: "response")
        loader.load(requestInputData) { result in
            XCTAssertEqual(result, expectedResultData)
            expectation.fulfill()
        }
        return expectation
    }
    
    static func testLoaderExpectedFailureWhenErrorIsThrownDuringLoading<T: APIRequest>(
        _ loader: APIRequestLoader<T>,
        requestInputData: T.InputDataType,
        thrownError: Error
    ) -> XCTestExpectation {
        MockURLProtocol.requestHandler = { _ in
            throw thrownError
        }

        let expectation = XCTestExpectation(description: "response")
        loader.load(requestInputData) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        return expectation
    }

}

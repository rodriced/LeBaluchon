//
//  TestsHelper.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022Tests
//
//  Created by Rod on 11/07/2022.
//

//import Foundation
import XCTest
@testable import P09_Desruelles_Rodolphe_L1_projet_xcode_062022


class TestsHelper {
    
    static func testLoaderResultData<T: APIRequest>(
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
        loader.load(requestInputData: requestInputData) { rates in
            XCTAssertEqual(rates, expectedResultData)
            expectation.fulfill()
        }
        return expectation
    }
    
    static func testLoaderFailureWhenErrorIsThrownDuringLoading<T: APIRequest>(
        _ loader: APIRequestLoader<T>,
        requestInputData: T.InputDataType,
        thrownError: Error
    ) -> XCTestExpectation {
        MockURLProtocol.requestHandler = { _ in
            throw thrownError
        }

        let expectation = XCTestExpectation(description: "response")
        loader.load(requestInputData: requestInputData) { rates in
            XCTAssertEqual(rates, nil)
            expectation.fulfill()
        }
        return expectation
    }

}

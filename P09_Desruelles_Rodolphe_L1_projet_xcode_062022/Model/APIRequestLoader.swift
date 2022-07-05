//
//  APIRequestLoader.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rod on 01/07/2022.
//

import Foundation

protocol APIRequest {
    associatedtype RequestDataType
    associatedtype ResultDataType

    func makeRequest(from data: RequestDataType) throws -> URLRequest
    func parseResponse(data: Data) throws -> ResultDataType
}

class APIRequestLoader<T: APIRequest> {
    let apiRequest: T
    let urlSession: URLSession

    init(apiRequest: T, urlSession: URLSession = .shared) {
        self.apiRequest = apiRequest
        self.urlSession = urlSession
    }

    func load(requestData: T.RequestDataType, completionHandler: @escaping (T.ResultDataType?) -> Void) {
        guard let urlRequest = try? apiRequest.makeRequest(from: requestData) else {
            return completionHandler(nil)
        }

        urlSession.dataTask(with: urlRequest) { data, response, error in
            guard let data = data,
                  error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200
            else {
                return completionHandler(nil)
            }

            let parsedResponse = try? self.apiRequest.parseResponse(data: data)
            completionHandler(parsedResponse)

        }.resume()
    }
}

//
//  APIRequestLoader.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rodolphe Desruelles on 01/07/2022.
//

import Foundation

protocol APIRequest {
    associatedtype InputDataType
    associatedtype ResultDataType: Equatable

    func makeRequest(from inputData: InputDataType) throws -> URLRequest
    func parseResponse(data: Data) throws -> ResultDataType
}

class APIRequestLoader<T: APIRequest> {
    let apiRequest: T
    let urlSession: URLSession

    init(apiRequest: T, urlSession: URLSession = .shared) {
        self.apiRequest = apiRequest
        self.urlSession = urlSession
    }

    func load(requestInputData: T.InputDataType, completionHandler: @escaping (T.ResultDataType?) -> Void) {
        guard let urlRequest = try? apiRequest.makeRequest(from: requestInputData) else {
            print("Error: bad request")
            return completionHandler(nil)
        }

        urlSession.dataTask(with: urlRequest) { data, response, error in
            guard error == nil
            else {
                print("Loading error = \(error.debugDescription)")
                return completionHandler(nil)
            }

            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200
            else {
                print("Status Code = \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                return completionHandler(nil)
            }

            do {
                let parsedResponse = try self.apiRequest.parseResponse(data: data)
                completionHandler(parsedResponse)
            } catch {
                print("Decoding error: \(error)")
                completionHandler(nil)
            }

        }.resume()
    }
}

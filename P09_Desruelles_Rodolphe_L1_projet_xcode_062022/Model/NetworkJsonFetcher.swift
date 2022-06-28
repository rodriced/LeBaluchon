//
//  Network.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rodolphe Desruelles on 22/06/2022.
//

import Foundation

class NetworkJsonFetcher {
    
    static let session = URLSession.shared
    
    let decoder = JSONDecoder()

    var task: URLSessionTask? = nil
    
    func fetchJson<T: Decodable>(_ urlString: String, headers: [String:String]? = nil, completionHandler: @escaping (T) -> Void) {
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        if let headers = headers {
            for (k,v) in headers {
                urlRequest.addValue(v, forHTTPHeaderField: k)
            }
        }
        
        task?.cancel()
        
        task = Self.session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("dataTask Client Error : \(error)")
                return
            }
            
            guard let response = response as? HTTPURLResponse,
//                  (200...299).contains(response.statusCode) else {
                  response.statusCode == 200 else {
                      print("dataTask Server Error : \(response?.description ?? "No response")")
                      return
                  }
            
            guard let mimeType = response.mimeType, mimeType == "application/json",
                  let data = data,
                  let  json = String(data: data, encoding: .utf8) else {
                      print("dataTask bad type : \(response.mimeType?.description ?? "No mime type" )")
                      return
                  }
            
            guard let rates = try? self.decoder.decode(T.self, from: data) else {
                print("dataTask json decoder error : \(json)")
                return
            }
            
            completionHandler(rates)
        }
        task?.resume()
    }

}

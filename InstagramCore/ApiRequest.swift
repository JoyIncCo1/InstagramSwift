//
//  ApiRequest.swift
//
//  Created by Vlad Hociotă on 28/10/2020.
//

import Foundation

public class ApiRequest {
    public private(set) var request: URLRequest

    public init(apiPath: String, parameters: Dictionary<String,Any>, method: String? = nil) {
        var components = URLComponents()
        components.queryItems = parameters.map { URLQueryItem(name: $0.0, value: "\($0.1)") }
        if let method = method, method == "POST" {
            let url = URL(string: "https://api.instagram.com" + apiPath)!
            request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = components.percentEncodedQuery?.data(using: String.Encoding.utf8)
        } else {
            components.scheme = "https"
            components.host = "api.instagram.com"
            components.path = apiPath
            request = URLRequest(url: components.url!)
        }
    }

    public func start(completion: @escaping (Any?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONSerialization.jsonObject(with: data,
                                                                    options: JSONSerialization.ReadingOptions(rawValue: 0))
                    if let data = response as? Dictionary<String,Any>,
                       let error = NSError.error(from: data) {
                        completion(nil, error)
                    } else {
                        completion(response, nil)
                    }
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
        task.resume()
    }
}

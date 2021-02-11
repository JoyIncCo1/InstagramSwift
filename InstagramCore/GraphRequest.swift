//
//  GraphRequest.swift
//
//  Created by Vlad Hociotă on 28/10/2020.
//

import Foundation

public class GraphRequest {
    private let request: URLRequest

    public init(graphPath: String, parameters: Dictionary<String,Any>) {
        var components = URLComponents(string: "https://graph.instagram.com")!
        components.path = graphPath
        components.queryItems = parameters.map { URLQueryItem(name: $0.0, value: "\($0.1)") }
        request = URLRequest(url: components.url!)
    }
    
    public func start(completion: @escaping (Any?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.global().async {
                if let data = data {
                    do {
                        let response = try JSONSerialization.jsonObject(with: data,
                                                                        options: JSONSerialization.ReadingOptions(rawValue: 0))
                        if let errorData = (response as? Dictionary<String,Any>)?["error"] as? Dictionary<String,Any> {
                            let error = NSError.error(from: errorData)
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
        }
        task.resume()
    }
}

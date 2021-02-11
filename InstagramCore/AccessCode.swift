//
//  AccessCode.swift
//
//  Created by Vlad Hociotă on 03/11/2020.
//

import Foundation

public class AccessCode {

    public static func request(clientId: String,
                                 oauthRedirectUri: String,
                                 permissions: Array<Permission>) -> URLRequest {
        let params = ["client_id" : clientId,
                      "redirect_uri" : oauthRedirectUri,
                      "response_type" : "code",
                      "scope" : permissions.map{$0.rawValue}.joined(separator: ",")]

        let request = ApiRequest(apiPath: "/oauth/authorize", parameters: params)
        return request.request
    }

    public static func get(from url: URL) -> (String?, NSError?) {
        var response = [String:Any]()

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems?.forEach { response[$0.name] = $0.value }

        let code = response["code"] as? String
        let error = NSError.error(from: response)

        return (code, error)
    }
}

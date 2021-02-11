//
//  AccessToken+Operations.swift
//
//  Created by Vlad Hociotă on 03/11/2020.
//

import Foundation

extension AccessToken {

    //MARK: - Short-lived token

    public struct ShortTokenData {
        public let tokenString: String
        public let userId: Int
        
        init?(_ data: Dictionary<String,Any>) {
            if let string = data["access_token"] as? String,
               let id = data["user_id"] as? Int {
                tokenString = string
                userId = id
            } else {
                return nil
            }
        }
    }

    public static func getFrom(code: String,
                               clientId: String,
                               secret: String,
                               oauthRedirectUri: String,
                               completion: @escaping (ShortTokenData?, Error?) -> Void)
    {
        let params = ["client_id" : clientId,
                      "client_secret" : secret,
                      "grant_type" : "authorization_code",
                      "redirect_uri" : oauthRedirectUri,
                      "code" : code]

        ApiRequest(apiPath: "/oauth/access_token",
                   parameters: params,
                   method: "POST")
            .start { (result, error) in
                if let error = error {
                    completion(nil, error)
                } else {
                    if let data = result as? Dictionary<String,Any> {
                        completion(ShortTokenData(data), nil)
                    } else {
                        completion(nil, NSError.InvalidResponseData)
                    }
                }
            }
    }

    
    //MARK: - Long-lived token

    public struct LongTokenData {
        public let tokenString: String
        public let tokenType: String
        public let expirationDate: Date
        
        init?(_ data: Dictionary<String,Any>) {
            if let string = data["access_token"] as? String,
               let type = data["token_type"] as? String,
               let expiration = data["expires_in"] as? Int {
                tokenString = string
                tokenType = type
                expirationDate = Date() + TimeInterval(expiration)
            } else {
                return nil
            }
        }
    }

    public static func exchange(token: String,
                                secret: String,
                                completion: @escaping (LongTokenData?, Error?) -> Void)
    {
        let params = ["client_secret" : secret,
                      "grant_type" : "ig_exchange_token",
                      "access_token" : token]

        GraphRequest(graphPath: "/access_token",
                     parameters: params)
            .start { (result, error) in
                if let error = error {
                    completion(nil, error)
                } else {
                    if let data = result as? Dictionary<String,Any> {
                        completion(LongTokenData(data), nil)
                    } else {
                        completion(nil, NSError.InvalidResponseData)
                    }
                }
            }
    }

    public static func refresh(token: String,
                               completion: @escaping (LongTokenData?, Error?) -> Void)
    {
        let params = ["grant_type" : "ig_refresh_token",
                      "access_token" : token]

        GraphRequest(graphPath: "/refresh_access_token", parameters: params).start { (result, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let data = result as? Dictionary<String,Any> {
                    completion(LongTokenData(data), nil)
                } else {
                    completion(nil, NSError.InvalidResponseData)
                }
            }
        }
    }
}

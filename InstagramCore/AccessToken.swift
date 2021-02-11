//
//  AccessToken.swift
//
//  Created by Vlad Hociotă on 27/10/2020.
//

import Foundation
import Security

public class AccessToken: Codable {

    public internal(set) static var current: AccessToken?

    public static var isCurrentAccessTokenActive: Bool {
        return !(current?.isExpired ?? true)
    }

    public static func refreshCurrentToken() {
        if let token = AccessToken.current {
            AccessToken.refresh(token: token.tokenString) { (tokenData, error) in
                if let tokenData = tokenData {
                    let token = AccessToken(tokenString: tokenData.tokenString,
                                            expirationDate: tokenData.expirationDate,
                                            userID: token.userID)
                    current = token
                    storeInKeychainn(token: token)
                }
            }
        }
    }

    public let expirationDate: Date
    public let tokenString: String
    public let userID: String

    public var isExpired: Bool {
        return Date() > expirationDate
    }

    public init(tokenString: String, expirationDate: Date, userID: String) {
        self.tokenString = tokenString
        self.expirationDate = expirationDate
        self.userID = userID
    }

    public static func set(token: AccessToken) {
        current = token
        storeInKeychainn(token: token)
    }

    public static func load() {
        current = loadFromKeychain()
    }

    public static func delete() {
        current = nil
        removeFromKeychain()
    }
}

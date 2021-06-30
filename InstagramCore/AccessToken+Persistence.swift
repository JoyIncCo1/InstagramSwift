//
//  AccessToken+Persistence.swift
//
//  Created by Vlad Hociotă on 03/11/2020.
//

import Foundation
import KeychainSwift

extension AccessToken {
    
    @discardableResult
    internal static func storeInKeychainn(token: AccessToken) -> Bool {
        if let data = try? JSONEncoder().encode(token) {
            return KeychainSwift().set(data, forKey: "InstagramAccessToken")
        } else {
            return false
        }
    }

    @discardableResult
    internal static func loadFromKeychain() -> AccessToken? {
        if let data = KeychainSwift().getData("InstagramAccessToken") {
            return try? JSONDecoder().decode(AccessToken.self, from: data)
        } else {
            return nil
        }
    }

    @discardableResult
    internal static func removeFromKeychain() -> Bool {
        return KeychainSwift().delete("InstagramAccessToken")
    }
}

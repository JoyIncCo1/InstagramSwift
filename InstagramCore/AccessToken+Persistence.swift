//
//  AccessToken+Persistence.swift
//
//  Created by Vlad Hociotă on 03/11/2020.
//

import Foundation

extension AccessToken {
    
    @discardableResult
    internal static func storeInKeychainn(token: AccessToken) -> Bool {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(token) {
            let attributes = [
                kSecValueData: encoded,
                kSecClass: kSecClassKey,
                kSecAttrLabel: "InstagramAccessToken"
            ] as CFDictionary
            return SecItemAdd(attributes, nil) == 0
        } else {
            return false
        }
    }

    @discardableResult
    internal static func loadFromKeychain() -> AccessToken? {
        let query = [
            kSecClass: kSecClassKey,
            kSecAttrLabel: "InstagramAccessToken",
            kSecReturnData: true
        ] as CFDictionary
        var result: AnyObject?
        if SecItemCopyMatching(query, &result) == 0 {
            if let result = result as? Data {
                let decoder = JSONDecoder()
                if let token = try? decoder.decode(AccessToken.self, from: result) {
                    return token
                }
            }
        }
        return nil
    }

    @discardableResult
    internal static func removeFromKeychain() -> Bool {
        let query = [
            kSecClass: kSecClassKey,
            kSecAttrLabel: "InstagramAccessToken"
        ] as CFDictionary
        return SecItemDelete(query) == 0
    }
}

//
//  AppClient.swift
//
//  Created by Vlad Hociotă on 27/10/2020.
//

import Foundation

public class AppClient {
    public static var current: AppClient?
    
    public static func setup(appId: String, appSecret: String, oauthRedirectUri: String) {
        current = AppClient(appId: appId, appSecret: appSecret, oauthRedirectUri: oauthRedirectUri)

        AccessToken.load()
        if !AccessToken.isCurrentAccessTokenActive {
            AccessToken.refreshCurrentToken()
        }
    }
    
    public let appId: String
    public let appSecret: String
    public let oauthRedirectUri: String
    
    private init(appId: String, appSecret: String, oauthRedirectUri: String) {
        self.appId = appId
        self.appSecret = appSecret
        self.oauthRedirectUri = oauthRedirectUri
    }
}

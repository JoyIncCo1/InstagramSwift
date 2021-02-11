//
//  LoginManager.swift
//
//  Created by Vlad Hociotă on 27/10/2020.
//

import Foundation
import UIKit
import InstagramCore

public class LoginManager {
    
    public init() {}

    //MARK: - Authentication

    public func logIn(permissions: Array<Permission>,
                      viewController: UIViewController,
                      completion: @escaping (LoginResult) -> Void) {

        guard let client = AppClient.current else {
            completion(LoginResult.failed(NSError.NoAuthorizedClient))
            return
        }

        let request = AccessCode.request(clientId: client.appId,
                                         oauthRedirectUri: client.oauthRedirectUri,
                                         permissions: permissions)

        let vc = LoginViewController(request: request,
                                     callbackURLScheme: client.oauthRedirectUri)
        { (callbackUrl, error) in
            if let callbackUrl = callbackUrl {
                let accessCodeData = AccessCode.get(from: callbackUrl)

                if let code = accessCodeData.0 {
                    getToken(for: code)
                } else {
                    DispatchQueue.main.async {
                        viewController.dismiss(animated: true)
                    }

                    if let error = accessCodeData.1 {
                        if error.localizedFailure == "access_denied" &&
                            error.localizedFailureReason == "user_denied" {
                            completion(LoginResult.cancelled)
                        } else {
                            completion(LoginResult.failed(error))
                        }
                    } else {
                        completion(LoginResult.failed(NSError.Unknown))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    viewController.dismiss(animated: true)
                }

                if let error = error {
                    if error.localizedFailureReason == "user_denied" {
                        completion(LoginResult.cancelled)
                    } else {
                        completion(LoginResult.failed(error))
                    }
                } else {
                    completion(LoginResult.failed(NSError.Unknown))
                }
            }
        }

        viewController.present(vc, animated: true, completion: nil)


        func getToken(for code: String) {
            AccessToken.getFrom(code: code,
                                clientId: client.appId,
                                secret: client.appSecret,
                                oauthRedirectUri: client.oauthRedirectUri)
            { (tokenData, error) in
                if let tokenData = tokenData {
                    let userId = String(tokenData.userId)
                    AccessToken.exchange(token: tokenData.tokenString,
                                         secret: client.appSecret)
                    { (tokenData, error) in
                        DispatchQueue.main.async {
                            viewController.dismiss(animated: true)
                        }

                        if let tokenData = tokenData {
                            let token = AccessToken(tokenString: tokenData.tokenString,
                                                    expirationDate: tokenData.expirationDate,
                                                    userID: userId)
                            AccessToken.set(token: token)
                            let result = LoginResult.success(granted: Set(permissions),
                                                             declined: [],
                                                             token: AccessToken.current!)
                            completion(result)
                        } else {
                            completion(LoginResult.failed(error!))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        viewController.dismiss(animated: true)
                    }

                    completion(LoginResult.failed(error!))
                }
            }
        }
    }

    public func logOut() {
        AccessToken.delete()
    }
}

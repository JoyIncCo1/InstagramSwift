//
//  LoginResult.swift
//
//  Created by Vlad Hociotă on 27/10/2020.
//

import Foundation
import InstagramCore

public enum LoginResult {
    case success(granted: Set<Permission>, declined: Set<Permission>, token: AccessToken)
    case cancelled
    case failed(Error)
}

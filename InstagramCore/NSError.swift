//
//  NSError.swift
//
//  Created by Vlad Hociotă on 28/10/2020.
//

import Foundation

extension NSError {
    public static let NoAuthorizedClient = NSError(domain: "InstagramGraphAPI",
                                                   code: 100,
                                                   userInfo: [NSLocalizedDescriptionKey : "No authorized client available"])

    public static let InvalidResponseData = NSError(domain: "InstagramGraphAPI",
                                                    code: 101,
                                                    userInfo: [NSLocalizedDescriptionKey : "Invalid response data"])

    public static let Unknown = NSError(domain: "InstagramGraphAPI",
                                        code: 102,
                                        userInfo: [NSLocalizedDescriptionKey : "Unknown error"])

    public var localizedFailure: String? {
        return userInfo[NSLocalizedFailureErrorKey] as? String
    }

    public static func error(from data: Dictionary<String,Any>) -> NSError? {
        let code = data["code"] as? Int

        var dict = [String:String]()

        if let errorType = data["error_type"] as? String ??
                           data["type"] as? String ??
                           data["error"] as? String {
            dict[NSLocalizedFailureErrorKey] = errorType
        }
        if let reason = data["error_reason"] as? String {
            dict[NSLocalizedFailureReasonErrorKey] = reason
        }
        if let message = data["error_message"] as? String ??
                         data["message"] as? String ??
                         data["error_description"] as? String {
            dict[NSLocalizedDescriptionKey] = message
        }

        if dict.isEmpty {
            return nil
        } else {
            return NSError(domain: "InstagramGraphAPI", code: code ?? 100, userInfo: dict)
        }
    }
}

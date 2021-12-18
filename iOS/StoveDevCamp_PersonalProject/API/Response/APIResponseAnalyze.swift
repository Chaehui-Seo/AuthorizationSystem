//
//  APIResponseAnalyze.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/17.
//

import Foundation
import SwiftKeychainWrapper
import UIKit

enum ResponseCase {
    case success
    case InvalidToken
    case fail
}


class APIResponseAnalyze {
    static func analyze_withToken(result: [String: Any], vc: UIViewController) -> ResponseCase {
        if let success = result["success"] as? Int, success == 1 {
            return .success
        } else if let message = result["message"] as? String, message == "Invalid token" {
            return .InvalidToken
        } else {
            return .fail
        }
    }
    
    static func analyze(result: [String: Any], vc: UIViewController) -> ResponseCase {
        if let success = result["success"] as? Int, success == 1 {
            return .success
        } else {
            return .fail
        }
    }
}

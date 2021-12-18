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

extension UIViewController {
    func invalidToken() {
        MemoViewModel.shared.selectedMemo = nil
        AdminViewModel.shared.adminUser = nil
        UserInfoViewModel.shared.user = nil
        MemoViewModel.shared.user = nil
        MemoViewModel.shared.memos = nil
        KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.accessToken.rawValue)
        KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.id.rawValue)
        KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.refreshToken.rawValue)
        let alert = UIAlertController(title: "", message: "토큰이 만료되었습니다. 다시 로그인해주세요.", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "확인", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(action1)
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorOccur() {
        let alert = UIAlertController(title: "", message: "오류가 발생했습니다", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(action1)
        self.present(alert, animated: true, completion: nil)
    }
}

//
//  UIViewController+showAlerts.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/18.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

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

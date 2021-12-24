//
//  SettingViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

class SettingViewController: UIViewController{
    // MARK: Properties
    @IBOutlet weak var logOutView: UIView!
    @IBOutlet weak var changeNickNameView: UIView!
    @IBOutlet weak var changePwView: UIView!
    @IBOutlet weak var changeNickNameButton: UIButton!
    @IBOutlet weak var changePwButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var withdrawalButton: UIButton!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.style()
    }
    
    // MARK: UI Setting
    func style() {
        logOutView.layer.cornerRadius = 25
        logOutView.layer.borderColor = UIColor.customDarkGray.cgColor
        logOutView.layer.borderWidth = 1
        
        changeNickNameView.layer.cornerRadius = 25
        changeNickNameView.layer.borderColor = UIColor.customDarkGray.cgColor
        changeNickNameView.layer.borderWidth = 1
        
        changePwView.layer.cornerRadius = 25
        changePwView.layer.borderColor = UIColor.customDarkGray.cgColor
        changePwView.layer.borderWidth = 1
    }
    
    // MARK: Button Action
    // 로그아웃
    @IBAction func logOutButtonDidTap(_ sender: Any) {
        self.changeNickNameButton.isEnabled = false
        self.changePwButton.isEnabled = false
        self.logoutButton.isEnabled = false
        self.withdrawalButton.isEnabled = false
        UserManager.shared.user = nil
        AdminViewModel.shared.adminUser = nil
        MemoViewModel.shared.user = nil
        MemoViewModel.shared.memos = nil
        KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.accessToken.rawValue)
        KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.id.rawValue)
        KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.refreshToken.rawValue)
        self.dismiss(animated: true, completion: {
            self.changeNickNameButton.isEnabled = true
            self.changePwButton.isEnabled = true
            self.logoutButton.isEnabled = true
            self.withdrawalButton.isEnabled = true
        })
    }
    
    // 닉네임 변경
    @IBAction func changeNickNameButtonClicked(_ sender: Any) {
        guard let nicknamePage = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "NicknameChangeViewController") as? NicknameChangeViewController else { return }
        self.changeNickNameButton.isEnabled = false
        self.changePwButton.isEnabled = false
        self.logoutButton.isEnabled = false
        self.withdrawalButton.isEnabled = false
        self.navigationController?.pushViewController(nicknamePage, animated: true)
        self.changeNickNameButton.isEnabled = true
        self.changePwButton.isEnabled = true
        self.logoutButton.isEnabled = true
        self.withdrawalButton.isEnabled = true
    }
    
    // 비밀번호 변경
    @IBAction func changePwButtonDidTap(_ sender: Any) {
        guard let changePwPage = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "CurrentPwCheckViewController") as? CurrentPwCheckViewController else { return }
        self.changeNickNameButton.isEnabled = false
        self.changePwButton.isEnabled = false
        self.logoutButton.isEnabled = false
        self.withdrawalButton.isEnabled = false
        self.navigationController?.pushViewController(changePwPage, animated: true)
        self.changeNickNameButton.isEnabled = true
        self.changePwButton.isEnabled = true
        self.logoutButton.isEnabled = true
        self.withdrawalButton.isEnabled = true
    }
    
    // 뒤로 가기
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 탈퇴하기
    @IBAction func withdrawalButtonDidTap(_ sender: Any) {
        guard let userInfo = UserManager.shared.user else { return }
        let alert = UIAlertController(title: "회원탈퇴", message: "탈퇴하시면 본 서비스에서 작성하신 모든 정보가 삭제됩니다. 탈퇴하시겠습니까?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let action2 = UIAlertAction(title: "탈퇴", style: .destructive) {_ in
            let alert = UIAlertController(title: "회원탈퇴", message: "비밀번호를 입력해주세요", preferredStyle: .alert)
            alert.addTextField()
            alert.textFields?[0].isSecureTextEntry = true
            let action1 = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let action2 = UIAlertAction(title: "탈퇴", style: .destructive) {_ in
                guard let pwInfo = alert.textFields?[0].text, pwInfo.isEmpty == false else { return }
                UsersAPIService.shared.withdrawal(jwt: KeychainWrapper.standard[.accessToken], userId: userInfo.userId, password: pwInfo, isAdmin: userInfo.isAdmin) { result in
                    if let success = result["success"] as? Int, success == 1 {
                        // 탈퇴 완료
                        DispatchQueue.main.async {
                            UserManager.shared.user = nil
                            AdminViewModel.shared.adminUser = nil
                            MemoViewModel.shared.user = nil
                            MemoViewModel.shared.memos = nil
                            KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.accessToken.rawValue)
                            KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.id.rawValue)
                            KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.refreshToken.rawValue)
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        if let message = result["message"] as? String, message == "incorrect password" {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "회원탈퇴", message: "비밀번호가 일치하지 않습니다", preferredStyle: .alert)
                                let action1 = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                                alert.addAction(action1)
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else if let message = result["message"] as? String, message == "Invalid token" {
                            UsersAPIService.shared.checkRefreshToken() { result2 in
                                DispatchQueue.main.async {
                                    switch APIResponseAnalyze.analyze_withToken(result: result2, vc: self) {
                                    case .success :
                                        UsersAPIService.shared.withdrawal(jwt: KeychainWrapper.standard[.accessToken], userId: userInfo.userId, password: pwInfo, isAdmin: userInfo.isAdmin) { result3 in
                                            if let success = result3["success"] as? Int, success == 1 {
                                                UserManager.shared.user = nil
                                                AdminViewModel.shared.adminUser = nil
                                                MemoViewModel.shared.user = nil
                                                MemoViewModel.shared.memos = nil
                                                KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.accessToken.rawValue)
                                                KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.id.rawValue)
                                                KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.refreshToken.rawValue)
                                                DispatchQueue.main.async {
                                                    self.dismiss(animated: true, completion: nil)
                                                }
                                            } else{
                                                DispatchQueue.main.async {
                                                    let alert = UIAlertController(title: "회원탈퇴", message: "오류가 발생해서 탈퇴가 실패했습니다", preferredStyle: .alert)
                                                    let action1 = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                                                    alert.addAction(action1)
                                                    self.present(alert, animated: true, completion: nil)
                                                }
                                            }
                                        }
                                    case .InvalidToken:
                                        let alert = UIAlertController(title: "회원탈퇴", message: "오류가 발생해서 탈퇴가 실패했습니다", preferredStyle: .alert)
                                        let action1 = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                                        alert.addAction(action1)
                                        self.present(alert, animated: true, completion: nil)
                                    case .fail:
                                        let alert = UIAlertController(title: "회원탈퇴", message: "오류가 발생해서 탈퇴가 실패했습니다", preferredStyle: .alert)
                                        let action1 = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                                        alert.addAction(action1)
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "회원탈퇴", message: "오류가 발생해서 탈퇴가 실패했습니다", preferredStyle: .alert)
                                let action1 = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                                alert.addAction(action1)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
            alert.addAction(action1)
            alert.addAction(action2)
            self.present(alert, animated: true, completion: nil)
        }
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
    
}

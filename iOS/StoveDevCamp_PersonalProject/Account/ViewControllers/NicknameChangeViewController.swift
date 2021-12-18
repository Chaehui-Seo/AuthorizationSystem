//
//  NicknameChangeViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/16.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

class NicknameChangeViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var nickNameValidCheckLabel: UILabel!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.style()
    }
    
    // MARK: UI Setting
    func style() {
        nextButton.layer.cornerRadius = 25
    }
    
    // MARK: Nickname Input
    @IBAction func nickNameTextFieldEditingChanged(_ sender: Any) {
        guard let nickNameInfo = nickNameTextField.text, nickNameInfo.isEmpty == false else {
            nickNameValidCheckLabel.isHidden = false
            nickNameValidCheckLabel.text = "최대 6글자까지 입력하실 수 있습니다"
            nickNameValidCheckLabel.textColor = UIColor.customViolet
            nextButton.isEnabled = false
            return
        }
        if nickNameInfo.count > 6 {
            nickNameTextField.deleteBackward()
            nickNameValidCheckLabel.isHidden = false
            nickNameValidCheckLabel.text = "최대 6글자까지 입력하실 수 있습니다"
            nickNameValidCheckLabel.textColor = UIColor.systemRed
        } else {
            nickNameValidCheckLabel.isHidden = true
            nextButton.isEnabled = true
        }
    }
    
    // MARK: Button Action
    // 다음
    @IBAction func nextButtonDidTap(_ sender: Any) {
        guard let nickNameInfo = nickNameTextField.text, nickNameInfo.isEmpty == false, let userInfo = UserInfoViewModel.shared.user else { return }
        UsersAPIService.shared.changeNickName(jwt: KeychainWrapper.standard[.accessToken], userId: userInfo.userId, nickName: nickNameInfo, isAdmin: AdminViewModel.shared.adminUser == nil ? userInfo.isAdmin : 1) { result in
            DispatchQueue.main.async {
                switch APIResponseAnalyze.analyze_withToken(result: result, vc: self) {
                case .success :
                    if let user = result["user"] as? UserInfo {
                        UserInfoViewModel.shared.user = user
                        if let adminUser = AdminViewModel.shared.adminUser, adminUser.userId == user.userId {
                            AdminViewModel.shared.adminUser = user
                        }
                        if let memoUser = MemoViewModel.shared.user, memoUser.userId == user.userId {
                            MemoViewModel.shared.user = user
                        } else {
                            UsersAPIService.shared.loadUsers { result2 in
                                DispatchQueue.main.async {
                                    if APIResponseAnalyze.analyze(result: result2, vc: self) == .success {
                                        if let list = result2["user"] as? [UserInfo] {
                                            AdminViewModel.shared.users = list
                                        }
                                    }
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "", message: "닉네임이 변경되었습니다", preferredStyle: .alert)
                            let action = UIAlertAction(title: "확인", style: .default) { _ in
                                self.navigationController?.popViewController(animated: true)
                            }
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                case .InvalidToken :
                    UsersAPIService.shared.checkRefreshToken() { result2 in
                        DispatchQueue.main.async {
                            switch APIResponseAnalyze.analyze_withToken(result: result2, vc: self) {
                            case .success :
                                UsersAPIService.shared.changeNickName(jwt: KeychainWrapper.standard[.accessToken], userId: userInfo.userId, nickName: nickNameInfo, isAdmin: AdminViewModel.shared.adminUser == nil ? userInfo.isAdmin : 1) { result3 in
                                    DispatchQueue.main.async {
                                        switch APIResponseAnalyze.analyze_withToken(result: result3, vc: self) {
                                        case .success :
                                            if let user = result3["user"] as? UserInfo {
                                                UserInfoViewModel.shared.user = user
                                                if let memoUser = MemoViewModel.shared.user, memoUser.userId == user.userId {
                                                    MemoViewModel.shared.user = user
                                                } else {
                                                    UsersAPIService.shared.loadUsers { result4 in
                                                        DispatchQueue.main.async {
                                                            if APIResponseAnalyze.analyze(result: result4, vc: self) == .success {
                                                                if let list = result4["user"] as? [UserInfo] {
                                                                    AdminViewModel.shared.users = list
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                DispatchQueue.main.async {
                                                    let alert = UIAlertController(title: "", message: "닉네임이 변경되었습니다", preferredStyle: .alert)
                                                    let action = UIAlertAction(title: "확인", style: .default) { _ in
                                                        self.navigationController?.popViewController(animated: true)
                                                    }
                                                    alert.addAction(action)
                                                    self.present(alert, animated: true, completion: nil)
                                                }
                                            }
                                        case .InvalidToken :
                                            self.invalidToken()
                                        case .fail:
                                            self.errorOccur()
                                        }
                                    }
                                }
                            case .InvalidToken :
                                self.invalidToken()
                            case .fail:
                                if let message = result["message"] as? String, message == "Unavailable nickName" {
                                    DispatchQueue.main.async {
                                        let alert = UIAlertController(title: "", message: "이미 사용 중인 닉네임입니다", preferredStyle: .alert)
                                        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                                        alert.addAction(action)
                                        self.present(alert, animated: true, completion: nil)
                                        self.nickNameValidCheckLabel.isHidden = false
                                        self.nickNameValidCheckLabel.text = "새 닉네임을 입력해주세요"
                                        self.nickNameValidCheckLabel.textColor = UIColor.systemRed
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        let alert = UIAlertController(title: "", message: "오류가 발생했습니다", preferredStyle: .alert)
                                        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                                        alert.addAction(action)
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                case .fail :
                    if let message = result["message"] as? String, message == "Unavailable nickName" {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "", message: "이미 사용 중인 닉네임입니다", preferredStyle: .alert)
                            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                            self.nickNameValidCheckLabel.isHidden = false
                            self.nickNameValidCheckLabel.text = "새 닉네임을 입력해주세요"
                            self.nickNameValidCheckLabel.textColor = UIColor.systemRed
                        }
                    } else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "", message: "오류가 발생했습니다", preferredStyle: .alert)
                            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    // 뒤로 가기
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//
//  PwChangeViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/16.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

class PwChangeViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var pwCheckTextField: UITextField!
    @IBOutlet weak var pwValidLabel: UILabel!
    @IBOutlet weak var pwCheckValidLabel: UILabel!
    @IBOutlet weak var changeButton: UIButton!
    
    // 이메일 인증인 경우 전달
    var idInfo: String?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.style()
    }
    
    // MARK: UI Setting
    func style() {
        changeButton.layer.cornerRadius = 25
    }
    
    // MARK: Password Input
    func isValidated(_ password: String) -> Bool {
        var lowerCaseLetter: Bool = false
        var digit: Bool = false
        if password.count  >= 6 {
            for char in password.unicodeScalars {
                if !lowerCaseLetter {
                    lowerCaseLetter = CharacterSet.lowercaseLetters.contains(char)
                }
                if !digit {
                    digit = CharacterSet.decimalDigits.contains(char)
                }
            }
            if (digit && lowerCaseLetter) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    @IBAction func pwTextFieldEditingChanged(_ sender: Any) {
        guard let pwInfo = pwTextField.text, pwInfo.isEmpty == false else {
            pwCheckTextField.isEnabled = false
            return
        }
        if isValidated(pwInfo) {
            pwValidLabel.text = "올바른 형식의 비밀번호입니다"
            pwValidLabel.textColor = UIColor.customViolet
            pwCheckTextField.isEnabled = true
            pwCheckValidLabel.isHidden = false
            pwCheckValidLabel.text = "비밀번호를 확인해주세요"
            pwCheckValidLabel.textColor = UIColor.customViolet
        } else {
            pwValidLabel.text = "영문 소문자와 숫자가 포함 6자 이상"
            pwValidLabel.textColor = UIColor.systemRed
            pwCheckValidLabel.isHidden = true
            pwCheckTextField.isEnabled = false
        }
        if let pwCheckInfo = pwCheckTextField.text, pwCheckInfo.isEmpty == false {
            pwCheckValidLabel.isHidden = true
            pwCheckTextField.text = ""
            changeButton.isEnabled = false
        } else {
            pwCheckValidLabel.isHidden = true
            changeButton.isEnabled = false
        }
    }
    
    // MARK: Password check Input
    @IBAction func pwCheckTextFieldEditingChanged(_ sender: Any) {
        guard let pwInfo = pwTextField.text, pwInfo.isEmpty == false, let pwCheckInfo = pwCheckTextField.text, pwCheckInfo.isEmpty == false else {
            pwCheckValidLabel.text = "비밀번호를 다시 입력해주세요"
            pwCheckValidLabel.textColor = UIColor.systemRed
            changeButton.isEnabled = false
            return
        }
        if pwInfo == pwCheckInfo {
            pwCheckValidLabel.isHidden = false
            pwCheckValidLabel.text = "비밀번호가 일치합니다"
            pwCheckValidLabel.textColor = UIColor.customViolet
            changeButton.isEnabled = true
        } else {
            pwCheckValidLabel.isHidden = false
            pwCheckValidLabel.text = "비밀번호가 일치하지 않습니다"
            pwCheckValidLabel.textColor = UIColor.systemRed
            changeButton.isEnabled = false
        }
    }
    
    // MARK: Button Action
    // 뒤로 가기
    @IBAction func backButtonDidTap(_ sender: Any) {
        if (self.navigationController as? PwChangeNavigationController) != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 변경
    @IBAction func changeButtonDidTap(_ sender: Any) {
        guard let pwInfo = pwTextField.text, pwInfo.isEmpty == false, let pwCheckInfo = pwCheckTextField.text, pwCheckInfo.isEmpty == false, pwInfo == pwCheckInfo else {return }
        guard let userInfo = UserManager.shared.user else {
            // 로그인 페이지 혹은 어드민페이지 이메일 인증으로 비번 변경
            guard let id = idInfo else { return }
            UsersAPIService.shared.changePassword(jwt: KeychainWrapper.standard[.accessToken], userId: id, newPw: pwInfo, isAdmin: 1) { result in
                DispatchQueue.main.async {
                    switch APIResponseAnalyze.analyze_withToken(result: result, vc: self) {
                    case .success :
                        let alert = UIAlertController(title: "", message: "비밀번호를 변경했습니다", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default) {_ in
                            self.pwTextField.text = ""
                            self.pwCheckTextField.text = ""
                            if (self.navigationController as? PwChangeNavigationController) != nil {
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    case .InvalidToken :
                        UsersAPIService.shared.checkRefreshToken() { result2 in
                            DispatchQueue.main.async {
                                switch APIResponseAnalyze.analyze_withToken(result: result2, vc: self) {
                                case .success :
                                    UsersAPIService.shared.changePassword(jwt: KeychainWrapper.standard[.accessToken], userId: id, newPw: pwInfo, isAdmin: 1) { result3 in
                                        DispatchQueue.main.async {
                                            switch APIResponseAnalyze.analyze_withToken(result: result3, vc: self) {
                                            case .success :
                                                let alert = UIAlertController(title: "", message: "비밀번호를 변경했습니다", preferredStyle: .alert)
                                                let action = UIAlertAction(title: "확인", style: .default) {_ in
                                                    self.pwTextField.text = ""
                                                    self.pwCheckTextField.text = ""
                                                    if (self.navigationController as? PwChangeNavigationController) != nil {
                                                        self.dismiss(animated: true, completion: nil)
                                                    } else {
                                                        self.navigationController?.popViewController(animated: true)
                                                    }
                                                }
                                                alert.addAction(action)
                                                self.present(alert, animated: true, completion: nil)
                                            case .InvalidToken :
                                                self.invalidToken()
                                            case .fail:
                                                self.pwTextField.text = ""
                                                self.pwCheckTextField.text = ""
                                                let alert = UIAlertController(title: "", message: "비밀번호 변경에 실패했습니다", preferredStyle: .alert)
                                                let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                                                alert.addAction(action)
                                                self.present(alert, animated: true, completion: nil)
                                            }
                                        }
                                    }
                                case .InvalidToken :
                                    self.invalidToken()
                                case .fail:
                                    self.pwTextField.text = ""
                                    self.pwCheckTextField.text = ""
                                    let alert = UIAlertController(title: "", message: "비밀번호 변경에 실패했습니다", preferredStyle: .alert)
                                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                                    alert.addAction(action)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    case .fail :
                        self.pwTextField.text = ""
                        self.pwCheckTextField.text = ""
                        let alert = UIAlertController(title: "", message: "비밀번호 변경에 실패했습니다", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            return
        }
        // 설정에서 비번 변경
        UsersAPIService.shared.changePassword(jwt: KeychainWrapper.standard[.accessToken], userId: userInfo.userId, newPw: pwInfo, isAdmin: userInfo.isAdmin) { result in
            DispatchQueue.main.async {
                switch APIResponseAnalyze.analyze_withToken(result: result, vc: self) {
                case .success :
                    if let user = result["user"] as? UserInfo {
                        UserManager.shared.user = user
                        let alert = UIAlertController(title: "", message: "비밀번호를 변경했습니다", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default) {_ in
                            self.pwTextField.text = ""
                            self.pwCheckTextField.text = ""
                            self.navigationController?.popViewController(animated: true)
                        }
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                case .InvalidToken :
                    UsersAPIService.shared.checkRefreshToken() { result2 in
                        DispatchQueue.main.async {
                            switch APIResponseAnalyze.analyze_withToken(result: result2, vc: self) {
                            case .success :
                                UsersAPIService.shared.changePassword(jwt: KeychainWrapper.standard[.accessToken], userId: userInfo.userId, newPw: pwInfo, isAdmin: userInfo.isAdmin)
                                { result3 in
                                    DispatchQueue.main.async {
                                        switch APIResponseAnalyze.analyze_withToken(result: result3, vc: self) {
                                        case .success :
                                            if let user = result3["user"] as? UserInfo {
                                                UserManager.shared.user = user
                                                DispatchQueue.main.async {
                                                    let alert = UIAlertController(title: "", message: "비밀번호를 변경했습니다", preferredStyle: .alert)
                                                    let action = UIAlertAction(title: "확인", style: .default) {_ in
                                                        self.pwTextField.text = ""
                                                        self.pwCheckTextField.text = ""
                                                        self.navigationController?.popViewController(animated: true)
                                                    }
                                                    alert.addAction(action)
                                                    self.present(alert, animated: true, completion: nil)
                                                }
                                            }
                                        case .InvalidToken :
                                            self.invalidToken()
                                        case .fail:
                                            DispatchQueue.main.async {
                                                self.pwTextField.text = ""
                                                self.pwCheckTextField.text = ""
                                                let alert = UIAlertController(title: "", message: "비밀번호 변경에 실패했습니다", preferredStyle: .alert)
                                                let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                                                alert.addAction(action)
                                                self.present(alert, animated: true, completion: nil)
                                            }
                                        }
                                    }
                                }
                            case .InvalidToken :
                                self.invalidToken()
                            case .fail:
                                DispatchQueue.main.async {
                                    self.pwTextField.text = ""
                                    self.pwCheckTextField.text = ""
                                    let alert = UIAlertController(title: "", message: "비밀번호 변경에 실패했습니다", preferredStyle: .alert)
                                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                                    alert.addAction(action)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                case .fail :
                    DispatchQueue.main.async {
                        self.pwTextField.text = ""
                        self.pwCheckTextField.text = ""
                        let alert = UIAlertController(title: "", message: "비밀번호 변경에 실패했습니다", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

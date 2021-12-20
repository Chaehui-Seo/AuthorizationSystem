//
//  PwInputViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

class PwInputViewController: UIViewController{
    
    // MARK: Properties
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var pwCheckTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var pwValidLabel: UILabel!
    @IBOutlet weak var pwCheckValidLabel: UILabel!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.style()
    }
    
    // MARK: UI Setting
    func style() {
        registerButton.layer.cornerRadius = 25
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
            registerButton.isEnabled = false
        } else {
            pwCheckValidLabel.isHidden = true
            registerButton.isEnabled = false
        }
    }
    
    // MARK: Password check Input
    @IBAction func pwCheckTextFieldEditingChanged(_ sender: Any) {
        guard let pwInfo = pwTextField.text, pwInfo.isEmpty == false, let pwCheckInfo = pwCheckTextField.text, pwCheckInfo.isEmpty == false else {
            pwCheckValidLabel.text = "비밀번호를 다시 입력해주세요"
            pwCheckValidLabel.textColor = UIColor.systemRed
            registerButton.isEnabled = false
            return
        }
        if pwInfo == pwCheckInfo {
            pwCheckValidLabel.isHidden = false
            pwCheckValidLabel.text = "비밀번호가 일치합니다"
            pwCheckValidLabel.textColor = UIColor.customViolet
            registerButton.isEnabled = true
        } else {
            pwCheckValidLabel.isHidden = false
            pwCheckValidLabel.text = "비밀번호가 일치하지 않습니다"
            pwCheckValidLabel.textColor = UIColor.systemRed
            registerButton.isEnabled = false
        }
    }
    
    
    // MARK: Button Action
    // 가입하기
    @IBAction func registerButtonDidTap(_ sender: Any) {
        guard let userInfo = RegisterViewModel.shared.userId, let nickNameInfo = RegisterViewModel.shared.nickName, let pwInfo = pwTextField.text, pwInfo.isEmpty == false, let pwCheckInfo = pwCheckTextField.text, pwCheckInfo.isEmpty == false, pwInfo == pwCheckInfo else { return }
        self.registerButton.isEnabled = false
        UsersAPIService.shared.register(userId: userInfo, nickName: nickNameInfo, password: pwInfo) { result in
            DispatchQueue.main.async {
                if APIResponseAnalyze.analyze(result: result, vc: self) == .success {
                    // 회원가입 성공
                    guard let userInfo = result["user"] as? UserInfo, let memoPage = UIStoryboard(name: "PersonalMemo", bundle: nil).instantiateViewController(withIdentifier: "PersonalMemoViewController") as? PersonalMemoViewController, var viewControllers = self.navigationController?.viewControllers, let welcome = UIStoryboard(name: "PersonalMemo", bundle: nil).instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController else { return }
                    memoPage.addChild(welcome)
                    welcome.view.frame = memoPage.view.frame
                    memoPage.view.addSubview(welcome.view)
                    welcome.didMove(toParent: memoPage)
                    
                    UserDefaults.standard.set(false, forKey: "onRegister")
                    UserDefaults.standard.removeObject(forKey: "onRegister-Email")
                    UserInfoViewModel.shared.user = userInfo
                    MemoViewModel.shared.user = userInfo
                    KeychainWrapper.standard.set(userInfo.userId, forKey: KeychainWrapper.Key.id.rawValue)
                    KeychainWrapper.standard.set(userInfo.refreshToken ?? "", forKey: KeychainWrapper.Key.refreshToken.rawValue)
                    
                    viewControllers[viewControllers.count - 1] = memoPage
                    self.navigationController?.setViewControllers(viewControllers, animated: true)
                    self.registerButton.isEnabled = true
                } else {
                    // 회원가입 실패
                    let alert = UIAlertController(title: "", message: "회원가입에 실패했습니다", preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: {
                        self.registerButton.isEnabled = true
                    })
                    
                }
            }
        }
    }
    
    // 뒤로 가기
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

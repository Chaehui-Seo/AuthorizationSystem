//
//  ViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/14.
//

import UIKit

class LogInViewController: UIViewController {
    
//    @IBOutlet weak var underLineView: UIView!
    @IBOutlet weak var welcomeOutlinedLabel: OutlinedLabel!
    
//    @IBOutlet weak var welcomeTitleLabel: UIOutlinedLabel!
    @IBOutlet weak var forgotPwButton: UIButton!
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var registerButtonBottomMargin: NSLayoutConstraint!
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.style()
    }
    
    func style() {
        welcomeOutlinedLabel.outlineColor = UIColor.customDarkGray
        welcomeOutlinedLabel.outlineWidth = 2
        logInButton.layer.cornerRadius = 25
    }
    
    @objc private func adjustInputView(noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        if noti.name == UIResponder.keyboardWillShowNotification {
            let adjustmentHeight = keyboardFrame.height - view.safeAreaInsets.bottom
            imageView.alpha = 0
            registerButtonBottomMargin.constant = adjustmentHeight - 50
        } else {
            imageView.alpha = 1
            registerButtonBottomMargin.constant = 40
        }
    }
    
    @IBAction func loginButtonDidTap(_ sender: Any) {
        guard let idInfo = idTextField.text, idInfo.isEmpty == false, let pwInfo = pwTextField.text, pwInfo.isEmpty == false else { return }
        UsersAPIService.shared.login(userId: idInfo, pw: pwInfo) { result in
            if let success = result["success"] as? Int, success == 1 {
                // 로그인 성공
                DispatchQueue.main.async {
                    guard let userInfo = result["user"] as? UserInfo, let personalPage = UIStoryboard(name: "PersonalMemo", bundle: nil).instantiateViewController(withIdentifier: "MemoNavigationController") as? MemoNavigationController, let adminPage = UIStoryboard(name: "Admin", bundle: nil).instantiateViewController(withIdentifier: "AdminNavigationController") as? AdminNavigationController  else { return }
                    if userInfo.isAdmin == 1 {
                        UserInfoViewModel.shared.user = userInfo
                        AdminViewModel.shared.adminUser = userInfo
                        adminPage.modalPresentationStyle = .fullScreen
                        adminPage.modalTransitionStyle = .crossDissolve
                        self.present(adminPage, animated: true, completion: {
                            self.idTextField.text = ""
                            self.pwTextField.text = ""
                        })
                    } else {
                        AdminViewModel.shared.adminUser = nil
                        UserInfoViewModel.shared.user = userInfo
                        MemoViewModel.shared.user = userInfo
                        personalPage.modalPresentationStyle = .fullScreen
                        personalPage.modalTransitionStyle = .crossDissolve
                        self.present(personalPage, animated: true, completion: {
                            self.idTextField.text = ""
                            self.pwTextField.text = ""
                        })
                    }
                }
            } else {
//                print("실패")
                DispatchQueue.main.async {                
                    let alert = UIAlertController(title: "", message: "로그인 정보를 확인해주세요", preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func registerButtonDidTap(_ sender: Any) {
        guard let registerPage = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterNavigationController") as? RegisterNavigationController else { return }
        registerPage.modalPresentationStyle = .fullScreen
        self.present(registerPage, animated: true, completion: nil)
    }
    
    @IBAction func forgetPwButton(_ sender: Any) {
        guard let forgotPwPage = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "PwChangeNavigationController") as? PwChangeNavigationController else { return }
        forgotPwPage.modalPresentationStyle = .fullScreen
        self.present(forgotPwPage, animated: true, completion: nil)
    }
    
    
    @IBAction func backgroundDidTap(_ sender: Any) {
        idTextField.resignFirstResponder()
        pwTextField.resignFirstResponder()
    }
}

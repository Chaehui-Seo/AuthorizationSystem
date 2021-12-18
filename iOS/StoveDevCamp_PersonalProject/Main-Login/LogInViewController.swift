//
//  ViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/14.
//

import UIKit
import SwiftKeychainWrapper
import Lottie

class LogInViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var welcomeOutlinedLabel: OutlinedLabel!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var forgotPwButton: UIButton!
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerButtonBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var autoLoginCheckImage: UIImageView!
    @IBOutlet weak var autoLoginLabel: UILabel!
    @IBOutlet weak var autoLoginButton: UIButton!
    let animationView: AnimationView = .init(name: "blop_violet")
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.style()
        loadingView.isHidden = false
        loadingView.addSubview(animationView)
        animationView.frame = CGRect(x: self.view.bounds.midX - 50, y: self.view.bounds.midY - 100, width: 100, height: 100)
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 4
        
        let autoLogin: Bool = UserDefaults.standard.bool(forKey: "autoLogin")
        
        if autoLogin {
            autoLoginLabel.textColor = UIColor.customViolet
            autoLoginCheckImage.image = UIImage(systemName: "checkmark.square.fill")
            autoLoginCheckImage.tintColor = UIColor.customViolet
        } else {
            autoLoginLabel.textColor = UIColor.lightGray
            autoLoginCheckImage.image = UIImage(systemName: "square")
            autoLoginCheckImage.tintColor = UIColor.lightGray
        }
        
        if let id: String = KeychainWrapper.standard[.id], let refreshToken: String = KeychainWrapper.standard[.refreshToken], autoLogin == true {
            animationView.play()
            animationView.loopMode = .loop
            let autoLoginTryingLabel = UILabel()
            loadingView.addSubview(autoLoginTryingLabel)
            autoLoginTryingLabel.text = "자동 로그인 중입니다"
            autoLoginTryingLabel.textColor = UIColor.customViolet
            autoLoginTryingLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                autoLoginTryingLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 20),
                autoLoginTryingLabel.centerXAnchor.constraint(equalTo: animationView.centerXAnchor)
            ])
            automaticLogin(id: id, refreshToken: refreshToken)
        } else {
            animationView.play { _ in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                    self.loadingView.alpha = 0
                    self.animationView.alpha = 0
                } completion: { _ in
                    if UserDefaults.standard.bool(forKey: "onRegister") == true, (UserDefaults.standard.string(forKey: "onRegister-Email") != nil) {
                        self.onRegister()
                    }
                }
            }
        }
    }
    
    // MARK: UI Setting
    func style() {
        welcomeOutlinedLabel.outlineColor = UIColor.customDarkGray
        welcomeOutlinedLabel.outlineWidth = 2
        logInButton.layer.cornerRadius = 25
    }
    
    // MARK: Keyboard up/down action
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
    
    // MARK: Button action
    
    // 로그인 시도
    @IBAction func loginButtonDidTap(_ sender: Any) {
        idTextField.resignFirstResponder()
        pwTextField.resignFirstResponder()
        guard let idInfo = idTextField.text, idInfo.isEmpty == false, let pwInfo = pwTextField.text, pwInfo.isEmpty == false else { return }
        UsersAPIService.shared.login(userId: idInfo, pw: pwInfo) { result in
            DispatchQueue.main.async {
                switch APIResponseAnalyze.analyze(result: result, vc: self) {
                case .success:
                    guard let userInfo = result["user"] as? UserInfo, let personalPage = UIStoryboard(name: "PersonalMemo", bundle: nil).instantiateViewController(withIdentifier: "MemoNavigationController") as? MemoNavigationController, let adminPage = UIStoryboard(name: "Admin", bundle: nil).instantiateViewController(withIdentifier: "AdminNavigationController") as? AdminNavigationController  else { return }
                    
                    // ViewModel에 적절한 유저정보 전달
                    AdminViewModel.shared.adminUser = (userInfo.isAdmin == 1 ? userInfo : nil)
                    UserInfoViewModel.shared.user = userInfo
                    MemoViewModel.shared.user = (userInfo.isAdmin == 1 ? nil : userInfo)
                    KeychainWrapper.standard.set(userInfo.userId, forKey: KeychainWrapper.Key.id.rawValue)
                    KeychainWrapper.standard.set(userInfo.refreshToken ?? "", forKey: KeychainWrapper.Key.refreshToken.rawValue)
                    // 어드민 혹은 메모 페이지로 이동
                    if userInfo.isAdmin == 1 {
                        adminPage.modalPresentationStyle = .fullScreen
                        adminPage.modalTransitionStyle = .crossDissolve
                        self.present(adminPage, animated: true, completion: {
                            self.idTextField.text = ""
                            self.pwTextField.text = ""
                        })
                    } else {
                        personalPage.modalPresentationStyle = .fullScreen
                        personalPage.modalTransitionStyle = .crossDissolve
                        self.present(personalPage, animated: true, completion: {
                            self.idTextField.text = ""
                            self.pwTextField.text = ""
                        })
                    }
                default:
                    if let message = result["message"] as? String, message == "No user found" {
                        let alert = UIAlertController(title: "", message: "해당 이메일로 가입된 정보가 없습니다", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    } else if let message = result["message"] as? String, message == "Incorrect password" {
                        let alert = UIAlertController(title: "", message: "비밀번호가 일치하지 않습니다", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "", message: "로그인할 수 없습니다", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // 회원가입
    @IBAction func registerButtonDidTap(_ sender: Any) {
        guard let registerPage = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterNavigationController") as? RegisterNavigationController else { return }
        registerPage.modalPresentationStyle = .fullScreen
        self.present(registerPage, animated: true, completion: {
            self.idTextField.text = ""
            self.pwTextField.text = ""
        })
    }
    
    // 이메일 인증 후 비밀번호 변경
    @IBAction func forgetPwButton(_ sender: Any) {
        guard let forgotPwPage = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "PwChangeNavigationController") as? PwChangeNavigationController else { return }
        forgotPwPage.modalPresentationStyle = .fullScreen
        self.present(forgotPwPage, animated: true, completion: {
            self.idTextField.text = ""
            self.pwTextField.text = ""
        })
    }
    
    // 자동로그인
    @IBAction func autoLoginButtonDidTap(_ sender: Any) {
        let autoLogin: Bool = UserDefaults.standard.bool(forKey: "autoLogin")
        UserDefaults.standard.set(!autoLogin, forKey: "autoLogin")
        if !autoLogin {
            autoLoginLabel.textColor = UIColor.customViolet
            autoLoginCheckImage.image = UIImage(systemName: "checkmark.square.fill")
            autoLoginCheckImage.tintColor = UIColor.customViolet
        } else {
            autoLoginLabel.textColor = UIColor.lightGray
            autoLoginCheckImage.image = UIImage(systemName: "square")
            autoLoginCheckImage.tintColor = UIColor.lightGray
        }
    }
    
    
    // 백그라운드 탭
    @IBAction func backgroundDidTap(_ sender: Any) {
        idTextField.resignFirstResponder()
        pwTextField.resignFirstResponder()
    }
    
    // MARK: TextField action
    @IBAction func pwTextFieldDidBegin(_ sender: Any) {
        pwTextField.text = ""
    }
    
    // MARK: Automatically move to other pages
    func automaticLogin(id: String, refreshToken: String) {
        UsersAPIService.shared.autoLogin(userId: id, refreshToken: refreshToken) { result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                switch APIResponseAnalyze.analyze(result: result, vc: self) {
                case .success:
                    guard let userInfo = result["user"] as? UserInfo, let personalPage = UIStoryboard(name: "PersonalMemo", bundle: nil).instantiateViewController(withIdentifier: "MemoNavigationController") as? MemoNavigationController, let adminPage = UIStoryboard(name: "Admin", bundle: nil).instantiateViewController(withIdentifier: "AdminNavigationController") as? AdminNavigationController  else { return }
                    
                    // ViewModel에 적절한 유저정보 전달
                    AdminViewModel.shared.adminUser = (userInfo.isAdmin == 1 ? userInfo : nil)
                    UserInfoViewModel.shared.user = userInfo
                    MemoViewModel.shared.user = (userInfo.isAdmin == 1 ? nil : userInfo)
                    
                    // 어드민 혹은 메모 페이지로 이동
                    if userInfo.isAdmin == 1 {
                        adminPage.modalPresentationStyle = .fullScreen
                        adminPage.modalTransitionStyle = .crossDissolve
                        self.present(adminPage, animated: true, completion: {
                            self.animationView.stop()
                            self.animationView.alpha = 0
                            self.loadingView.alpha = 0
                            self.idTextField.text = ""
                            self.pwTextField.text = ""
                        })
                    } else {
                        personalPage.modalPresentationStyle = .fullScreen
                        personalPage.modalTransitionStyle = .crossDissolve
                        self.present(personalPage, animated: true, completion: {
                            self.animationView.stop()
                            self.animationView.alpha = 0
                            self.loadingView.alpha = 0
                            self.idTextField.text = ""
                            self.pwTextField.text = ""
                        })
                    }
                default:
                    if let message = result["message"] as? String, message == "No user found" {
                        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                            self.loadingView.alpha = 0
                            self.animationView.alpha = 0
                        } completion: { _ in
                            let alert = UIAlertController(title: "", message: "해당 이메일로 가입된 정보가 없습니다", preferredStyle: .alert)
                            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else if let message = result["message"] as? String, message == "Incorrect password" {
                        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                            self.loadingView.alpha = 0
                            self.animationView.alpha = 0
                        } completion: { _ in
                            let alert = UIAlertController(title: "", message: "비밀번호가 일치하지 않습니다", preferredStyle: .alert)
                            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                            self.loadingView.alpha = 0
                            self.animationView.alpha = 0
                        } completion: { _ in
                            
                            let alert = UIAlertController(title: "", message: "로그인할 수 없습니다", preferredStyle: .alert)
                            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    func onRegister() {
        let alert = UIAlertController(title: "", message: "회원가입 중이던 정보가 있습니다. 이어서 회원가입을 진행하시겠습니까?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "취소", style: .default) { _ in
            UserDefaults.standard.set(false, forKey: "onRegister")
            UserDefaults.standard.removeObject(forKey: "onRegister-Email")
        }
        let action2 = UIAlertAction(title: "이동", style: .default) { _ in
            guard let registerPage = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterNavigationController") as? RegisterNavigationController else { return }
            registerPage.modalPresentationStyle = .fullScreen
            self.present(registerPage, animated: true, completion: {
                self.idTextField.text = ""
                self.pwTextField.text = ""
            })
        }
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
}

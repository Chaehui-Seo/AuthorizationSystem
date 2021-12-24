//
//  CurrentPwCheckViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/16.
//

import Foundation
import UIKit

class CurrentPwCheckViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pwTextField: UITextField!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.style()
    }
    
    // MARK: UI Setting
    func style() {
        nextButton.layer.cornerRadius = 25
    }
    
    // MARK: Password Input
    @IBAction func pwTextFieldEditingChanged(_ sender: Any) {
        guard UserManager.shared.user != nil else { return }
        guard let pwInfo = pwTextField.text, pwInfo.isEmpty == false else {
            nextButton.isEnabled = false
            return
        }
        nextButton.isEnabled = true
    }
    
    // MARK: Button Action
    // 다음
    @IBAction func nextButtonDidTap(_ sender: Any) {
        guard let userInfo = UserManager.shared.user, let pwInfo = pwTextField.text, pwInfo.isEmpty == false else { return }
        UsersAPIService.shared.login(userId: userInfo.userId, pw: pwInfo) { result in
            print(result)
            if let success = result["success"] as? Int, success == 1 {
                DispatchQueue.main.async {                
                    guard let changePwPage = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "PwChangeViewController") as? PwChangeViewController, var viewControllers = self.navigationController?.viewControllers else { return }
                    viewControllers[viewControllers.count - 1] = changePwPage
                    self.navigationController?.setViewControllers(viewControllers, animated: true)
                }
            } else {
                if let message = result["message"] as? String, message == "Incorrect password" {
                    DispatchQueue.main.async {
                        self.pwTextField.text = ""
                        let alert = UIAlertController(title: "", message: "비밀번호가 일치하지 않습니다", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.pwTextField.text = ""
                        let alert = UIAlertController(title: "", message: "오류가 발생했습니다", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
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

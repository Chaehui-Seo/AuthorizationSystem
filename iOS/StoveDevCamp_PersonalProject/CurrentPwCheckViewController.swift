//
//  CurrentPwCheckViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/16.
//

import Foundation
import UIKit

class CurrentPwCheckViewController: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pwTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.style()
    }
    
    func style() {
        nextButton.layer.cornerRadius = 25
    }
    
    @IBAction func pwTextFieldEditingChanged(_ sender: Any) {
        guard UserInfoViewModel.shared.user != nil else { return }
        guard let pwInfo = pwTextField.text, pwInfo.isEmpty == false else {
            nextButton.isEnabled = false
            return
        }
        nextButton.isEnabled = true
    }
    
    @IBAction func nextButtonDidTap(_ sender: Any) {
        guard let userInfo = UserInfoViewModel.shared.user, let pwInfo = pwTextField.text, pwInfo.isEmpty == false else { return }
        UsersAPIService.shared.login(userId: userInfo.userId, pw: pwInfo) { result in
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
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

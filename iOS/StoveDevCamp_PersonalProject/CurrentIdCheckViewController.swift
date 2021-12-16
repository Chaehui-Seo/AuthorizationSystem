//
//  CurrentIdCheckViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/16.
//

import Foundation
import UIKit

class CurrentIdCheckViewController: UIViewController {
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var sendVerifyMailButton: UIButton!
    
    @IBOutlet weak var verifyNumTitleLabel: UILabel!
    @IBOutlet weak var verifyNumTextField: UITextField!
    @IBOutlet weak var verifyNumUnderLine: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    var verifyNum: Int?
    var verifyId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.style()
    }
    
    func style() {
        sendVerifyMailButton.layer.cornerRadius = 25
        nextButton.layer.cornerRadius = 25
    }
    
    func isValidEmail(input: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailCheck = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailCheck.evaluate(with: input)
    }
    
    @IBAction func idTextFieldEditingChanged(_ sender: Any) {
        guard let idInfo = idTextField.text, idInfo.isEmpty == false else {
            sendVerifyMailButton.isEnabled = false
            return
        }
        if let viewModelIdInfo = RegisterViewModel.shared.userId {
            if idInfo != viewModelIdInfo {
                verifyNumTitleLabel.isHidden = true
                verifyNumTextField.isHidden = true
                verifyNumUnderLine.isHidden = true
                nextButton.isHidden = true
                sendVerifyMailButton.isEnabled = false
                RegisterViewModel.shared.userId = nil
            }
        } else {
            if isValidEmail(input: idInfo) {
                sendVerifyMailButton.isEnabled = true
            } else {
                sendVerifyMailButton.isEnabled = false
            }
        }
        
    }
    
    @IBAction func sendVerifyMailButtonDidTap(_ sender: Any) {
        guard let idInfo = idTextField.text, idInfo.isEmpty == false else { return }
        UsersAPIService.shared.sendEmailForPw(userId: idInfo) { result in
            print(result)
            if let success = result["success"] as? Int, success == 1, let verify = result["message"] as? Int {
                self.verifyNum = verify
                self.verifyId = idInfo
                DispatchQueue.main.async {
                    self.sendVerifyMailButton.isHidden = true
                    self.verifyNumTitleLabel.isHidden = false
                    self.verifyNumTextField.isHidden = false
                    self.verifyNumUnderLine.isHidden = false
                    self.nextButton.isHidden = false
                }
            } else if let message = result["message"] as? String, message == "Unavailable userId" {
                // 실패
                DispatchQueue.main.async {
                    self.idTextField.text = ""
                    let alert = UIAlertController(title: "", message: "회원정보가 존재하지 않습니다", preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.idTextField.text = ""
                    let alert = UIAlertController(title: "", message: "인증번호가 일치하지 않습니다", preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func verifyNumTextFieldEditingChanged(_ sender: Any) {
        guard let verifyInputInfo = verifyNumTextField.text, verifyInputInfo.isEmpty == false else {
            nextButton.isEnabled = false
            return
        }
        nextButton.isEnabled = true
    }
    
    @IBAction func nextButtonDidTap(_ sender: Any) {
        guard let verifyInput = verifyNumTextField.text, verifyInput.isEmpty == false, let inputNum = Int(verifyInput), let verify = verifyNum else { return }
        if inputNum == verify {
            guard let changePwPage = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "PwChangeViewController") as? PwChangeViewController, var viewControllers = self.navigationController?.viewControllers else { return }
            changePwPage.idInfo = self.verifyId
            viewControllers[viewControllers.count - 1] = changePwPage
            self.navigationController?.setViewControllers(viewControllers, animated: true)
        } else {
            let alert = UIAlertController(title: "", message: "인증번호가 일치하지 않습니다", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

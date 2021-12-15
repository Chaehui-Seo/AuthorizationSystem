//
//  IdInputViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit

class IdInputViewController: UIViewController {
    @IBOutlet weak var idFormatCheckLabel: UILabel!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var sendVerifyMailButton: UIButton!
    
    @IBOutlet weak var verifyNumTitleLabel: UILabel!
    @IBOutlet weak var verifyNumTextField: UITextField!
    @IBOutlet weak var verifyNumUnderLine: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    var verifyNum: Int?
    
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
            idFormatCheckLabel.isHidden = false
            idFormatCheckLabel.text = "이메일을 입력해주세요"
            idFormatCheckLabel.textColor = UIColor.customViolet
            sendVerifyMailButton.isEnabled = false
            return
        }
        if let viewModelIdInfo = RegisterViewModel.shared.userId {
            if idInfo != viewModelIdInfo {
                idFormatCheckLabel.isHidden = false
                idFormatCheckLabel.text = "이메일을 다시 입력 후 인증을 시도해주세요"
                idFormatCheckLabel.textColor = UIColor.systemRed
                verifyNumTitleLabel.isHidden = true
                verifyNumTextField.isHidden = true
                verifyNumUnderLine.isHidden = true
                nextButton.isHidden = true
                sendVerifyMailButton.isEnabled = false
                RegisterViewModel.shared.userId = nil
            }
        } else {
            if isValidEmail(input: idInfo) {
                idFormatCheckLabel.isHidden = true
                sendVerifyMailButton.isEnabled = true
            } else {
                idFormatCheckLabel.isHidden = false
                idFormatCheckLabel.text = "올바른 형식의 이메일을 입력해주세요"
                idFormatCheckLabel.textColor = UIColor.systemRed
                sendVerifyMailButton.isEnabled = false
            }
        }
        
    }
    
    @IBAction func sendVerifyMailButtonDidTap(_ sender: Any) {
        guard let idInfo = idTextField.text, idInfo.isEmpty == false else { return }
        UsersAPIService.shared.sendEmailVerification(userId: idInfo) { result in
            print("result: \(result)")
            if let success = result["success"] as? Int, success == 1, let verify = result["message"] as? Int {
                RegisterViewModel.shared.userId = idInfo
                self.verifyNum = verify
                DispatchQueue.main.async {
                    self.sendVerifyMailButton.isHidden = true
                    self.verifyNumTitleLabel.isHidden = false
                    self.verifyNumTextField.isHidden = false
                    self.verifyNumUnderLine.isHidden = false
                    self.nextButton.isHidden = false
                }
            } else {
                
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
            guard let nickNamePage = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "NickNameInputViewController") as? NickNameInputViewController else { return }
            self.navigationController?.pushViewController(nickNamePage, animated: true)
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

//
//  NicknameChangeViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/16.
//

import Foundation
import UIKit

class NicknameChangeViewController: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var nickNameValidCheckLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.style()
    }
    
    func style() {
        nextButton.layer.cornerRadius = 25
    }
    
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
    
    @IBAction func nextButtonDidTap(_ sender: Any) {
        guard let nickNameInfo = nickNameTextField.text, nickNameInfo.isEmpty == false, let userInfo = UserInfoViewModel.shared.user else { return }
        UsersAPIService.shared.changeNickName(jwt: userInfo.jwt, userId: userInfo.userId, nickName: nickNameInfo, isAdmin: userInfo.isAdmin) { result in
            if let success = result["success"] as? Int, success == 1, let user = result["user"] as? UserInfo {
                UserInfoViewModel.shared.user = user
                if let memoUser = MemoViewModel.shared.user, memoUser.userId == user.userId {
                    MemoViewModel.shared.user = user
                } else {
                    print(1)
                    UsersAPIService.shared.loadUsers { list in
                        print(2)
                        print(list)
                        AdminViewModel.shared.users = list
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
            } else if let message = result["message"] as? String, message == "Unavailable nickName" {
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
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
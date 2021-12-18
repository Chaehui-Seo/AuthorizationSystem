//
//  MemoCreateViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit
import Combine
import SwiftKeychainWrapper

class MemoCreateViewController: UIViewController{
    
    // MARK: Properties
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var outlinedView: UIView!
    @IBOutlet weak var filledView: UIView!
    @IBOutlet weak var memoTextView: UITextView!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    private var cancellable: Set<AnyCancellable> = []
    var colorString: String?
    
    let picker = UIColorPickerViewController()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha = 0
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            self.view.alpha = 1
        }
        picker.delegate = self
        if let selectedMemo = MemoViewModel.shared.selectedMemo {
            picker.selectedColor = hexStringToUIColor(hex: selectedMemo.color)
        } else {
            picker.selectedColor = UIColor.customLightViolet
        }
        self.style()
        self.bindViewModel()
    }
    
    // MARK: UI Setting
    func style() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        backView.layer.cornerRadius = 10
        outlinedView.layer.borderColor = UIColor.customDarkGray.cgColor
        outlinedView.layer.borderWidth = 2
        outlinedView.layer.cornerRadius = 2
        filledView.backgroundColor = UIColor.customLightViolet
        filledView.layer.cornerRadius = 2
    }

    // MARK: Data Binding with Combine
    func bindViewModel() {
        // 수정 상황일 경우
        MemoViewModel.shared.$selectedMemo.receive(on: RunLoop.main)
            .sink { [weak self] memo in
                guard let self = self, let info = memo else { return }
                self.deleteButton.isHidden = false
                self.memoTextView.text = info.content
                self.filledView.backgroundColor = hexStringToUIColor(hex: info.color)
                self.colorString = info.color
            }.store(in: &cancellable)
    }
    
    // MARK: Button Action
    // 메모 삭제
    @IBAction func deleteButtonDidTap(_ sender: Any) {
        guard let selectedMemo = MemoViewModel.shared.selectedMemo, let user = MemoViewModel.shared.user, let currentUser = UserInfoViewModel.shared.user else { return }
        
        MemosAPIService.shared.deleteMemo(jwt: KeychainWrapper.standard[.accessToken], id: selectedMemo.id, userId: user.userId, isAdmin: currentUser.isAdmin) { result in
            DispatchQueue.main.async {
                switch APIResponseAnalyze.analyze_withToken(result: result, vc: self) {
                case .success :
                    if let list = result["memo"] as? [MemoInfo] {
                        MemoViewModel.shared.memos = list
                        MemoViewModel.shared.selectedMemo = nil
                        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                            self.view.alpha = 0
                        } completion: { _ in
                            self.view.removeFromSuperview()
                        }
                    }
                case .InvalidToken :
                    UsersAPIService.shared.checkRefreshToken(jwt: currentUser.refreshToken ?? "", userId: user.userId) { result2 in
                        DispatchQueue.main.async {
                            switch APIResponseAnalyze.analyze_withToken(result: result2, vc: self) {
                            case .success :
                                MemosAPIService.shared.deleteMemo(jwt: KeychainWrapper.standard[.accessToken], id: selectedMemo.id, userId: user.userId, isAdmin: currentUser.isAdmin) { result3 in
                                    DispatchQueue.main.async {
                                        switch APIResponseAnalyze.analyze_withToken(result: result3, vc: self) {
                                        case .success :
                                            if let list = result3["memo"] as? [MemoInfo] {
                                                MemoViewModel.shared.memos = list
                                                MemoViewModel.shared.selectedMemo = nil
                                                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                                                    self.view.alpha = 0
                                                } completion: { _ in
                                                    self.view.removeFromSuperview()
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
                                self.errorOccur()
                            }
                        }
                    }
                case .fail :
                    self.errorOccur()
                }
            }
        }
    }
    
    
    // 메모 생성
    @IBAction func doneButtonDidTap(_ sender: Any) {
        guard let user = MemoViewModel.shared.user, let currentUser = UserInfoViewModel.shared.user, let content = memoTextView.text, content.isEmpty == false else { return }
        if let selectedMemo = MemoViewModel.shared.selectedMemo {
            MemosAPIService.shared.editMemo(jwt: KeychainWrapper.standard[.accessToken], id: selectedMemo.id, userId: user.userId, color: colorString ?? "#C2C3F7", content: content, isAdmin: currentUser.isAdmin) { result in
                DispatchQueue.main.async {
                    switch APIResponseAnalyze.analyze_withToken(result: result, vc: self) {
                    case .success :
                        if let list = result["memo"] as? [MemoInfo] {
                            MemoViewModel.shared.memos = list
                            MemoViewModel.shared.selectedMemo = nil
                            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                                self.view.alpha = 0
                            } completion: { _ in
                                self.view.removeFromSuperview()
                            }
                        }
                    case .InvalidToken :
                        UsersAPIService.shared.checkRefreshToken(jwt: currentUser.refreshToken ?? "", userId: user.userId) { result2 in
                            DispatchQueue.main.async {
                                switch APIResponseAnalyze.analyze_withToken(result: result2, vc: self) {
                                case .success :
                                    MemosAPIService.shared.editMemo(jwt: KeychainWrapper.standard[.accessToken], id: selectedMemo.id, userId: user.userId, color: self.colorString ?? "#C2C3F7", content: content, isAdmin: currentUser.isAdmin) { result3 in
                                        DispatchQueue.main.async {
                                            switch APIResponseAnalyze.analyze_withToken(result: result3, vc: self) {
                                            case .success :
                                                if let list = result3["memo"] as? [MemoInfo] {
                                                    MemoViewModel.shared.memos = list
                                                    MemoViewModel.shared.selectedMemo = nil
                                                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                                                        self.view.alpha = 0
                                                    } completion: { _ in
                                                        self.view.removeFromSuperview()
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
                                    self.errorOccur()
                                }
                            }
                        }
                    case .fail :
                        self.errorOccur()
                    }
                }
            }
        } else {
            MemosAPIService.shared.createMemo(jwt: KeychainWrapper.standard[.accessToken], color: colorString ?? "#C2C3F7", userId: user.userId, isAdmin: currentUser.isAdmin, content: content) { result in
                DispatchQueue.main.async {
                    switch APIResponseAnalyze.analyze_withToken(result: result, vc: self) {
                    case .success :
                        if let list = result["memo"] as? [MemoInfo] {
                            MemoViewModel.shared.memos = list
                            MemoViewModel.shared.selectedMemo = nil
                            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                                self.view.alpha = 0
                            } completion: { _ in
                                self.view.removeFromSuperview()
                            }
                        }
                    case .InvalidToken :
                        UsersAPIService.shared.checkRefreshToken(jwt: currentUser.refreshToken ?? "", userId: user.userId) { result2 in
                            DispatchQueue.main.async {
                                switch APIResponseAnalyze.analyze_withToken(result: result2, vc: self) {
                                case .success :
                                    MemosAPIService.shared.createMemo(jwt: KeychainWrapper.standard[.accessToken], color: self.colorString ?? "#C2C3F7", userId: user.userId, isAdmin: currentUser.isAdmin, content: content) { result3 in
                                        DispatchQueue.main.async {
                                            switch APIResponseAnalyze.analyze_withToken(result: result3, vc: self) {
                                            case .success :
                                                if let list = result3["memo"] as? [MemoInfo] {
                                                    MemoViewModel.shared.memos = list
                                                    MemoViewModel.shared.selectedMemo = nil
                                                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                                                        self.view.alpha = 0
                                                    } completion: { _ in
                                                        self.view.removeFromSuperview()
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
                                    self.errorOccur()
                                }
                            }
                        }
                    case .fail :
                        self.errorOccur()
                    }
                }
            }
        }
    }
    
    // 취소 (돌아가기)
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        MemoViewModel.shared.selectedMemo = nil
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            self.view.alpha = 0
        } completion: { _ in
            self.view.removeFromSuperview()
        }
    }
    
    // 색상 선택
    @IBAction func colorPickButtonDidTap(_ sender: Any) {
        self.present(picker, animated: true, completion: nil)
        
    }
}


// MARK: Color Picker
extension MemoCreateViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        self.filledView.backgroundColor = viewController.selectedColor
        self.colorString = viewController.selectedColor.toHexString()
    }
    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        self.filledView.backgroundColor = viewController.selectedColor
        self.colorString = viewController.selectedColor.toHexString()
    }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.customLightViolet
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

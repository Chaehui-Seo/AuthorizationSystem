//
//  BlockedViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/16.
//

import Foundation
import UIKit
import Lottie
import SwiftKeychainWrapper

class BlockedViewController: UIViewController {
    
    // MARK: Propertied
    @IBOutlet weak var filledView: UIView!
    @IBOutlet weak var outlinedView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var emojiStackView: UIStackView!
    @IBOutlet weak var emojiBackgroundView: UIView!
    @IBOutlet weak var respondView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    var message: BlockMessage?

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.style()
        self.view.alpha = 0
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            self.view.alpha = 1
        }
        
        let animationView: AnimationView = .init(name: "warning")
        backView.insertSubview(animationView, at: 1)
        animationView.frame = CGRect(x: self.backView.bounds.midX - 30, y: 10, width: 60, height: 60)
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        animationView.loopMode = .loop
        guard let info = message else {
            self.messageLabel.text = "차단되었습니다"
            return
        }
        self.messageLabel.text = info.content
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
//        emojiBackgroundView.layer.borderWidth = 2
//        emojiBackgroundView.layer.borderColor = UIColor.lightGray.cgColor
        emojiBackgroundView.layer.cornerRadius = 25
        logoutButton.layer.cornerRadius = 30
        emojiBackgroundView.layer.masksToBounds = false
        emojiBackgroundView.layer.shadowColor = UIColor.black.cgColor
        emojiBackgroundView.layer.shadowOffset = CGSize(width: 5, height: 5)
        emojiBackgroundView.layer.shadowOpacity = 0.3
        emojiBackgroundView.layer.shadowRadius = 5.0
        self.emojiStackView.alpha = 0
        self.emojiBackgroundView.alpha = 0
    }
    
    // MARK: Button Action
    // 반응하기
    @IBAction func respondLongPressed(_ sender: Any) {
        if emojiBackgroundView.isHidden == true {
            self.emojiBackgroundView.isHidden = false
            self.emojiStackView.isHidden = false
            self.emojiBackgroundView.transform = CGAffineTransform(translationX: 0, y: 10)
            self.emojiStackView.transform = CGAffineTransform(translationX: 0, y: 10)
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                self.emojiBackgroundView.alpha = 1
                self.emojiStackView.alpha = 1
                self.emojiBackgroundView.transform = CGAffineTransform.identity
                self.emojiStackView.transform = CGAffineTransform.identity
            }

            for i in emojiStackView.arrangedSubviews {
                i.removeFromSuperview()
            }
            
            let animationView1: AnimationView = .init(name: "good-emoji")
            emojiStackView.addArrangedSubview(animationView1)
            animationView1.contentMode = .scaleAspectFit
            animationView1.play()
            animationView1.loopMode = .loop
            
            let animationView2: AnimationView = .init(name: "normal-emoji")
            emojiStackView.addArrangedSubview(animationView2)
            animationView2.contentMode = .scaleAspectFit
            animationView2.play()
            animationView2.loopMode = .loop
            
            let animationView3: AnimationView = .init(name: "bad-emoji")
            emojiStackView.addArrangedSubview(animationView3)
            animationView3.contentMode = .scaleAspectFit
            animationView3.play()
            animationView3.loopMode = .loop
            
            let button1 = UIButton()
            let button2 = UIButton()
            let button3 = UIButton()
            self.emojiBackgroundView.addSubview(button1)
            self.emojiBackgroundView.addSubview(button2)
            self.emojiBackgroundView.addSubview(button3)
            
            button1.addTarget(self, action: #selector(goodEmojiDidTap), for: .touchUpInside)
            button2.addTarget(self, action: #selector( normalEmojiDidTap), for: .touchUpInside)
            button3.addTarget(self, action: #selector(badEmojiDidTap), for: .touchUpInside)
            
            button1.translatesAutoresizingMaskIntoConstraints = false
            button2.translatesAutoresizingMaskIntoConstraints = false
            button3.translatesAutoresizingMaskIntoConstraints = false
            animationView1.translatesAutoresizingMaskIntoConstraints = false
            animationView2.translatesAutoresizingMaskIntoConstraints = false
            animationView3.translatesAutoresizingMaskIntoConstraints = false
            
            
            NSLayoutConstraint.activate([
                animationView1.widthAnchor.constraint(equalToConstant: 40),
                animationView1.heightAnchor.constraint(equalToConstant: 40),
                animationView2.widthAnchor.constraint(equalToConstant: 40),
                animationView2.heightAnchor.constraint(equalToConstant: 40),
                animationView3.widthAnchor.constraint(equalToConstant: 40),
                animationView3.heightAnchor.constraint(equalToConstant: 40),
                
                button1.leadingAnchor.constraint(equalTo: animationView1.leadingAnchor),
                button1.trailingAnchor.constraint(equalTo: animationView1.trailingAnchor),
                button1.topAnchor.constraint(equalTo: animationView1.topAnchor),
                button1.bottomAnchor.constraint(equalTo: animationView1.bottomAnchor),
                
                button2.leadingAnchor.constraint(equalTo: animationView2.leadingAnchor),
                button2.trailingAnchor.constraint(equalTo: animationView2.trailingAnchor),
                button2.topAnchor.constraint(equalTo: animationView2.topAnchor),
                button2.bottomAnchor.constraint(equalTo: animationView2.bottomAnchor),
                
                button3.leadingAnchor.constraint(equalTo: animationView3.leadingAnchor),
                button3.trailingAnchor.constraint(equalTo: animationView3.trailingAnchor),
                button3.topAnchor.constraint(equalTo: animationView3.topAnchor),
                button3.bottomAnchor.constraint(equalTo: animationView3.bottomAnchor),
            ])
        }
    }
    
    // Good emoji 반응
    @objc func goodEmojiDidTap() {
        emojiSelected(name: "good-emoji", responseNum: 0)
    }
    
    // Normal emoji 반응
    @objc func normalEmojiDidTap() {
        emojiSelected(name: "normal-emoji", responseNum: 1)
    }
    
    // Bad emoji 반응
    @objc func badEmojiDidTap() {
        emojiSelected(name: "bad-emoji", responseNum: 2)
        
    }
    
    // 이모지 반응 general
    func emojiSelected(name: String, responseNum: Int) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.emojiStackView.alpha = 0
            self.emojiBackgroundView.alpha = 0
        } completion: { _ in
            self.emojiBackgroundView.isHidden = true
            self.emojiStackView.isHidden = true
        }
        var changeColor = UIColor.customLightViolet
        switch responseNum {
        case 0:
            changeColor = UIColor.systemYellow.withAlphaComponent(0.3)
        case 1:
            changeColor = UIColor.systemGreen.withAlphaComponent(0.3)
        default:
            changeColor = UIColor.systemRed.withAlphaComponent(0.3)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) { self.filledView.backgroundColor = changeColor }
        let badResultView: AnimationView = .init(name: name)
        respondView.addSubview(badResultView)
        badResultView.frame = CGRect(x: self.respondView.bounds.midX - 50, y: self.respondView.bounds.midY - 50, width: 100, height: 100)
        badResultView.contentMode = .scaleAspectFit
        badResultView.play { _ in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                badResultView.alpha = 0
                self.filledView.backgroundColor = UIColor.customLightViolet
            } completion: { _ in
                badResultView.removeFromSuperview()
            }
        }
        guard let userInfo = UserInfoViewModel.shared.user, let messageInfo = self.message else { return }
        BlockMessageAPIService.shared.editBlockMessage(jwt: KeychainWrapper.standard[.accessToken], id: messageInfo.id, userId: userInfo.userId, response: responseNum) { _ in }
    }
    
    // 백그라운드 탭
    @IBAction func backgroundDidTap(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.emojiStackView.alpha = 0
            self.emojiBackgroundView.alpha = 0
        } completion: { _ in
            self.emojiBackgroundView.isHidden = true
            self.emojiStackView.isHidden = true
        }
    }
    
    // 로그아웃
    @IBAction func logoutButtonDidTap(_ sender: Any) {
        MemoViewModel.shared.selectedMemo = nil
        AdminViewModel.shared.adminUser = nil
        UserInfoViewModel.shared.user = nil
        MemoViewModel.shared.user = nil
        MemoViewModel.shared.memos = nil
        KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.accessToken.rawValue)
        KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.id.rawValue)
        KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.refreshToken.rawValue)
        self.parent?.dismiss(animated: true, completion: nil)
    }
}

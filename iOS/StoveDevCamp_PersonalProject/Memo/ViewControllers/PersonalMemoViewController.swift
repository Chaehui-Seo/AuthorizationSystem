//
//  personalMemoViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit
import Combine
import SwiftKeychainWrapper

class PersonalMemoViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var nickNameOutlinedLabel: OutlinedLabel!
    @IBOutlet weak var nickNameFilledLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingButton: UIButton!
    private var cancellable: Set<AnyCancellable> = []
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.style()
        self.bindViewModel()
    }
    
    // MARK: UI Setting
    func style() {
        nickNameOutlinedLabel.outlineColor = UIColor.customDarkGray
        nickNameOutlinedLabel.outlineWidth = 2
    }
    
    // MARK: Data binding by using Combine
    func bindViewModel() {
        MemoViewModel.shared.$user.receive(on: RunLoop.main)
            .sink { [weak self] user in
                // user = 누구의 메모지를 보고 있는가
                // currentUser = 로그인된 사람은 누구인가
                guard let self = self, let userInfo = user, let currentUser  = UserInfoViewModel.shared.user else { return }
                // 설정 버튼은 로그인한 계정 = 메모 계정일 경우에만 보여야 함
                self.settingButton.isHidden = (userInfo.userId != currentUser.userId)
                
                self.emailLabel.text = userInfo.userId
                self.nickNameFilledLabel.text = userInfo.nickName
                self.nickNameOutlinedLabel.text = userInfo.nickName
                
                if userInfo.isBlocked == 1, userInfo.userId == currentUser.userId {
                    // 현재 메모 계정은 block 되어 있고, 어드민으로 접근하지 않은 경우
                    self.userIsBlocked()
                } else {
                    // 메모 계정이 block 되지 않았거나, 어드민으로 접근한 경우
                    MemosAPIService.shared.loadMemos(jwt: KeychainWrapper.standard[.accessToken], userId: userInfo.userId, isAdmin: currentUser.isAdmin) { result in
                        DispatchQueue.main.async {
                            switch APIResponseAnalyze.analyze_withToken(result: result, vc: self) {
                            case .success :
                                if let list = result["memo"] as? [MemoInfo] {
                                    MemoViewModel.shared.memos = list
                                }
                            case .InvalidToken :
                                UsersAPIService.shared.checkRefreshToken() { result2 in
                                    DispatchQueue.main.async {
                                        switch APIResponseAnalyze.analyze_withToken(result: result2, vc: self) {
                                        case .success :
                                            MemosAPIService.shared.loadMemos(jwt: KeychainWrapper.standard[.accessToken], userId: userInfo.userId, isAdmin: currentUser.isAdmin) { result3 in
                                                DispatchQueue.main.async {
                                                    switch APIResponseAnalyze.analyze_withToken(result: result3, vc: self) {
                                                    case .success :
                                                        if let list = result3["memo"] as? [MemoInfo] {
                                                            MemoViewModel.shared.memos = list
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
            }.store(in: &cancellable)
        
        MemoViewModel.shared.$memos.receive(on: RunLoop.main)
            .sink { [weak self] memo in
                guard let self = self else { return }
                self.tableView.reloadData()
            }.store(in: &cancellable)
    }
    
    // MARK: User blocked
    func userIsBlocked() {
        if AdminViewModel.shared.adminUser == nil {
            guard let userInfo = UserInfoViewModel.shared.user else { return }
            BlockMessageAPIService.shared.loadBlockMessages(jwt: KeychainWrapper.standard[.accessToken], userId: userInfo.userId) { result in
                DispatchQueue.main.async {
                    switch APIResponseAnalyze.analyze_withToken(result: result, vc: self) {
                    case .success :
                        if let list = result["message"] as? [BlockMessage] {
                            guard let blockedPage = UIStoryboard(name: "PersonalMemo", bundle: nil).instantiateViewController(withIdentifier: "BlockedViewController") as? BlockedViewController else { return }
                            if list.count > 0 {
                                blockedPage.message = list[0]
                            }
                            self.addChild(blockedPage)
                            blockedPage.view.frame = self.view.frame
                            self.view.addSubview(blockedPage.view)
                            blockedPage.didMove(toParent: self)
                        }
                    case .InvalidToken :
                        UsersAPIService.shared.checkRefreshToken() { result2 in
                            DispatchQueue.main.async {
                                switch APIResponseAnalyze.analyze_withToken(result: result2, vc: self) {
                                case .success :
                                    BlockMessageAPIService.shared.loadBlockMessages(jwt: KeychainWrapper.standard[.accessToken], userId: userInfo.userId) { result3 in
                                        DispatchQueue.main.async {
                                            switch APIResponseAnalyze.analyze_withToken(result: result3, vc: self) {
                                            case .success :
                                                if let list = result3["message"] as? [BlockMessage] {
                                                    guard let blockedPage = UIStoryboard(name: "PersonalMemo", bundle: nil).instantiateViewController(withIdentifier: "BlockedViewController") as? BlockedViewController else { return }
                                                    if list.count > 0 {
                                                        blockedPage.message = list[0]
                                                    }
                                                    self.addChild(blockedPage)
                                                    blockedPage.view.frame = self.view.frame
                                                    self.view.addSubview(blockedPage.view)
                                                    blockedPage.didMove(toParent: self)
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
    
    // MARK: Move to Setting
    @IBAction func settingButtonDidTap(_ sender: Any) {
        guard let settingPage = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else { return }
        self.navigationController?.pushViewController(settingPage, animated: true)
    }
}

// MARK: UITableview
extension PersonalMemoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let memoInfo = MemoViewModel.shared.memos else { return 1 }
        return memoInfo.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell", for: indexPath) as? MemoCell else {
            return UITableViewCell()
        }
        guard let memoInfo = MemoViewModel.shared.memos else { return cell }
        if indexPath.row < memoInfo.count {
            cell.updateUI(info: memoInfo[indexPath.row])
        } else {
            cell.updateLastCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let memoInfo = MemoViewModel.shared.memos else { return }
        
        if indexPath.row < memoInfo.count {
            MemoViewModel.shared.selectedMemo = memoInfo[indexPath.row]
        } else {
            MemoViewModel.shared.selectedMemo = nil
        }
        guard let createMemoPage = UIStoryboard(name: "PersonalMemo", bundle: nil).instantiateViewController(withIdentifier: "MemoCreateViewController") as? MemoCreateViewController else { return }
        self.addChild(createMemoPage)
        createMemoPage.view.frame = self.view.frame
        self.view.addSubview(createMemoPage.view)
        createMemoPage.didMove(toParent: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

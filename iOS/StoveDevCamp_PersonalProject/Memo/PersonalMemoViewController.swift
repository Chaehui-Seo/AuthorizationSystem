//
//  personalMemoViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit
import Combine

class PersonalMemoViewController: UIViewController {
    @IBOutlet weak var nickNameOutlinedLabel: OutlinedLabel!
    @IBOutlet weak var nickNameFilledLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingButton: UIButton!
    private var cancellable: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.style()
        self.viewModelBind()
    }
    
    func style() {
        nickNameOutlinedLabel.outlineColor = UIColor.customDarkGray
        nickNameOutlinedLabel.outlineWidth = 2
    }
    
    func viewModelBind() {
        MemoViewModel.shared.$user.receive(on: RunLoop.main)
            .sink { [weak self] user in
                guard let self = self, let userInfo = user, let currentUser  = UserInfoViewModel.shared.user else { return }
                if userInfo.userId == currentUser.userId {
                    self.settingButton.isHidden = false
                } else {
                    self.settingButton.isHidden = true
                }
                self.nickNameFilledLabel.text = userInfo.nickName
                self.nickNameOutlinedLabel.text = userInfo.nickName
                MemosAPIService.shared.loadMemos(jwt: userInfo.jwt, userId: userInfo.userId, isAdmin: userInfo.isAdmin) { list in
                    MemoViewModel.shared.memos = list
                }
            }.store(in: &cancellable)
        
        MemoViewModel.shared.$memos.receive(on: RunLoop.main)
            .sink { [weak self] memo in
                guard let self = self else { return }
                self.tableView.reloadData()
            }.store(in: &cancellable)
    }
    
    func checkBlocked(isBlocked: Int) {
        if isBlocked == 1 {
            guard let blockedPage = UIStoryboard(name: "PersonalMemo", bundle: nil).instantiateViewController(withIdentifier: "BlockedViewController") as? BlockedViewController else { return }
            self.addChild(blockedPage)
            blockedPage.view.frame = self.view.frame
            self.view.addSubview(blockedPage.view)
            blockedPage.didMove(toParent: self)
        }
    }
    
    @IBAction func settingButtonDidTap(_ sender: Any) {
        guard let settingPage = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else { return }
        self.navigationController?.pushViewController(settingPage, animated: true)
    }
}

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
            print("selected")
            MemoViewModel.shared.selectedMemo = memoInfo[indexPath.row]
        } else {
            print("create")
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


class MemoCell: UITableViewCell {
    @IBOutlet weak var outLinedView: UIView!
    @IBOutlet weak var filledView: UIView!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var plusImageView: UIImageView!
    
    func updateUI(info: MemoInfo) {
        memoLabel.isHidden = false
        outLinedView.isHidden = false
        plusImageView.isHidden = true
        memoLabel.text = info.content
        outLinedView.layer.borderColor = UIColor.customDarkGray.cgColor
        outLinedView.layer.borderWidth = 2
        outLinedView.layer.cornerRadius = 2
//        filledView.backgroundColor = UIColor(hex: info.color)
        filledView.backgroundColor = UIColor.customViolet.withAlphaComponent(0.4)
        filledView.layer.cornerRadius = 2
    }
    
    func updateLastCell() {
        memoLabel.text = "추가"
        memoLabel.isHidden = true
        outLinedView.isHidden = true
        plusImageView.isHidden = false
        filledView.backgroundColor = UIColor.white
        filledView.layer.borderWidth = 2
        filledView.layer.borderColor = UIColor.customViolet.withAlphaComponent(0.4).cgColor
        filledView.layer.cornerRadius = 2
    }
}

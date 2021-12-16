//
//  MemoCreateViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit
import Combine

class MemoCreateViewController: UIViewController{
    private var cancellable: Set<AnyCancellable> = []
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var outlinedView: UIView!
    @IBOutlet weak var filledView: UIView!
    
    @IBOutlet weak var memoTextView: UITextView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha = 0
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            self.view.alpha = 1
        }

        self.bindViewModel()
        self.style()
    }
    
    func style() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        backView.layer.cornerRadius = 10
        outlinedView.layer.borderColor = UIColor.customDarkGray.cgColor
        outlinedView.layer.borderWidth = 2
        outlinedView.layer.cornerRadius = 2
        filledView.backgroundColor = UIColor.customViolet.withAlphaComponent(0.4)
        filledView.layer.cornerRadius = 2
    }
    
    func bindViewModel() {
        MemoViewModel.shared.$selectedMemo.receive(on: RunLoop.main)
            .sink { [weak self] memo in
                guard let self = self, let info = memo else { return }
                self.deleteButton.isHidden = false
                self.memoTextView.text = info.content
            }.store(in: &cancellable)
    }
    
    @IBAction func deleteButtonDidTap(_ sender: Any) {
        guard let selectedMemo = MemoViewModel.shared.selectedMemo, let user = MemoViewModel.shared.user else { return }
        MemosAPIService.shared.deleteMemo(jwt: user.jwt, id: selectedMemo.id, userId: user.userId, isAdmin: user.isAdmin) { list in
            MemoViewModel.shared.memos = list
            DispatchQueue.main.async {
                MemoViewModel.shared.selectedMemo = nil
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                    self.view.alpha = 0
                } completion: { _ in
                    self.view.removeFromSuperview()
                }
                
            }
        }
    }
    
    @IBAction func doneButtonDidTap(_ sender: Any) {
        guard let user = MemoViewModel.shared.user, let content = memoTextView.text, content.isEmpty == false else { return }
        if let selectedMemo = MemoViewModel.shared.selectedMemo {
            MemosAPIService.shared.editMemo(jwt: user.jwt, id: selectedMemo.id, userId: user.userId, color: "000000", content: content, isAdmin: user.isAdmin) { list in
                MemoViewModel.shared.memos = list
                DispatchQueue.main.async {
                    MemoViewModel.shared.selectedMemo = nil
                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                        self.view.alpha = 0
                    } completion: { _ in
                        self.view.removeFromSuperview()
                    }
                    
                }
            }
        } else {
            MemosAPIService.shared.createMemo(jwt: user.jwt, color: "000000", userId: user.userId, isAdmin: user.isAdmin, content: content) { list in
                MemoViewModel.shared.memos = list
                DispatchQueue.main.async {
                    MemoViewModel.shared.selectedMemo = nil
                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                        self.view.alpha = 0
                    } completion: { _ in
                        self.view.removeFromSuperview()
                    }
                    
                }
            }
        }
    }
    
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        MemoViewModel.shared.selectedMemo = nil
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            self.view.alpha = 0
        } completion: { _ in
            self.view.removeFromSuperview()
        }
    }
}

//
//  AdminMemoViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/16.
//

import Foundation
import UIKit

class AdminMemoViewController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var innerContainerView: UIView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // ContainerView 설정
        guard let memoPage = UIStoryboard(name: "PersonalMemo", bundle: nil)
            .instantiateViewController(withIdentifier: "MemoNavigationController") as? MemoNavigationController else { return }
        self.addChild(memoPage)
        self.innerContainerView.addSubview((memoPage.view)!)
        memoPage.view.frame = self.innerContainerView.bounds
        memoPage.didMove(toParent: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        MemoViewModel.shared.user = nil
    }
    
    // MARK: Button Action
    // 뒤로 가기
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

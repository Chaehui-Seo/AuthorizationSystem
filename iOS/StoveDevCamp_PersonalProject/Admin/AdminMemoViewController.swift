//
//  AdminMemoViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/16.
//

import Foundation
import UIKit

class AdminMemoViewController: UIViewController {
    @IBOutlet weak var innerContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

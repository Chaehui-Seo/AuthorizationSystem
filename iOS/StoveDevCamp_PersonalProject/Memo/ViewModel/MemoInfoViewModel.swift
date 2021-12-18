//
//  MemoViewModel.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit
import Combine

class MemoViewModel {
    static let shared = MemoViewModel()
    
    @Published var user: UserInfo?
    @Published var memos: [MemoInfo]?
    @Published var selectedMemo: MemoInfo?
}

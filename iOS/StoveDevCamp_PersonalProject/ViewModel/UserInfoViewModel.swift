//
//  UserInfoViewModel.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit
import Combine

class UserInfoViewModel {
    static let shared = UserInfoViewModel()
    
    @Published var user: UserInfo?
}

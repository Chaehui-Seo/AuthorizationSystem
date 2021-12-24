//
//  UserInfoViewModel.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit
import Combine

class UserManager {
    static let shared = UserManager()
    
    @Published var user: UserInfo?
}

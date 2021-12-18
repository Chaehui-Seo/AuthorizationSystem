//
//  AdminViewModel.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit
import Combine

class AdminViewModel {
    static let shared = AdminViewModel()
    
    @Published var adminUser: UserInfo?
    @Published var users: [UserInfo]?
    @Published var selectedUser: UserInfo?
}

//
//  KeychainWrapper+keys.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/17.
//

import Foundation
import SwiftKeychainWrapper

extension KeychainWrapper.Key {
    static let accessToken: KeychainWrapper.Key = "accessToken"
    static let refreshToken: KeychainWrapper.Key = "refreshToken"
    static let id: KeychainWrapper.Key = "id"
    static let autoLogin: KeychainWrapper.Key = "autoLogin"
}

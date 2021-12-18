//
//  UsersDataModel.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit

struct UserInfo: Codable {
    let userId: String
    let password: String
    let refreshToken: String?
    let nickName: String
    let isAdmin: Int
    let isBlocked: Int
    
    enum CodingKeys: String, CodingKey {
        case userId
        case password
        case refreshToken
        case nickName
        case isAdmin
        case isBlocked
    }
}

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
    let jwt: String?
    let nickName: String
    let isEmailVerified: Int
    let isAdmin: Int
    let isBlocked: Int
    let fcmToken: String?
    
    enum CodingKeys: String, CodingKey {
        case userId
        case password
        case jwt
        case nickName
        case isEmailVerified
        case isAdmin
        case isBlocked
        case fcmToken
    }
}

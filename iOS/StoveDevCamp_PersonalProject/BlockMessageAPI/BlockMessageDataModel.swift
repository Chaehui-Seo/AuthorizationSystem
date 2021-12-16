//
//  BlockMessageDataModel.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit

struct BlockMessageDataModel: Codable {
    let id: Int
    let content: String
    let isRead: Int
    let fromUser: String
    let toUser: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case isRead
        case fromUser
        case toUser
    }
}

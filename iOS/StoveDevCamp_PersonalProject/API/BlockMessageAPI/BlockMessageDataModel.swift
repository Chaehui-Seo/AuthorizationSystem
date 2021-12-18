//
//  BlockMessageDataModel.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit

struct BlockMessage: Codable {
    let id: Int
    let content: String
    let response: Int?
    let fromUser: String
    let toUser: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case response
        case fromUser
        case toUser
    }
}

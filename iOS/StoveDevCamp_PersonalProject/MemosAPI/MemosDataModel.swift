//
//  MemoDataModel.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit

struct MemoInfo: Codable {
    let id: Int
    let color: String
    let content: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case color
        case content
        case userId
    }
}

//
//  AdminListCell.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/17.
//

import Foundation
import UIKit

class AdminListCell: UITableViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var blockLabel: UILabel!
    
    func updateUI(no: Int, userInfo: UserInfo) {
        numberLabel.text = "\(no)"
        idLabel.text = userInfo.userId
        nickNameLabel.text = userInfo.nickName
        blockLabel.text = userInfo.isBlocked == 1 ? "O" : "X"
    }
}

//
//  MemoCell.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit

class MemoCell: UITableViewCell {
    @IBOutlet weak var outLinedView: UIView!
    @IBOutlet weak var filledView: UIView!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var plusImageView: UIImageView!
    
    func updateUI(info: MemoInfo) {
        memoLabel.isHidden = false
        outLinedView.isHidden = false
        plusImageView.isHidden = true
        memoLabel.text = info.content
        outLinedView.layer.borderColor = UIColor.customDarkGray.cgColor
        outLinedView.layer.borderWidth = 2
        outLinedView.layer.cornerRadius = 2
        filledView.backgroundColor = hexStringToUIColor(hex: info.color)
        filledView.layer.cornerRadius = 2
        filledView.layer.borderWidth = 0
    }
    
    func updateLastCell() {
        memoLabel.text = "추가"
        memoLabel.isHidden = true
        outLinedView.isHidden = true
        plusImageView.isHidden = false
        filledView.backgroundColor = UIColor.white
        filledView.layer.borderWidth = 2
        filledView.layer.borderColor = UIColor.customLightViolet.cgColor
        filledView.layer.cornerRadius = 2
    }
}

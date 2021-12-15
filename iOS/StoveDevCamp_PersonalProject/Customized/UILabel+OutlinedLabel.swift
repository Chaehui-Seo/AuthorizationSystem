//
//  UILabel+OutlinedLabel.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/14.
//

import Foundation
import UIKit

class OutlinedLabel: UILabel {

    var outlineWidth: CGFloat = 1
    var outlineColor: UIColor = UIColor.black

    override func drawText(in rect: CGRect) {
        let strokeTextAttributes = [
            NSAttributedString.Key.strokeColor : outlineColor,
            NSAttributedString.Key.strokeWidth : -1 * outlineWidth,
        ] as [NSAttributedString.Key : Any] as [NSAttributedString.Key : Any]

        self.attributedText = NSAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
        super.drawText(in: rect)
    }
}

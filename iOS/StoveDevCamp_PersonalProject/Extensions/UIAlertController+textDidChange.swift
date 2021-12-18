//
//  UIAlertController+textDidChange.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/17.
//

import Foundation
import UIKit

extension UIAlertController {
    @objc func textDidChange() {
        guard let textField = textFields?.first else { return }
        if textField.text?.count ?? 0 > 40 {
            textField.deleteBackward()
        }
    }
}

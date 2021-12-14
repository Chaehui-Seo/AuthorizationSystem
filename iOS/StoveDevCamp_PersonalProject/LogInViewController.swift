//
//  ViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/14.
//

import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet weak var underLineView: UIView!
    
    @IBOutlet weak var welcomeTitleLabel: UIOutlinedLabel!
    @IBOutlet weak var forgotPwButton: UIButton!
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.style()
    }
    
    func style() {
//        welcomeTitleLabel.outlineColor = UIColor.darkGray
//        welcomeTitleLabel.outlineWidth = 2
        idTextField.layer.cornerRadius = 22
        pwTextField.layer.cornerRadius = 22
        logInButton.layer.cornerRadius = 25
        logInButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.5)
        logInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        forgotPwButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        underLineView.alpha = 0.5
        underLineView.layer.cornerRadius = 3
    }
}


class UIOutlinedLabel: UILabel {

    var outlineWidth: CGFloat = 1
    var outlineColor: UIColor = UIColor.black

    override func drawText(in rect: CGRect) {
        print("draw")
        let strokeTextAttributes = [
            NSAttributedString.Key.strokeColor : outlineColor,
            NSAttributedString.Key.strokeWidth : -1 * outlineWidth,
        ] as [NSAttributedString.Key : Any] as [NSAttributedString.Key : Any]

        self.attributedText = NSAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
        super.drawText(in: rect)
    }
}

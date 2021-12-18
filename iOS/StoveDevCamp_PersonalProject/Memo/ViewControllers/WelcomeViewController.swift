//
//  WelcomeViewController.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/16.
//

import Foundation
import UIKit
import Lottie

class WelcomeViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var outlinedView: UIView!
    @IBOutlet weak var filledView: UIView!
    @IBOutlet weak var welcomeOutlinedLabel: OutlinedLabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    let animationView: AnimationView = .init(name: "confetti")
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.style()
        self.view.alpha = 0
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) { self.view.alpha = 1 }
        backView.addSubview(animationView)
        let width = self.backView.bounds.width
        let height = width / 940 * 752
        animationView.frame = CGRect(x: self.backView.bounds.minX, y: self.backView.bounds.minY - 20, width: width, height: height)
        animationView.contentMode = .scaleAspectFit
        animationView.play()
    }
    
    // MARK: UI Setting
    func style() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        backView.layer.cornerRadius = 10
        outlinedView.layer.borderColor = UIColor.customDarkGray.cgColor
        outlinedView.layer.borderWidth = 2
        outlinedView.layer.cornerRadius = 2
        filledView.backgroundColor = UIColor.customLightViolet
        filledView.layer.cornerRadius = 2
        welcomeOutlinedLabel.outlineColor = UIColor.customDarkGray
        welcomeOutlinedLabel.outlineWidth = 2
        confirmButton.layer.cornerRadius = 30
    }
    
    // MARK: Button Action
    // 확인
    @IBAction func doneButtonDidTap(_ sender: Any) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            self.view.alpha = 0
        } completion: { _ in
            self.view.removeFromSuperview()
        }
    }
    
    // 백그라운드 탭
    // 애니메이션/재미 요소
    @IBAction func backgorundTapped(_ sender: Any) {
        animationView.stop()
        let touchPoint = tapGesture.location(in: self.backView)
        let width = self.backView.bounds.width
        let height = width / 940 * 752
        animationView.frame = CGRect(x: touchPoint.x - (width / 2), y: touchPoint.y - (height / 2), width: width, height: height )
        animationView.play()
    }
}

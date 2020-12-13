//
//  SetupViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 7/12/19.
//  Copyright © 2019 Tadreik Campbell. All rights reserved.
//

import UIKit

final class SetupViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstFeature: UIView!
    @IBOutlet weak var secondFeature: UIView!
    @IBOutlet weak var thirdFeature: UIView!
    @IBOutlet weak var continueButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.layer.cornerRadius = continueButton.frame.height / 2
    }

    @IBAction func goToLogin(_ sender: Any) {
        pref.set(true, forKey: "hasLaunched")
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "mediator")
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        navController.isNavigationBarHidden = true
        self.present(navController, animated: true)
    }
}

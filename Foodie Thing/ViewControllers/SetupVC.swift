//
//  SetupViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 7/12/19.
//  Copyright © 2019 Tadreik Campbell. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstFeature: UIView!
    @IBOutlet weak var secondFeature: UIView!
    @IBOutlet weak var thirdFeature: UIView!
    @IBOutlet weak var continueButton: FoodieButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.refreshColor(color: UIColor(named: "FT Theme")!)
        continueButton.tintColor = .white
    }

    @IBAction func goToLogin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "mediator")
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        navController.isNavigationBarHidden = true
        self.present(navController, animated: true)
    }
}

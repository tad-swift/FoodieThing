//
//  DisplayViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 5/18/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import UIKit
import FirebaseAuth

final class LoginViewController: UIViewController {

    @IBOutlet weak var loginBtn: FoodieButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var emailField: HoshiTextField!
    @IBOutlet weak var passwordField: HoshiTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        loginLabel.text = "Login to continue"
        loginLabel.font = UIFont.systemFont(ofSize: 31, weight: .bold)
        loginBtn.refreshColor(color: .white)
        loginBtn.tintColor = UIColor(named: "FT Theme")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        if emailField.text != nil && passwordField != nil {
            if validateEmail(emailField.text!) {
                Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) {
                    (result, error) in
                    if error != nil {
                        self.newAlert(title: "Error logging in", body: "\(error!.localizedDescription)")
                    } else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainVC = (storyboard.instantiateViewController(withIdentifier: "tab"))
                        let navController = UINavigationController(rootViewController: mainVC)
                        navController.modalPresentationStyle = .fullScreen
                        navController.isNavigationBarHidden = true
                        self.present(navController, animated: true)
                    }
                }
            } else {
                newAlert(title: "Error logging in", body: "Could not validate email")
            }
            
        } else {
            newAlert(title: "Error logging in", body: "Username or password is blank")
        }
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func forgotPassTapped(_ sender: Any) {
        if emailField.text!.isEmpty {
            newAlert(title: "Error sending email", body: "Please enter your email")
        } else {
            Auth.auth().sendPasswordReset(withEmail: emailField.text!) { error in
                self.newAlert(title: "Error", body: "\(error!)")
            }
            newAlert(title: "Email sent", body: "Check your email \(self.emailField.text!) for a link to reset your password")
        }
        
    }
    
}

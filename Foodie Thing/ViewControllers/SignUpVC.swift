//
//  SignUpViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 5/18/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var policyLabel: ActiveLabel!
    @IBOutlet weak var emailField: HoshiTextField!
    @IBOutlet weak var usernameField: HoshiTextField!
    @IBOutlet weak var passwordField: HoshiTextField!
    @IBOutlet weak var signupBtn: FoodieButton!
    @IBOutlet weak var loginLabel: ActiveLabel!
    
    var db: Firestore!
    var users = [User]()
    var popRecognizer: InteractivePopRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        emailField.delegate = self
        usernameField.delegate = self
        passwordField.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        signupBtn.refreshColor(color: .white)
        signupBtn.tintColor = UIColor(named: "FT Theme")
        
        signupLabel.text = "Create an Account"
        signupLabel.font = UIFont.systemFont(ofSize: 31, weight: .bold)
        
        let privacyPolicy = ActiveType.custom(pattern: "\\sPrivacy\\sPolicy\\b")
        let loginText = ActiveType.custom(pattern: "\\sLog\\sin\\b")
        
        policyLabel.enabledTypes = [privacyPolicy]
        policyLabel.text = "By signing up, you agree to our Privacy Policy."
        policyLabel.customColor[privacyPolicy] = UIColor.cyan
        policyLabel.customSelectedColor[privacyPolicy] = UIColor.systemGray5
        
        policyLabel.handleCustomTap(for: privacyPolicy) { element in
            self.openUrl(link: "https://foodiething.com/privacy")
        }
        
        loginLabel.enabledTypes = [loginText]
        loginLabel.text = "Already have an account? Log in"
        loginLabel.customColor[loginText] = UIColor.cyan
        loginLabel.customSelectedColor[loginText] = UIColor.white
        loginLabel.handleCustomTap(for: loginText) { element in
            self.performSegue(withIdentifier: "goToLogin", sender: self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        users.removeAll()
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        getUsers()
        if emailField.text != nil && usernameField.text != nil && passwordField.text != nil{
            if validateEmail(emailField.text!) && validateUsername(name: usernameField.text!){
                if usernameField.text!.count > 20 {
                    newAlert(title: "Error creating account", body: "Username cannot be more than 20 characters")
                    users.removeAll()
                } else {
                    if canUseName() {
                        createNewUser()
                    } else {
                        newAlert(title: "Error creating account", body: "That username is taken")
                        users.removeAll()
                    }
                }
            } else {
                newAlert(title: "Error creating account", body: "Bad email or password")
                users.removeAll()
            }
        } else {
            newAlert(title: "Error creating account", body: "Please don't leave any fields blank")
            users.removeAll()
        }
    }
    
    func getUsers() {
        var tempList: [User]!
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let docRef = self.db.collection("users").document(document.documentID)
                    docRef.getDocument { (document, _) in
                        if let userData = document.flatMap({
                            $0.data().flatMap({ (data) in
                                return User(dictionary: data)
                            })
                        }) {
                            tempList.append(userData)
                            self.users = tempList
                            
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
            }
        }
    }
    
    func canUseName() -> Bool {
        var bool = false
        for user in users {
            if usernameField.text?.lowercased() == user.username?.lowercased() {
                bool = false
            } else {
                bool = true
            }
        }
        return bool
    }
    
    func createNewUser() {
        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { [self] authResult, error in
            if error != nil {
                newAlert(title: "Error creating account", body: "\(error!)")
            } else {
                let user = Auth.auth().currentUser
                
                let newUserData: [String: Any] = [
                    "bio": "",
                    "coverPhoto": "",
                    "email": emailField.text!,
                    "dateCreated": Timestamp(date: Date()),
                    "following": ["p1FcpQthBdQGHCjlsnFhZzE3bi53","SNQurG7nJtXWq2ve4UZ5dTwGL572"],
                    "profilePic": "",
                    "name": "",
                    "username": usernameField.text!,
                    "docID": user!.uid
                ]
                
                self.db.collection("users").document(user!.uid).setData(newUserData) { err in
                    if let err = err {
                        print("Error creating account: \(err)")
                        newAlert(title: "Error creating account", body: "\(err)")
                    } else {
                        print("Successfully created account with: \(String(describing: newUserData["email"]))!")
                    }
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainVC = (storyboard.instantiateViewController(withIdentifier: "tab"))
                let navController = UINavigationController(rootViewController: mainVC)
                navController.modalPresentationStyle = .fullScreen
                navController.isNavigationBarHidden = true
                self.present(navController, animated: true)
            }
        }
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

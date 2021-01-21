//
//  UsernameViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/29/20.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


final class UsernameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameField: FTField!
    @IBOutlet weak var validNameLabel: UILabel!
    @IBOutlet weak var letsgoBtn: UIButton!

    var usernames = [
        "foodiething","ft","foodything","foodiethings"
    ]
    var canContinue = false
    var foundMatchingName = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsers()
        usernameField.layer.cornerRadius = 8
        letsgoBtn.layer.cornerRadius = letsgoBtn.frame.height / 2
        usernameField.delegate = self
        validNameLabel.text = ""
        usernameField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    func getUsers() {
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                log.debug("Error getting documents: \(err as NSObject)")
            } else {
                for document in querySnapshot!.documents {
                    let docRef = db.collection("users").document(document.documentID)
                    docRef.getDocument { (document, _) in
                        if let userData = document.flatMap({
                            $0.data().flatMap({ (data) in
                                return User(dictionary: data)
                            })
                        }) {
                            self.usernames.append(userData.username!)
                        } else {
                            log.debug("Document does not exist")
                        }
                    }
                }
            }
        }
    }
    
    func loadUserData() {
        let user = Auth.auth().currentUser
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                log.debug("Error getting documents: \(err as NSObject)")
            } else {
                let docRef = db.collection("users").document(user!.uid)
                docRef.getDocument { (document, _) in
                    if let userObj = document.flatMap({
                        $0.data().flatMap({ (data) in
                            return User(dictionary: data)
                        })
                    }) {
                        myUser = userObj
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainTabBarController = storyboard.instantiateViewController(identifier: "tab")
                        (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(mainTabBarController)
                    }
                }
            }
        }
    }
    
    @objc func textFieldDidChange() {
        for username in usernames {
            if username.lowercased() == usernameField.text?.lowercased() {
                foundMatchingName = true
                break
            } else {
                foundMatchingName = false
            }
        }
        if validateUsername(name: usernameField.text!) {
            if foundMatchingName {
                canContinue = false
                validNameLabel.text = "Somebody already ate that one 😔"
                validNameLabel.textColor = UIColor.red
            } else {
                canContinue = true
                validNameLabel.text = "That username looks delicious! 🤤"
                validNameLabel.textColor = UIColor.init(red: 0, green: 0.5, blue: 0, alpha: 1)
            }
        } else {
            canContinue = false
            if usernameField.text!.count < 3 {
                if usernameField.text!.count == 0 {
                    validNameLabel.text = "Wow... such empty."
                    validNameLabel.textColor = UIColor.red
                } else {
                    validNameLabel.text = "Boo! Too short!"
                    validNameLabel.textColor = UIColor.red
                }
            } else {
                validNameLabel.text = "So sorry. You can't have special characters or spaces in your username."
                validNameLabel.textColor = UIColor.red
            }
        }
    }
    
    @IBAction func createAccount(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            let newUserData: [String: Any] = [
                "bio": "",
                "coverPhoto": "",
                "email": user.email ?? "",
                "dateCreated": Timestamp(date: Date()),
                "following": ["TP4naRGfbDhwVOvVHSGPOP16B603","CJNryI3DDqeg5UZo06UHyYgaDH82","NikUWpMT91hUmblXGdvwteGFoNl1"],
                "profilePic": "",
                "name": user.displayName ?? "",
                "username": usernameField.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                "docID": user.uid
            ]
            if canContinue {
                db.collection("users").document(user.uid).setData(newUserData) { _ in
                    self.loadUserData()
                }

            } else {
                newAlert(title: "Hold on", body: "Please enter a valid username first")
            }
        } else {
            newAlert(title: "Authentication error", body: "Something went wrong and your account couldn't be created. Please try again or contact us at inquiries@foodiething.com")
        }

    }
}

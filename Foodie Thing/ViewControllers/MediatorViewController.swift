//
//  MediatorViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/1/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import UIKit
import FirebaseAuth


final class MediatorViewController: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle!
    
    var biz: User! {
        didSet {
            handle = Auth.auth().addStateDidChangeListener { [self] (auth, user) in
                if user != nil {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainVC = storyboard.instantiateViewController(withIdentifier: "tab")
                    let navController = UINavigationController(rootViewController: mainVC)
                    navController.modalPresentationStyle = .fullScreen
                    navController.isNavigationBarHidden = true
                    self.present(navController, animated: false)
                } else {
                     let storyboard = UIStoryboard(name: "Login", bundle: nil)
                     let setupVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
                     let navController = UINavigationController(rootViewController: setupVC)
                     navController.modalPresentationStyle = .fullScreen
                     navController.isNavigationBarHidden = true
                     self.present(navController, animated: false)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if Auth.auth().currentUser != nil {
            loadUserData()
        } else {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let setupVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
            let navController = UINavigationController(rootViewController: setupVC)
            navController.modalPresentationStyle = .fullScreen
            navController.isNavigationBarHidden = true
            self.present(navController, animated: false)
        }
    }
    
    func loadUserData() {
        let user = Auth.auth().currentUser
        let docRef = db.collection("users").document(user!.uid)
        docRef.getDocument { (document, _) in
            if let userObj = document.flatMap({
                $0.data().flatMap({ (data) in
                    return User(dictionary: data)
                })
            }) {
                myUser = userObj
                self.biz = userObj
            } else {
                let firebaseAuth = Auth.auth()
                do {
                  try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                  log.debug("Error signing out: \(signOutError)")
                }
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let setupVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
                let navController = UINavigationController(rootViewController: setupVC)
                navController.modalPresentationStyle = .fullScreen
                navController.isNavigationBarHidden = true
                self.present(navController, animated: false)
            }
        }
    }

}

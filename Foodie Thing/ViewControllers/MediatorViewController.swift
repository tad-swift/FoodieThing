//
//  MediatorViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/1/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


final class MediatorViewController: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle!
    
    var biz: User! {
        didSet {
            handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                if user != nil {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainTabBarController = storyboard.instantiateViewController(identifier: "tab")
                    (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(mainTabBarController)
                } else {
                    let storyboard = UIStoryboard(name: "Login", bundle: nil)
                    let loginController = storyboard.instantiateViewController(identifier: "loginVC")
                    (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(loginController)
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
            let loginController = storyboard.instantiateViewController(identifier: "loginVC")
            (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(loginController)
        }
    }
    
    func loadUserData() {
        let user = Auth.auth().currentUser
        let docRef = db.collection("users").document(user!.uid)
        docRef.getDocument { (document, _) in
            let obj = try! document?.data(as: User.self)!
            myUser = obj
            self.biz = obj
        }
    }

}

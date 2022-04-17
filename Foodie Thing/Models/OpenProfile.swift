//
//  OpenProfile.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/2/20.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

extension UIViewController {
    func openProfile(name: String) {
        let docRef = Firestore.firestore().collection("users").document(name)
        docRef.getDocument { (document, _) in
            let userObj = try! document?.data(as: User.self)!
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let profileVC = storyboard.instantiateViewController(withIdentifier: "otherProfileVC") as! OtherProfileViewController
            profileVC.user = userObj
            self.show(profileVC, sender: self)
        }
    }
}

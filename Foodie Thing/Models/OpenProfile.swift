//
//  OpenProfile.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/2/20.
//

import UIKit
import FirebaseFirestore

extension UIViewController {
    func openProfile(name: String) {
        let docRef = db.collection("users").document(name)
        docRef.getDocument { (document, _) in
            if let userObj = document.flatMap({
                $0.data().flatMap({ (data) in
                    return User(dictionary: data)
                })
            }) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let profileVC = storyboard.instantiateViewController(withIdentifier: "otherProfileVC") as! OtherProfileViewController
                profileVC.user = userObj
                
                self.show(profileVC, sender: self)
            } else {
                log.debug("Document does not exist")
            }
            
        }
    }
}

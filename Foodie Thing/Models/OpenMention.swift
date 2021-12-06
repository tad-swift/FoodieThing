//
//  OpenMention.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/5/20.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

extension UIViewController {
    func openMention(name: String) {
        db.collection("users").whereField("username", isEqualTo: name).getDocuments() { (querySnapshot, err) in
            if let err = err {
                log.debug("Error getting documents: \(err as NSObject)")
            } else {
                for document in querySnapshot!.documents {
                    let docRef = db.collection("users").document(document.documentID)
                    docRef.getDocument { (document, _) in
                        let userObj = try! document?.data(as: User.self)!
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let profileVC = storyboard.instantiateViewController(withIdentifier: "otherProfileVC") as! OtherProfileViewController
                        profileVC.user = userObj
                        self.present(profileVC, animated: true)
                        
                    }
                }
            }
        }
    }
}

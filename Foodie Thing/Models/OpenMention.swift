//
//  OpenMention.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/5/20.
//

import UIKit
import Firebase

extension UIViewController {
    func openMention(name: String) {
        let db = Firestore.firestore()
        db.collection("users").whereField("username", isEqualTo: name).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let docRef = db.collection("users").document(document.documentID)
                    docRef.getDocument { (document, _) in
                        if let userObj = document.flatMap({
                            $0.data().flatMap({ (data) in
                                return User(dictionary: data)
                            })
                        }) {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let profileVC = storyboard.instantiateViewController(withIdentifier: "otherProfileVC") as! OtherProfileViewController
                            profileVC.user = userObj
                            self.present(profileVC, animated: true)
                        } else {
                            print("Document does not exist")
                        }
                        
                    }
                }
            }
        }
    }
}
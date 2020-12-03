//
//  AddUsers.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 12/3/20.
//

import UIKit
import FirebaseAuth

extension UIViewController {
    /**
     Grabs all the users from the Firestore database and puts them in an array of type `User`
     - Parameter list: Pointer to the array you'll be working with
     */
    func addUsers(to list: UnsafeMutablePointer<[User]>) {
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
                            list.pointee.append(userData)
                        } else {
                            log.debug("Document does not exist")
                        }
                    }
                }
            }
        }
    }
    
    /// Grabs the current user's data and assigns it to the `myUser` object.
    func getUser() {
        let userDocID = Auth.auth().currentUser!.uid
        let docRef = db.collection("users").document(userDocID)
        docRef.getDocument { (document, _) in
            if let userObj = document.flatMap({
                $0.data().flatMap({ (data) in
                    return User(dictionary: data)
                })
            }) {
                myUser = userObj
            } else {
                log.debug("Document does not exist")
            }
        }
    }
}

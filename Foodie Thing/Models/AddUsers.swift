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
                    let userData = try! document.data(as: User.self)!
                    list.pointee.append(userData)
                }
            }
        }
    }
    
    /// Grabs the current user's data and assigns it to the `myUser` object.
    func updateMyUser() {
        let userDocID = Auth.auth().currentUser!.uid
        let docRef = db.collection("users").document(userDocID)
        docRef.getDocument { (document, _) in
            myUser = try! document?.data(as: User.self)!
        }
    }
    
    func getUserById(id: String, _ completion: @escaping (User) -> ()) {
        let docRef = db.collection("users").document(id)
        docRef.getDocument { (document, _) in
            let userObj = try! document!.data(as: User.self)!
            completion(userObj)
        }
    }
}

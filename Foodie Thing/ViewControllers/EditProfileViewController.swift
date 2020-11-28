//
//  EditProfileViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/19/20.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


final class EditProfileViewController: UITableViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var bioField: UITextField!
    
    var userData: User! {
        didSet {
            setupViews()
        }
    }
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUser()
        getUsers()
    }
    
    func setupViews() {
        nameField.text = userData.name
        usernameField.text = userData.username
        bioField.text = userData.bio
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
                            self.users.append(userData)
                        } else {
                            log.debug("Document does not exist")
                        }
                    }
                }
            }
        }
    }
    
    func getUser() {
        let userDocID = Auth.auth().currentUser!.uid
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                log.debug("Error getting documents: \(err as NSObject)")
            } else {
                let docRef = db.collection("users").document(userDocID)
                docRef.getDocument { (document, _) in
                    if let userObj = document.flatMap({
                        $0.data().flatMap({ (data) in
                            return User(dictionary: data)
                        })
                    }) {
                        self.userData = userObj
                    } else {
                        log.debug("Document does not exist")
                    }
                }
            }
        }
    }
    
    func changeUsername(to username: String) {
        for user in users {
            if nameField.text!.lowercased() == user.username?.lowercased() {
                newAlert(title: "Error changing name", body: "That username is already in use")
            } else {
                db.collection("users").document(userData.docID!).setData(["username": username, "previousNames": [userData.username]], merge: true)
            }
        }
    }
    
    func changeName(to name: String) {
        db.collection("users").document(userData.docID!).setData(["name": name, "previousNames": [userData.username]], merge: true)
    }
    
    func changeBio(to bio: String) {
        db.collection("users").document(userData.docID!).setData(["bio": bio], merge: true)
    }

    @IBAction func saveTapped(_ sender: Any) {
        if (usernameField.text!.count < 3 || usernameField.text!.count > 20) || (nameField.text!.count < 2 || nameField.text!.count > 20) {
            newAlert(title: "Error Changing name", body: "Your username and name must have more than 2 characters and must NOT be more than 20 characters")
        } else {
            changeUsername(to: usernameField.text!)
            changeName(to: nameField.text!)
            changeBio(to: bioField.text!)
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name("reloadProfile"), object: nil)
            })
        }
        
        
    }

}

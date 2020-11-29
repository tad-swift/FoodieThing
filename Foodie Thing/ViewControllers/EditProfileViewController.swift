//
//  EditProfileViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/19/20.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


final class EditProfileViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var bioField: UITextView!

    var placeholderLabel : UILabel!
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
        placeholderLabel = UILabel()
        placeholderLabel.text = "Bio"
        placeholderLabel.font = UIFont.systemFont(ofSize: 17)
        placeholderLabel.sizeToFit()
        bioField.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (bioField.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        bioField.text = userData.bio
        placeholderLabel.isHidden = !bioField.text.isEmpty
        bioField.isScrollEnabled = false
        bioField.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // update cell height
        placeholderLabel.isHidden = !bioField.text.isEmpty
        tableView.beginUpdates()
        tableView.endUpdates()
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 60))
        let label = UILabel()
        if section == 0 {
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width, height: headerView.frame.height)
            label.text = "Name"
        }
        if section == 1 {
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width, height: headerView.frame.height - 30)
            label.text = "Username"
        }
        if section == 2 {
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width - 30, height: headerView.frame.height - 30)
            label.text = "Bio"
        }
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        label.textColor = UIColor.label
        headerView.addSubview(label)

        return headerView
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        if (usernameField.text!.count < 3 || usernameField.text!.count > 20) || (nameField.text!.count < 2 || nameField.text!.count > 12) {
            newAlert(title: "Error Changing name", body: "Your username and name must have more than 2 characters and must NOT be more than 12 characters")
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

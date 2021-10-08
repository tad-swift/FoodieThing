//
//  EditProfileViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/19/20.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SPAlert


final class EditProfileViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var bioField: UITextView!

    var placeholderLabel : UILabel!
    var users = [User]()
    var usernames = [
        "foodiething","ft","foodything","foodiethings","jonahsachs","jonah"
    ]
    var initialName = ""
    var initialUsername = ""
    var initialBio = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMyUser()
        addUsers(to: &users)
        setupViews()
    }
    
    func setupViews() {
        nameField.text = myUser.name
        usernameField.text = myUser.username
        placeholderLabel = UILabel()
        placeholderLabel.text = "Bio"
        placeholderLabel.font = UIFont.systemFont(ofSize: 17)
        placeholderLabel.sizeToFit()
        bioField.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (bioField.font?.pointSize)! / 2)
        placeholderLabel.textColor = .placeholderText
        bioField.text = myUser.bio
        placeholderLabel.isHidden = bioField.text.isNotEmpty
        bioField.isScrollEnabled = false
        bioField.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.beginUpdates()
        tableView.endUpdates()
        
        initialName = myUser.name
        initialUsername = myUser.username
        initialBio = myUser.bio
    }
    
    /**
     Determines if any of the textFields were changed from their original string
     - Parameter text: The initial string of the textField
     - Parameter textFieldText: The current string of the textField
     - Returns: A bool stating wether the text was changed. True for changed, false for not changed
     */
    func didFieldChange(_ text: String, _ textFieldText: String) -> Bool {
        return text != textFieldText
    }
    
    /// Adds a placeholder in the UITextView. Also changes the height of the UITextView.
    func textViewDidChange(_ textView: UITextView) {
        // update cell height
        placeholderLabel.isHidden = bioField.text.isNotEmpty
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func addUsernames() {
        usernames = [
            "foodiething","ft","foodything","foodiethings"
        ]
        for user in users {
            usernames.append(user.username)
        }
    }
    
    func changeUsername(to username: String) {
        if didFieldChange(initialUsername, usernameField.text!) {
            if validateUsername(name: usernameField.text!) {
                addUsernames()
                for user in usernames {
                    if usernameField.text!.lowercased() == user.lowercased() {
                        newAlert(title: "Error changing name", body: "That username is already in use")
                        break
                    } else {
                        if myUser.previousNames == nil {
                            myUser.previousNames = [String]()
                        }
                        myUser.previousNames.append(usernameField.text!)
                        db.collection("users").document(myUser.docID).setData(["username": username, "previousNames": myUser.previousNames], merge: true)
                    }
                }
            } else {
                newAlert(title: "Error changing username", body: "Please enter a valid username")
            }
        }
    }
    
    func changeName(to name: String) {
        if didFieldChange(initialName, nameField.text!) {
            db.collection("users").document(myUser.docID).setData(["name": name], merge: true)
        }
    }
    
    func changeBio(to bio: String) {
        if didFieldChange(initialBio, bioField.text) {
            db.collection("users").document(myUser.docID).setData(["bio": bio], merge: true)
        }
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
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = UIColor.label
        headerView.addSubview(label)
        return headerView
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        if (usernameField.text!.count < 3 || usernameField.text!.count > 28) || (nameField.text!.count < 2 || nameField.text!.count > 30) {
            newAlert(title: "Error Changing name", body: "Your username and name must have more than 2 characters and must NOT be more than 28 characters")
        } else {
            if usernameField.text?.lowercased() == myUser.username.lowercased() {
                changeName(to: nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines))
                changeBio(to: bioField.text!)
            } else {
                changeUsername(to: usernameField.text!)
                changeName(to: nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines))
                changeBio(to: bioField.text!)
            }
            NotificationCenter.default.post(name: Notification.Name("reloadProfile"), object: nil)
            SPAlert.present(title: "Saved", preset: .done)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
}

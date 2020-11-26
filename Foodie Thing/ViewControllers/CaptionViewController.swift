//
//  CaptionViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/8/20.
//

import UIKit
import SPAlert
import FirebaseFirestore
import FirebaseStorage

class CaptionViewController: UIViewController {
    
    @IBOutlet weak var captionField: HoshiTextField!
    
    var db: Firestore!
    var post: [String: Any]!
    var userDocID: String!
    var postDocID: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Caption"
    }
    
    func uploadPost() {
        db = Firestore.firestore()
        post["caption"] = captionField.text
        self.dismiss(animated: true, completion: { [self] in
            self.db.collection("posts").document(postDocID).setData(post)
            self.db.collection("users").document(userDocID).collection("posts").document(postDocID).setData(post) { err in
                if let err = err {
                    SPAlert.present(title: "Error Posting", message: "\(err)", preset: .error)
                } else {
                    SPAlert.present(title: "Done", preset: .done)
                    NotificationCenter.default.post(name: Notification.Name("refreshPosts"), object: nil)
                }
            }
        })
    }

    @IBAction func cancelTapped(_ sender: Any) {
        let userDocID = post["userDocID"]!
        let storageRef = post["storageRef"]!
        self.dismiss(animated: true, completion: {
            if self.post["isVideo"]! as! Bool == true {
                Storage.storage().reference().child("\(userDocID)\(storageRef).mov").delete()
                Storage.storage().reference().child("\(userDocID)\(storageRef).jpg").delete()
            } else {
                Storage.storage().reference().child("\(userDocID)\(storageRef).jpg").delete()
            }
        })
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        uploadPost()
    }
    
}

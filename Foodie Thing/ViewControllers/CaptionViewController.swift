//
//  CaptionViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/8/20.
//

import UIKit
import SPAlert
import FirebaseStorage

final class CaptionViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var captionField: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        captionField.layer.cornerRadius = 8
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func uploadPost() {
        if captionField.text.isNotEmpty {
            tempPost["caption"] = captionField.text
        }
        db.collection("users").document(myUser.docID!).collection("posts").document(tempPost["docID"] as! String).setData(tempPost) { err in
            if let err = err {
                SPAlert.present(title: "Error Posting", message: "\(err)", preset: .error)
            } else {
                SPAlert.present(title: "Done", preset: .done)
                NotificationCenter.default.post(name: Notification.Name("refreshPosts"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }
            tempPost = nil
        }
        
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            tempPost = nil
        })
        
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        uploadPost()
    }
    
}

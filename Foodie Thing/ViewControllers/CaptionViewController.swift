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

final class CaptionViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var captionField: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        captionField.layer.cornerRadius = 8
        captionField.delegate = self
    }

    func uploadPost() {
        if let text = captionField.text {
            tempPost?.caption = text
        }
        try! Firestore.firestore().collection("posts")
            .document(tempPost!.docID).setData(from: tempPost!) { err in
            tempPost = nil
            if let err = err {
                SPAlert.present(title: "Error Posting", message: "\(err)", preset: .error)
            } else {
                SPAlert.present(title: "Done", preset: .done)
                NotificationCenter.default.post(name: Notification.Name("refreshPosts"), object: nil)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func cancelTapped(_ sender: Any) {
        tempPost = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        uploadPost()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
}

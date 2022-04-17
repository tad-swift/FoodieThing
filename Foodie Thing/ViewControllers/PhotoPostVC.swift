//
//  PhotoPostViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 5/27/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import UIKit
import SwiftDate
import FirebaseFirestore

final class PhotoPostViewController: UIViewController {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: ActiveLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var usernameBg: UIView!

    var photo: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo(for: photo.userDocID)
        usernameBg.layer.cornerRadius = 8
        photoView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        captionLabel.text = photo.caption!
        dateLabel.text = formatDate(date: photo.dateCreated.dateValue())
        let processor = DownsamplingImageProcessor(size: (UIScreen.main.bounds.size))
        photoView.kf.setImage(
            with: URL(string: photo.imageurl!),
            placeholder: nil,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.3)),
                .cacheOriginalImage
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        usernameLabel.addGestureRecognizer(tap)
        #if targetEnvironment(macCatalyst)
        let menuButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = menuButton
        #endif
        if UIDevice.current.userInterfaceIdiom == .pad {
            let menuButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancelTapped))
            navigationItem.rightBarButtonItem = menuButton
        }
    }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTap() {
        openProfile(name: photo.userDocID)
    }
    
    func getUserInfo(for userID: String) {
        let docRef = Firestore.firestore().collection("users").document(userID)
        docRef.getDocument { (document, _) in
            let userObj = try! document!.data(as: User.self)!
            self.usernameLabel.text = "@\(userObj.username)"
            
        }
    }

}

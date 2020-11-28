//
//  PhotoPostViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 5/27/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import UIKit
import SwiftDate

final class PhotoPostViewController: UIViewController {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: ActiveLabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var photo: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo(for: photo.userDocID!)
        photoView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        captionLabel.text = photo.caption!
        dateLabel.text = formatDate(date: photo.dateCreated!.dateValue())
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
        let menuButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = menuButton
    }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTap() {
        openProfile(name: photo.userDocID!)
    }
    
    func getUserInfo(for userID: String) {
        let docRef = db.collection("users").document(userID)
        docRef.getDocument { (document, _) in
            if let userData = document.flatMap({
                $0.data().flatMap({ (data) in
                    return User(dictionary: data)
                })
            }) {
                self.usernameLabel.text = userData.username
            } else {
                log.debug("Document does not exist")
            }
        }
    }

}

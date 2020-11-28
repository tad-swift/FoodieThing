//
//  VideoPostViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 5/25/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import UIKit
import AVKit

final class VideoPostViewController: UIViewController {
    
    @IBOutlet weak var playerView: VersaPlayerView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: ActiveLabel!
    @IBOutlet weak var dateLabel: UILabel!

    var video: Post!
    var aspectRatio: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo(for: video.userDocID!)
        captionLabel.text = video.caption
        dateLabel.text = formatDate(date: video.dateCreated!.dateValue())
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: aspectRatio).isActive = true
        let item = VersaPlayerItem(url: URL(string: video.videourl!)!)
        playerView.set(item: item)
        playerView.player.play()
        playerView.autoplay = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        usernameLabel.addGestureRecognizer(tap)
        
        let menuButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = menuButton
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerView.player.currentItem, queue: .main) { [weak self] _ in
            self?.playerView.player?.seek(to: CMTime.zero)
            self?.playerView.player?.play()
        }
    }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTap() {
        openProfile(name: video.userDocID!)
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

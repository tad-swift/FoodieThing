//
//  PostCell.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 10/31/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import UIKit


class PostCell: UICollectionViewCell {
    static let reuseIdentifier = "post-cell-reuse-identifier"
    
    var image = UIImageView()
    var playImage = UIImageView()
    
    var post: Post! {
        didSet {
            if post.isVideo! {
                playImage.isHidden = false
            } else {
                playImage.isHidden = true
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
    
    func configure() {
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 8
        image.contentMode = .scaleAspectFill
        playImage.isHidden = true
        playImage.translatesAutoresizingMaskIntoConstraints = false
        playImage.contentMode = .scaleAspectFit
        playImage.image = UIImage(systemName: "play.fill")
        contentView.addSubview(image)
        contentView.addSubview(playImage)
        playImage.heightAnchor.constraint(equalToConstant: 30).isActive = true
        playImage.widthAnchor.constraint(equalToConstant: 30).isActive = true
        let inset = CGFloat(0)
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset)
            ])
    }

}

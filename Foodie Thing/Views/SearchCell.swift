//
//  SearchCollectionViewCell.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 5/25/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import UIKit

class SearchCell: UICollectionViewCell {
    
    static let reuseIdentifier = "search-cell-identifier"
    
    var imageView = UIImageView()
    var titleLabel = UILabel()
    
    var user: User!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
    
    func configure() {
        contentView.layer.cornerRadius = 8.0
        contentView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height / 2
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -20),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: 50)
            ])
    }
}


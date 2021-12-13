//
//  IconCell.swift
//  TC Icon Selector
//
//  Created by Tadreik Campbell on 1/22/21.
//

import UIKit


class ListIconCell: UICollectionViewCell {
    static let reuseIdentifier = "icon-cell-reuse-identifier"
    
    var image = UIImageView()
    var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    func configure() {
        image.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 14
        image.contentMode = .scaleAspectFill
        label.font = .rounded(ofSize: 20, weight: .medium)
        contentView.addSubview(image)
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            label.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 20),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            label.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            image.heightAnchor.constraint(equalToConstant: 60),
            image.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
}

extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
    }
}

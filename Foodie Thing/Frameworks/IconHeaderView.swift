//
//  IconHeaderView.swift
//  TC Icon Selector
//
//  Created by Tadreik Campbell on 1/22/21.
//

import UIKit

class IconHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "icon-header-reuse-identifier"
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    func configure() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.font = .rounded(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
}

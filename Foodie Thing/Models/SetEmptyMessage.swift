//
//  SetEmptyMessage.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/30/20.
//

import UIKit

extension UICollectionView {
    func setEmptyMessage(_ message: String, _ color: UIColor = UIColor.systemGray) {
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = color
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 20)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        let view = UIView()
        view.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.widthAnchor.constraint(equalToConstant: 300),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: self.bounds.height / 3)
        ])
        self.backgroundView = view
    }
    
    func isCollectionEmpty() -> Bool {
        let sectionCount = self.numberOfSections
        var itemsCount = 0
        for i in 0..<sectionCount {
            itemsCount += self.numberOfItems(inSection: i)
        }
        return itemsCount == 0
    }
}

//
//  ObjectCell.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/19/20.
//

import UIKit


final class ObjectCell: UICollectionViewCell {
    static let reuseIdentifier = "ObjectCell"
    
    @IBOutlet weak var objectImage: UIImageView!
    @IBOutlet weak var checkImage: UIImageView!
    
    var modelName = "" {
        didSet {
            objectImage.image = UIImage(named: modelName.capitalized)
        }
    }
    
}

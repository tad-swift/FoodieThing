//
//  FoodieButton.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 6/22/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import UIKit

@IBDesignable
class FoodieButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        layer.cornerRadius = frame.height / 2
        tintColor = UIColor(named: "FT Theme")
        refreshColor(color: UIColor.init(red: 255, green: 255, blue: 255, alpha: 1))
        titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
        clipsToBounds = true
    }
    
    func createImage(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), true, 0.0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        return image
    }
    
    func refreshColor(color: UIColor) {
        let image = createImage(color: color)
        setBackgroundImage(image, for: .normal)
        clipsToBounds = true
    }

}

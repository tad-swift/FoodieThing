//
//  TabBarController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/17/19.
//  Copyright © 2019 Tadreik Campbell. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var ARIsGone: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if Device.current == .iPadAir2 {
            ARIsGone = true
            viewControllers?.remove(at: 2)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)

        if !ARIsGone {
            tabBar.items?[0].image = UIImage(systemName: "play.circle.fill", withConfiguration: symbolConfig)
            tabBar.items?[1].image = UIImage(systemName: "photo.fill.on.rectangle.fill", withConfiguration: symbolConfig)
            tabBar.items?[2].image = UIImage(systemName: "arkit", withConfiguration: symbolConfig)
            tabBar.items?[3].image = UIImage(systemName: "magnifyingglass", withConfiguration: symbolConfig)
            tabBar.items?[4].image = UIImage(systemName: "person.fill", withConfiguration: symbolConfig)
            
            tabBar.items?[0].selectedImage = UIImage(systemName: "play.circle.fill", withConfiguration: symbolConfig)
            tabBar.items?[1].selectedImage = UIImage(systemName: "photo.fill.on.rectangle.fill", withConfiguration: symbolConfig)
            tabBar.items?[2].selectedImage = UIImage(systemName: "arkit", withConfiguration: symbolConfig)
            tabBar.items?[3].selectedImage = UIImage(systemName: "magnifyingglass", withConfiguration: symbolConfig)
            tabBar.items?[4].selectedImage = UIImage(systemName: "person.fill", withConfiguration: symbolConfig)
        } else {
            tabBar.items?[0].image = UIImage(systemName: "play.circle.fill", withConfiguration: symbolConfig)
            tabBar.items?[1].image = UIImage(systemName: "photo.fill.on.rectangle.fill", withConfiguration: symbolConfig)
            tabBar.items?[2].image = UIImage(systemName: "magnifyingglass", withConfiguration: symbolConfig)
            tabBar.items?[3].image = UIImage(systemName: "person.fill", withConfiguration: symbolConfig)
            
            tabBar.items?[0].selectedImage = UIImage(systemName: "play.circle.fill", withConfiguration: symbolConfig)
            tabBar.items?[1].selectedImage = UIImage(systemName: "photo.fill.on.rectangle.fill", withConfiguration: symbolConfig)
            tabBar.items?[2].selectedImage = UIImage(systemName: "magnifyingglass", withConfiguration: symbolConfig)
            tabBar.items?[3].selectedImage = UIImage(systemName: "person.fill", withConfiguration: symbolConfig)
        }
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let barItemView = item.value(forKey: "view") as? UIView else { return }

        let timeInterval: TimeInterval = 0.3
        let propertyAnimator = UIViewPropertyAnimator(duration: timeInterval, dampingRatio: 0.5) {
            barItemView.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
        }
        propertyAnimator.addAnimations({ barItemView.transform = .identity }, delayFactor: CGFloat(timeInterval))
        propertyAnimator.startAnimation()
    }
    
}

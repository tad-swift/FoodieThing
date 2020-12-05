//
//  TabBarController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/17/19.
//  Copyright © 2019 Tadreik Campbell. All rights reserved.
//

import UIKit
import TransitionableTab


final class TabBarController: UITabBarController {
    
    var ARIsGone: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        if Device.current == .iPadAir2 {
            ARIsGone = true
            viewControllers?.remove(at: 2)
        }
        #if targetEnvironment(macCatalyst)
        viewControllers?.remove(at: 2)
        ARIsGone = true
        #endif
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .medium)
        
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

extension TabBarController: TransitionableTab {
    
    func transitionDuration() -> CFTimeInterval {
        return 0.3
    }
    
    func transitionTimingFunction() -> CAMediaTimingFunction {
        return .easeInOut
    }
    
    func fromTransitionAnimation(layer: CALayer?, direction: Direction) -> CAAnimation {
        return DefineAnimation.fade(.from)
    }
    
    func toTransitionAnimation(layer: CALayer?, direction: Direction) -> CAAnimation {
        return DefineAnimation.fade(.to)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return animateTransition(tabBarController, shouldSelect: viewController)
    }
}

//
//  SettingsViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 6/30/19.
//  Copyright © 2019 Tadreik Campbell. All rights reserved.

import UIKit
import TC_Icon_Selector


final class IconPickerViewController: ListSelector {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        icons = [
            Icon(name: "Current", image: "1 Classic"),
            Icon(name: "Mango", image: "2 Mango"),
            Icon(name: "Tropics", image: "3 Tropics"),
            Icon(name: "Plum", image: "4 Purple"),
            Icon(name: "Coral", image: "5 Coral"),
            Icon(name: "Berry", image: "6 Berry"),
            Icon(name: "Deep", image: "7 Deep"),
            Icon(name: "Charcoal", image: "8 Gray"),
            Icon(name: "Classic Pink", image: "9 Classic Pink"),
            Icon(name: "Lights Out", image: "10 Lights Out")
        ]
        complete()
    }
}

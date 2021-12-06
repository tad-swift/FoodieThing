//
//  SettingsViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 6/30/19.
//  Copyright © 2019 Tadreik Campbell. All rights reserved.

import UIKit


final class IconPickerViewController: ListSelector {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        icons = [
            Icon(name: "Berry Sunset", image: "Berry Sunset"),
            Icon(name: "Canopy", image: "Canopy"),
            Icon(name: "FT Classic", image: "FT Classic"),
            Icon(name: "FT Legacy", image: "FT Legacy"),
            Icon(name: "FT Modern", image: "FT Modern"),
            Icon(name: "Hawaii", image: "Hawaii"),
            Icon(name: "Maize", image: "Maize"),
            Icon(name: "Mango", image: "Mango"),
            Icon(name: "Night", image: "Night"),
            Icon(name: "Peach Berry", image: "Peach Berry"),
            Icon(name: "Pride", image: "Pride"),
            Icon(name: "Smoothie", image: "Smoothie"),
            Icon(name: "Volcano", image: "Volcano"),
            Icon(name: "Western Desert", image: "Western Desert")
        ]
    }
}

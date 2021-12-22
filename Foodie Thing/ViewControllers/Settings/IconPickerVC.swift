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
        sections = ["Alternate Icons", "Neon Series"]
        icons = [
            Icon(name: "Berry Sunset", image: "Berry Sunset", section: sections[0]),
            Icon(name: "Canopy", image: "Canopy", section: sections[0]),
            Icon(name: "FT Classic", image: "FT Classic", section: sections[0]),
            Icon(name: "FT Legacy", image: "FT Legacy", section: sections[0]),
            Icon(name: "FT Modern", image: "FT Modern", section: sections[0]),
            Icon(name: "Hawaii", image: "Hawaii", section: sections[0]),
            Icon(name: "Maize", image: "Maize", section: sections[0]),
            Icon(name: "Mango", image: "Mango", section: sections[0]),
            Icon(name: "Night", image: "Night", section: sections[0]),
            Icon(name: "Peach Berry", image: "Peach Berry", section: sections[0]),
            Icon(name: "Pride", image: "Pride", section: sections[0]),
            Icon(name: "Smoothie", image: "Smoothie", section: sections[0]),
            Icon(name: "Volcano", image: "Volcano", section: sections[0]),
            Icon(name: "Western Desert", image: "Western Desert", section: sections[0])
        ]
    }
}

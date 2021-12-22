//
//  Icon.swift
//  TC Icon Selector
//
//  Created by Tadreik Campbell on 1/22/21.
//

import Foundation

public struct Icon: Hashable {
    let name: String
    let image: String
    let section: String
    let id = UUID()
    
    public init(name: String, image: String, section: String = "Alternate Icons") {
        self.name = name
        self.image = image
        self.section = section
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

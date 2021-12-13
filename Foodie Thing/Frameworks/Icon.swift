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
    let id = UUID()
    
    public init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

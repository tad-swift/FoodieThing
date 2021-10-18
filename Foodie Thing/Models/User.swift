//
//  User.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 5/20/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//


import Foundation
import FirebaseFirestore

struct User: Hashable, Codable {

    var following: [String]
    var profilePic: String
    var coverPhoto: String
    var username: String
    var name: String
    var email: String
    var bio: String
    var docID: String
    var dateCreated: Timestamp
    var previousNames: [String]?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(docID)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.docID == rhs.docID
    }
    
    func contains(_ filter: String?) -> Bool {
        guard let filterText = filter else { return true }
        if filterText.isEmpty { return true }
        let lowercasedFilter = filterText.lowercased()
        return username.lowercased().contains(lowercasedFilter)
    }
    
}

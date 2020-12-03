//
//  User.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 5/20/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//


import Foundation
import FirebaseFirestore

struct User: Hashable {

    var following: [String]?
    var profilePic: String?
    var coverPhoto: String?
    var username: String?
    var name: String?
    var email: String?
    var bio: String?
    var docID: String?
    var dateCreated: Timestamp?
    var previousNames: [String]?
    let identifier = UUID()

    init?(dictionary: [String: Any]) {
        self.following = dictionary["following"] as? [String]
        self.username = dictionary["username"] as? String
        self.name = dictionary["name"] as? String
        self.profilePic = dictionary["profilePic"] as? String
        self.coverPhoto = dictionary["coverPhoto"] as? String
        self.email = dictionary["email"] as? String
        self.bio = dictionary["bio"] as? String
        self.docID = dictionary["docID"] as? String
        self.dateCreated = dictionary["dateCreated"] as? Timestamp
        self.previousNames = dictionary["previousNames"] as? [String]
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    func contains(_ filter: String?) -> Bool {
        guard let filterText = filter else { return true }
        if filterText.isEmpty { return true }
        let lowercasedFilter = filterText.lowercased()
        return username!.lowercased().contains(lowercasedFilter)
    }
    
}

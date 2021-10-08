//
//  Post.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 10/31/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Post: Hashable, Codable {
    
    let videourl: String?
    let imageurl: String?
    var tags: [String]?
    let dateCreated: Timestamp
    let docID: String
    var caption: String?
    let userDocID: String
    let isVideo: Bool
    let storageRef: String
    let views: Int
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(docID)
    }

    static func == (lhs: Post, rhs: Post) -> Bool {
      lhs.docID == rhs.docID
    }
}

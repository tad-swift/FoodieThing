//
//  Post.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 10/31/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Post: Hashable {
    
    let videourl: String?
    let imageurl: String?
    let tags: [String]?
    let dateCreated: Timestamp?
    let docID: String?
    let caption: String?
    let userDocID: String?
    let isVideo: Bool?
    let storageRef: String?
    let identifier = UUID()

    init?(dictionary: [String: Any]) {
        self.videourl = dictionary["videourl"] as? String
        self.imageurl = dictionary["imageurl"] as? String
        self.tags = dictionary["tags"] as? [String]
        self.dateCreated = dictionary["dateCreated"] as? Timestamp
        self.docID = dictionary["docID"] as? String
        self.caption = dictionary["caption"] as? String
        self.userDocID = dictionary["userDocID"] as? String
        self.isVideo = dictionary["isVideo"] as? Bool
        self.storageRef = dictionary["storageRef"] as? String
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(identifier)
    }

    static func == (lhs: Post, rhs: Post) -> Bool {
      lhs.identifier == rhs.identifier
    }
}

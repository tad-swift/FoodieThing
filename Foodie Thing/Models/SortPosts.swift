//
//  SortPosts.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/30/20.
//

import UIKit

extension UIViewController {
    /**
     Sorts posts in reverse chronological order. Most recent post as first element.
     - Parameter postList: Pointer to the input array
     */
    func sortPosts(_ postList: inout [Post]) {
        postList.sort { (lhs: Post, rhs: Post) -> Bool in
            return lhs.dateCreated.dateValue() > rhs.dateCreated.dateValue()
        }
    }
}

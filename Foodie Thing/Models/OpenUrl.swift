//
//  OpenUrl.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 12/4/19.
//  Copyright © 2019 Tadreik Campbell. All rights reserved.
//

import UIKit

extension UIViewController {
    func openUrl(isInsta: Bool = false, link: String = "", username: String = "") {
        if isInsta {
            if (UIApplication.shared.canOpenURL(NSURL(string: "instagram://user?username=\(username)")! as URL)) {
                UIApplication.shared.open(NSURL(string: "instagram://user?username=\(username)")! as URL, options: [:], completionHandler: nil)
            } else {
                //redirect to safari because the user doesn't have Instagram
                UIApplication.shared.open(NSURL(string: "https://instagram.com/\(username )")! as URL, options: [:], completionHandler: nil)
            }
        } else {
            UIApplication.shared.open(NSURL(string: link)! as URL, options: [:], completionHandler: nil)
        }
    }
}

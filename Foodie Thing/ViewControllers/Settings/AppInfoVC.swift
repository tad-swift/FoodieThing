//
//  InfoViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 7/12/19.
//  Copyright © 2019 Tadreik Campbell. All rights reserved.
//

import UIKit
import SafariServices

final class AppInfoViewController: UIViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var jonahInsta: UIImageView!
    @IBOutlet weak var memojiStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let infoDictionary = Bundle.main.infoDictionary
        let version = infoDictionary?["CFBundleShortVersionString"] as? String
        //let build = infoDictionary?["CFBundleVersion"] as? String
        versionLabel.text = "Foodie Thing App v. \(version ?? "")"
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        //let tap2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        jonahInsta.addGestureRecognizer(tap1)
    }
    
    @objc func imageTapped(tap: UITapGestureRecognizer){
        switch tap.view?.tag {
        case 1:
            // Jonah Instagram
            openUrl(isInsta: true, username: "jonahsachs")
        case 2:
            openUrl(isInsta: true, username: "tadreik")
        default:
            break
        }
        
        if pref.bool(forKey: "SwitchState") == true {
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
    }
    
}

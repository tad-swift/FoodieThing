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
    @IBOutlet weak var melImage: UIImageView!
    @IBOutlet weak var minimalismImage: UIImageView!
    @IBOutlet weak var gmaImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let infoDictionary = Bundle.main.infoDictionary
        let version = infoDictionary?["CFBundleShortVersionString"] as? String
        //let build = infoDictionary?["CFBundleVersion"] as? String
        versionLabel.text = "Foodie Thing App v. \(version ?? "")"
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        //let tap2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        
        jonahInsta.addGestureRecognizer(tap1)
        melImage.addGestureRecognizer(tap4)
        gmaImage.addGestureRecognizer(tap2)
        minimalismImage.addGestureRecognizer(tap3)
    }
    
    @objc func imageTapped(tap: UITapGestureRecognizer){
        _ = tap.view as! UIImageView
        switch tap.view?.tag {
        case 1:
            // Jonah Instagram
            openUrl(isInsta: true, username: "jonahsachs")
        case 2:
            // GMA sticker pack
            openUrl(link: "https://apps.apple.com/us/app/the-wonderful-gma-sticker-pack/id1489932513")
        case 3:
            // Minimalism sticker pack
            openUrl(link: "https://apps.apple.com/us/app/minimalism-sticker-pack/id1484802507")
        case 4:
            // Mel sticker pack
            openUrl(link: "https://apps.apple.com/us/app/the-day-of-mel-sticker-pack/id1484979071")
        default:
            break
        }
        
        if pref.bool(forKey: "SwitchState") == true {
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
    }
    
}

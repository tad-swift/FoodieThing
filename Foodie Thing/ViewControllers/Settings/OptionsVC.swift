//
//  OptionsTableViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 8/15/19.
//  Copyright © 2019 Tadreik Campbell. All rights reserved.
//

import UIKit
import SafariServices
import FirebaseAuth

final class OptionsViewController: UITableViewController {
    
    @IBOutlet weak var websiteCell: UITableViewCell!
    @IBOutlet weak var hapticSwitch: UISwitch!
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hapticSwitch.setOn(pref.bool(forKey: "SwitchState"), animated: false)
        let indexPath = IndexPath(item: 1, section: 1)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 60))
        let label = UILabel()
        if section == 0 {
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width, height: headerView.frame.height)
            label.text = "Profile"
        }
        if section == 1 {
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width, height: headerView.frame.height - 30)
            label.text = "Look and Feel"
        }
        if section == 2 {
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width - 30, height: headerView.frame.height - 30)
            label.text = "Share Options"
        }
        if section == 3 {
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width - 30, height: headerView.frame.height - 30)
            label.text = "More"
        }
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = UIColor.label
        headerView.addSubview(label)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let shareText = "https://apps.apple.com/us/app/foodie-thing/id1471725282"
        let shareUrl = NSURL(string: shareText)
        
        if indexPath.section == 2 && indexPath.row == 0 {
            let ac = UIActivityViewController(activityItems: [shareUrl!], applicationActivities: nil)
            let popover = ac.popoverPresentationController
            popover?.sourceView = view
            popover?.sourceRect = CGRect(x: 120, y: 150, width: 64, height: 64)
            present(ac, animated: true)
        }

        if indexPath.section == 3 && indexPath.row == 0 {
            openUrl(isInsta: true, username: "foodiething")
        }
        if indexPath.section == 3 && indexPath.row == 2 {
            openUrl(link: "https://tadreik.com/ftprivacy")
        }
        if indexPath.section == 4 && indexPath.row == 0 {
            var shouldSignOut = true
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                log.debug("Error signing out: \(signOutError)")
                shouldSignOut = false
            }
            if shouldSignOut {
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let loginController = storyboard.instantiateViewController(identifier: "loginVC")
                (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(loginController)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = super.tableView(tableView, numberOfRowsInSection: section)
        if section == 1 && UIDevice.current.userInterfaceIdiom == .pad {
            return count - 1
        }
        return count
    }
    
    @IBAction func valueChanged(sender: UISwitch) {
        if sender.isOn {
            pref.set(true, forKey: "SwitchState")
        } else {
            pref.set(false, forKey: "SwitchState")
        }
    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

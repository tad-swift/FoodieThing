//
//  SwitchCell.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/26/19.
//  Copyright © 2019 Tadreik Campbell. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {
    
    let defaults = UserDefaults.standard

    override func awakeFromNib() {
        super.awakeFromNib()
        let switchView = UISwitch(frame: .zero)
        switchView.onTintColor = UIColor(named: "FT Theme")
        switchView.setOn(defaults.bool(forKey: "SwitchState"), animated: false)
        switchView.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        accessoryView = switchView
        imageView?.image = UIImage(named: "HapticSymbol")
    }
    
    @objc func valueChanged(sender: UISwitch) {
        
        if sender.isOn {
            defaults.set(true, forKey: "SwitchState")
        } else {
            defaults.set(false, forKey: "SwitchState")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

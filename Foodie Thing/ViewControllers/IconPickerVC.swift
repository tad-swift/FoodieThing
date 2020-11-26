//
//  SettingsViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 6/30/19.
//  Copyright © 2019 Tadreik Campbell. All rights reserved.

import UIKit

class IconPickerViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var one: UIImageView!
    @IBOutlet weak var two: UIImageView!
    @IBOutlet weak var three: UIImageView!
    @IBOutlet weak var four: UIImageView!
    @IBOutlet weak var five: UIImageView!
    @IBOutlet weak var six: UIImageView!
    @IBOutlet weak var seven: UIImageView!
    @IBOutlet weak var eight: UIImageView!
    @IBOutlet weak var nine: UIImageView!

    @IBOutlet weak var ten: UIImageView!
    @IBOutlet weak var eleven: UIImageView!
    @IBOutlet weak var twelve: UIImageView!
    @IBOutlet weak var thirteen: UIImageView!
    @IBOutlet weak var fourteen: UIImageView!
    @IBOutlet weak var fifteen: UIImageView!
    @IBOutlet weak var sixteen: UIImageView!
    @IBOutlet weak var seventeen: UIImageView!
    @IBOutlet weak var eighteen: UIImageView!

    @IBOutlet weak var nineteen: UIImageView!
    @IBOutlet weak var twenty: UIImageView!
    @IBOutlet weak var twentyone: UIImageView!
    @IBOutlet weak var twentytwo: UIImageView!
    @IBOutlet weak var twentythree: UIImageView!
    @IBOutlet weak var twentyfour: UIImageView!
    @IBOutlet weak var twentyfive: UIImageView!
    @IBOutlet weak var twentysix: UIImageView!
    @IBOutlet weak var twentyseven: UIImageView!

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var vertStackOne: UIStackView!
    @IBOutlet weak var horStackOne1: UIStackView!
    @IBOutlet weak var horStackOne2: UIStackView!
    @IBOutlet weak var horStackOne3: UIStackView!

    @IBOutlet weak var vertStackTwo: UIStackView!
    @IBOutlet weak var horStackTwo1: UIStackView!
    @IBOutlet weak var horStackTwo2: UIStackView!
    @IBOutlet weak var horStackTwo3: UIStackView!
    @IBOutlet weak var vertStackThree: UIStackView!
    @IBOutlet weak var horStackThree1: UIStackView!
    @IBOutlet weak var horStackThree2: UIStackView!
    
    let selection = UISelectionFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()

        vertStackOne.spacing = 16
        vertStackTwo.spacing = 16
        vertStackThree.spacing = 16

        horStackOne1.spacing = 16
        horStackOne2.spacing = 16
        horStackOne3.spacing = 16
        horStackTwo1.spacing = 16
        horStackTwo2.spacing = 16
        horStackTwo3.spacing = 16
        horStackThree1.spacing = 16
        horStackThree2.spacing = 16
        
        let iconsList = [one,two,three,four,five,six,seven,eight,nine,ten,eleven,twelve,
                         thirteen,fourteen,fifteen,sixteen,seventeen,eighteen,nineteen,twenty,
                         twentyone,twentytwo,twentythree,twentyfour]
        
        for icon in iconsList {
            icon?.layer.cornerRadius = 20
        }

        let tap1 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap6 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap7 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap8 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap9 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap10 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap11 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap12 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap13 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap14 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap15 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap16 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap17 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap18 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap19 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap20 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap21 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap22 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap23 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))
        let tap24 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tap:)))

        one.addGestureRecognizer(tap1)
        two.addGestureRecognizer(tap2)
        three.addGestureRecognizer(tap3)
        four.addGestureRecognizer(tap4)
        five.addGestureRecognizer(tap5)
        six.addGestureRecognizer(tap6)
        seven.addGestureRecognizer(tap7)
        eight.addGestureRecognizer(tap8)
        nine.addGestureRecognizer(tap9)
        ten.addGestureRecognizer(tap10)
        eleven.addGestureRecognizer(tap11)
        twelve.addGestureRecognizer(tap12)
        thirteen.addGestureRecognizer(tap13)
        fourteen.addGestureRecognizer(tap14)
        fifteen.addGestureRecognizer(tap15)
        sixteen.addGestureRecognizer(tap16)
        seventeen.addGestureRecognizer(tap17)
        eighteen.addGestureRecognizer(tap18)
        nineteen.addGestureRecognizer(tap19)
        twenty.addGestureRecognizer(tap20)
        twentyone.addGestureRecognizer(tap21)
        twentytwo.addGestureRecognizer(tap22)
        twentythree.addGestureRecognizer(tap23)
        twentyfour.addGestureRecognizer(tap24)
        
        one.tag = 1
        two.tag = 2
        three.tag = 3
        four.tag = 4
        five.tag = 5
        six.tag = 6
        seven.tag = 7
        eight.tag = 8
        nine.tag = 9
        ten.tag = 10
        eleven.tag = 11
        twelve.tag = 12
        thirteen.tag = 13
        fourteen.tag = 14
        fifteen.tag = 15
        sixteen.tag = 16
        seventeen.tag = 17
        eighteen.tag = 18
        nineteen.tag = 19
        twenty.tag = 20
        twentyone.tag = 21
        twentytwo.tag = 22
        twentythree.tag = 23
        twentyfour.tag = 24

    }

    @objc func imageTapped(tap: UITapGestureRecognizer){
        
        if defaults.bool(forKey: "SwitchState") == true {
            selection.selectionChanged()
        }
        
        switch tap.view?.tag {
        case 1: changeIcon(to: "1")
        case 2: changeIcon(to: "2")
        case 3: changeIcon(to: "3")
        case 4: changeIcon(to: "5")
        case 5: changeIcon(to: "4")
        case 6: changeIcon(to: "6")
        case 7: changeIcon(to: "7")
        case 8: changeIcon(to: "8")
        case 9: changeIcon(to: "9")
        case 10: changeIcon(to: "17")
        case 11: changeIcon(to: "10")
        case 12: changeIcon(to: "16")
        case 13: changeIcon(to: "11")
        case 14: changeIcon(to: "12")
        case 15: changeIcon(to: "13")
        case 16: changeIcon(to: "18")
        case 17: changeIcon(to: "15")
        case 18: changeIcon(to: "14")
        case 19: changeIcon(to: "19")
        case 20: changeIcon(to: "20")
        case 21: changeIcon(to: "21")
        case 22: changeIcon(to: "24")
        case 23: changeIcon(to: "25")
        case 24: changeIcon(to: "26")
        default: changeIcon(to: "1")
        }
        
    }
    
    func changeIcon(to iconName: String) {
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }
        UIApplication.shared.setAlternateIconName(iconName, completionHandler: { (error) in
            if let error = error {
                print("App icon failed to change due to \(error.localizedDescription)")
            } else {
                print("App icon changed successfully")
            }
        })
    }
    
}

//
//  Validator+ViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 10/23/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import UIKit

extension UIViewController {
    func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func validateUsername(name: String) -> Bool {
        let nameRegEx = "[0-9a-zA-Z]{2,17}"
        let namePred = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return namePred.evaluate(with: name)
    }
}

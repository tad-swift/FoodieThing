//
//  NewAlert.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/2/20.
//

import UIKit

extension UIViewController {
    func newAlert(title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

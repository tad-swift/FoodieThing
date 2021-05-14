//
//  FTField.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 12/11/20.
//

import UIKit

final class FTField: UITextField {
    
    override func textRect(forBounds: CGRect) -> CGRect {
        return forBounds.insetBy(dx: 10, dy: 4)
    }
    override func editingRect(forBounds: CGRect) -> CGRect {
        return forBounds.insetBy(dx: 10 , dy: 4)
    }
    override func placeholderRect(forBounds: CGRect) -> CGRect {
        return forBounds.insetBy(dx: 10, dy: 4)
    }
}

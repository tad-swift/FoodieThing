//
//  FormatDate.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/5/20.
//

import UIKit
import SwiftDate

extension UIViewController {
    func formatDate(date: Date) -> String {
        let timestamp = DateInRegion(date, region: .current)
        let newDateStyle = timestamp.toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.english)
        return "\(newDateStyle)"
    }
}



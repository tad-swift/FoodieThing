//
//  GetVideoAspectRatio.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/5/20.
//

import UIKit
import AVKit

extension UIViewController {
    func getVideoResolution(url: String) -> CGFloat? {
        guard let track = AVURLAsset(url: URL(string: url)!).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return abs(size.height) / abs(size.width)
    }
}

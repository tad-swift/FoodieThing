//
//  FTStickerViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 12/9/19.
//  Copyright © 2019 Tadreik Campbell. All rights reserved.
//

import UIKit
import Messages

class FTStickerViewController: MSStickerBrowserViewController {
    
    var stickers = [MSSticker]()
    
    func changeBrowserViewBackgroundColor(color: UIColor) {
        stickerBrowserView.backgroundColor = color
    }
    
    func loadStickers() {
        createSticker("Apple with FT", "apple sticker")
        createSticker("Burger with FT", "burger sticker")
        createSticker("Cherries with FT", "cherries sticker")
        createSticker("Hotdog with FT", "hotdog sticker")
        createSticker("Ice Cream with FT", "ice cream sticker")
        createSticker("Food Please", "food please sticker")
        createSticker("iMessage Foodie Thing Stickers 7", "100k sticker")
        createSticker("iMessage Foodie Thing Stickers 4", "link in bio sticker")
        createSticker("Instagram Time", "instagram time sticker")
        createSticker("HBD", "happy birthday sticker")
        createSticker("iMessage Foodie Thing Stickers 5", "sticker 5")
        createSticker("iMessage Foodie Thing Stickers 3", "sticker 3")
        createSticker("iMessage Foodie Thing Stickers 6", "sticker 6")
        createSticker("heart1", "heart sticker")
        createSticker("iMessage Foodie Thing Stickers 2", "sticker 7")
        createSticker("Foodie Love", "Foodie Love sticker")
        createSticker("iMessage Foodie Thing Stickers", "sticker 8")
        createSticker("Day 1", "Day 1 sticker")
        createSticker("TBT", "TBT sticker")
        createSticker("OGs", "OGs sticker")
    }
    
    func createSticker(_ asset: String, _ localizedDescription: String) {
        guard let stickerPath = Bundle.main.path(forResource: asset, ofType: "png") else {
            return
        }
        let stickerURL = URL(fileURLWithPath: stickerPath)
        let sticker: MSSticker
        do {
            try sticker = MSSticker(contentsOfFileURL: stickerURL, localizedDescription: localizedDescription)
            stickers.append(sticker)
        } catch {
            return
        }
    }
    
    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        stickers.count
    }
    
    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        return stickers[index]
    }
}

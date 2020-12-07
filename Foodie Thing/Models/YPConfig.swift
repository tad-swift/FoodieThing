//
//  YPConfig.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 10/31/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import UIKit
import AVKit
import YPImagePicker

extension ProfileVC {
    
    enum YPConfigType: CaseIterable {
        case photo, video
    }
    
    func createYPConfig(type: YPConfigType) -> YPImagePickerConfiguration {
        var config = YPImagePickerConfiguration()
        switch type {
        case .photo:
            config.isScrollToChangeModesEnabled = true
            config.onlySquareImagesFromCamera = true
            config.usesFrontCamera = false
            config.showsPhotoFilters = false
            config.showsVideoTrimmer = false
            config.shouldSaveNewPicturesToAlbum = false
            config.albumName = "Foodie Thing Media"
            config.startOnScreen = YPPickerScreen.library
            config.screens = [.library, .photo]
            config.showsCrop = .rectangle(ratio: (1/1))
            config.targetImageSize = .cappedTo(size: 1024)
            config.overlayView = UIView()
            config.hidesStatusBar = false
            config.hidesBottomBar = false
            config.preferredStatusBarStyle = UIStatusBarStyle.default
            config.maxCameraZoomFactor = 1.0
            config.library.options = nil
            config.library.onlySquare = true
            config.library.isSquareByDefault = true
            config.library.minWidthForItem = nil
            config.library.mediaType = YPlibraryMediaType.photo
            config.library.defaultMultipleSelection = false
            config.library.maxNumberOfItems = 1
            config.library.minNumberOfItems = 1
            config.library.numberOfItemsInRow = 4
            config.library.spacingBetweenItems = 1.0
            config.library.skipSelectionsGallery = false
            config.library.preselectedItems = nil
            return config
        case .video:
            config.isScrollToChangeModesEnabled = true
            config.onlySquareImagesFromCamera = true
            config.usesFrontCamera = false
            config.showsPhotoFilters = false
            config.showsVideoTrimmer = true
            config.shouldSaveNewPicturesToAlbum = false
            config.albumName = "Foodie Thing Media"
            config.startOnScreen = YPPickerScreen.library
            config.screens = [.library, .video]
            config.showsCrop = .rectangle(ratio: (1/1))
            config.targetImageSize = .original
            config.overlayView = UIView()
            config.hidesStatusBar = false
            config.hidesBottomBar = false
            config.preferredStatusBarStyle = UIStatusBarStyle.default
            config.maxCameraZoomFactor = 1.0
            config.library.options = nil
            config.library.onlySquare = true
            config.library.isSquareByDefault = true
            config.library.minWidthForItem = nil
            config.library.mediaType = .video
            config.library.defaultMultipleSelection = false
            config.library.maxNumberOfItems = 1
            config.library.minNumberOfItems = 1
            config.library.numberOfItemsInRow = 4
            config.library.spacingBetweenItems = 1.0
            config.library.skipSelectionsGallery = false
            config.library.preselectedItems = nil
            config.video.compression = AVAssetExportPresetHEVC1920x1080
            config.video.fileType = .mov
            config.video.recordingTimeLimit = 120.0
            config.video.libraryTimeLimit = 120.0
            config.video.minimumTimeLimit = 2.0
            config.video.trimmerMaxDuration = 120.0
            config.video.trimmerMinDuration = 2.0
            return config
        }
    }
    
}

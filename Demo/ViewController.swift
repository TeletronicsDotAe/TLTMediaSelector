//
//  ViewController.swift
//  Demo
//
//  Created by Martin Rehder on 20.07.16.
//  Copyright © 2016 Martin Rehder. All rights reserved.
//

import UIKit
import RSKImageCropper

class ViewController: UIViewController, RSKImageCropViewControllerDataSource {
    let mediaSelector = MediaSelection()

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mediaSelector.didGetPhoto = {
            (photo: UIImage, info: [AnyHashable: Any]) -> Void in
            NSLog("did get photo")
            self.imageView.image = photo
        }

        mediaSelector.didGetVideo = {
            (video: URL, info: [AnyHashable: Any]) -> Void in
            NSLog("did get video")
        }
    }

    @IBAction func selectImage(_ sender: AnyObject) {
        mediaSelector.title = "Select Image"
        mediaSelector.subtitle = "Select your image among one of these sources"
        mediaSelector.allowsPhoto = true
        mediaSelector.allowsVideo = false
        mediaSelector.allowsMasking = true
        mediaSelector.customMaskDatasource = self
        mediaSelector.defaultsToFrontCamera = true
        mediaSelector.buttonBackgroundColor = UIColor.init(white: 0.8, alpha: 1.0)
        mediaSelector.closeButtonTextColor = .black
        mediaSelector.closeButtonBackgroundColor = .red
        // Required for the iPad
        mediaSelector.presentingView = sender as? UIView
        mediaSelector.present()
    }

    @IBAction func selectVideo(_ sender: AnyObject) {
        mediaSelector.title = "Select Video"
        mediaSelector.subtitle = "Select your video among one of these sources"
        mediaSelector.allowsPhoto = false
        mediaSelector.allowsVideo = true
        mediaSelector.allowsEditing = true
        mediaSelector.videoMaximumDuration = 10
        mediaSelector.defaultsToFrontCamera = true
        mediaSelector.buttonBackgroundColor = UIColor.init(white: 0.8, alpha: 1.0)
        // Required for the iPad
        mediaSelector.presentingView = sender as? UIView
        mediaSelector.present()
    }

    @IBAction func selectPhotoOrVideo(_ sender: AnyObject) {
        mediaSelector.title = "Select Image or Video"
        mediaSelector.subtitle = "Select among one of these sources"
        mediaSelector.allowsPhoto = true
        mediaSelector.allowsVideo = true
        mediaSelector.allowsVoiceRecording = true
        mediaSelector.allowsEditing = true
        mediaSelector.videoMaximumDuration = 10
        mediaSelector.voiceRecordingMaximumDuration = 10
        mediaSelector.defaultsToFrontCamera = true
        mediaSelector.buttonBackgroundColor = UIColor.init(white: 0.8, alpha: 1.0)
        // Required for the iPad
        mediaSelector.presentingView = sender as? UIView
        mediaSelector.present()
    }
    
    // MARK: - Masking demo
    
    func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {
        var maskSize = CGSize(width: 220, height: 220)
        if controller.isPortraitInterfaceOrientation() {
            maskSize = CGSize(width: 250, height: 250)
        }
        let viewWidth = controller.view.frame.width
        let viewHeight = controller.view.frame.height
        
        let maskRect = CGRect(x: (viewWidth - maskSize.width) * 0.5,
                              y: (viewHeight - maskSize.height) * 0.5,
                              width: maskSize.width,
                              height: maskSize.height)
        
        return maskRect
    }
    
    func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {
        let path = UIBezierPath.init(roundedRect: controller.maskRect, cornerRadius: 10)
        return path
    }
    
    func imageCropViewControllerCustomMovementRect(_ controller: RSKImageCropViewController) -> CGRect {
        return controller.maskRect
    }

}


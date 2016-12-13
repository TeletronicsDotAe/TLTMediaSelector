//
//  ViewController.swift
//  Demo
//
//  Created by Martin Rehder on 20.07.16.
//  Copyright © 2016 Martin Rehder. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let mediaSelector = MediaSelection()

    override func viewDidLoad() {
        super.viewDidLoad()

        mediaSelector.didGetPhoto = {
            (photo: UIImage, info: [AnyHashable: Any]) -> Void in
            NSLog("did get photo")
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
        mediaSelector.defaultsToFrontCamera = true
        mediaSelector.buttonBackgroundColor = UIColor.init(white: 0.8, alpha: 1.0)
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
    
}


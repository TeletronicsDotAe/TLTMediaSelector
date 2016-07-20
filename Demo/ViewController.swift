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
            (photo: UIImage, info: [NSObject : AnyObject]) -> Void in
            NSLog("did get photo")
        }
    }

    @IBAction func selectImage(sender: AnyObject) {
        mediaSelector.title = "Select Image"
        mediaSelector.subtitle = "Select your image among one of these sources"
        mediaSelector.allowsMasking = true
        mediaSelector.defaultsToFrontCamera = true
        mediaSelector.buttonBackgroundColor = UIColor.init(white: 0.8, alpha: 1.0)
        mediaSelector.present()
    }

}


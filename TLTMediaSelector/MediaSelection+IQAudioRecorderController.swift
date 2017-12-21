//
//  MediaSelection+IQAudioRecorderController.swift
//  TLTMediaSelector
//
//  Created by Martin Rehder on 01.12.2016.
//  Copyright © 2016 Teletronics, MIT License

/*
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit
import IQAudioRecorderController

extension MediaSelection {

    func presentAudioRecorderViewControllerAnimated(_ audioRecorderViewController: IQAudioRecorderViewController) {
        let navigationController = UINavigationController(rootViewController:audioRecorderViewController)
        
        navigationController.isToolbarHidden = false
        navigationController.toolbar.isTranslucent = true
        
        navigationController.navigationBar.isTranslucent = true
        
        let bs = audioRecorderViewController.barStyle
        audioRecorderViewController.barStyle = bs
        if let topVC = UIApplication.topViewController() {
            if UI_USER_INTERFACE_IDIOM() == .phone {
                topVC.present(navigationController, animated: true, completion: { })
            }
            else {
                // On iPad use pop-overs.
                navigationController.modalPresentationStyle = .popover
                navigationController.popoverPresentationController?.sourceView = self.presentingView
                topVC.present(navigationController, animated:true, completion:nil)
            }
        }
    }
}

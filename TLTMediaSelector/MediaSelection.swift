//
//  MediaSelection.swift
//
//  Created by Martin Rehder on 27.06.16.
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
import Foundation
import MobileCoreServices
import SCLAlertView
import RSKImageCropper

public class MediaSelection: NSObject {

    public override init() {
        super.init()
    }
    
    public class func getPhotoWithCallback(getPhotoWithCallback callback: (photo: UIImage, info: [NSObject : AnyObject]) -> Void) {
        let mSel = MediaSelection()
        mSel.allowsVideo = false
        mSel.didGetPhoto = callback
        mSel.present()
    }
    
    public class func getVideoWithCallback(getVideoWithCallback callback: (video: NSURL, info: [NSObject : AnyObject]) -> Void) {
        let mSel = MediaSelection()
        mSel.allowsPhoto = false
        mSel.didGetVideo = callback
        mSel.present()
    }
    
    // MARK: - Configuration options

    public var allowsPhoto = true
    
    public var allowsVideo = false
    
    public var allowsTake = true
    
    public var allowsSelectFromLibrary = true
    
    public var allowsEditing = false

    public var allowsMasking = false

    public var iPadUsesFullScreenCamera = false
    
    public var defaultsToFrontCamera = false

    // Need to set this when using the control on an iPad
    public var presentingView: UIView? = nil
    
    public lazy var presentingViewController: UIViewController = {
        return UIApplication.sharedApplication().keyWindow!.rootViewController!
    }()
    
    
    // MARK: - Callbacks
    
    /// A photo was selected
    public var didGetPhoto: ((photo: UIImage, info: [NSObject : AnyObject]) -> Void)?
    
    /// A video was selected
    public var didGetVideo: ((video: NSURL, info: [NSObject : AnyObject]) -> Void)?
    
    /// The user selected did not attempt to select a photo
    public var didDeny: (() -> Void)?
    
    /// The user started selecting a photo or took a photo and then hit cancel
    public var didCancel: (() -> Void)?
    
    /// A photo or video was selected but the ImagePicker had NIL for EditedImage and OriginalImage
    public var didFail: (() -> Void)?

    public var customButtonPressed: (() -> Void)?
    
    // MARK: - Localization overrides

    public var title = "Select"
    public var subtitle = ""
    public var headIcon: UIImage?
    public var headIconBackgroundColor: UIColor?
    public var customButtonText: String?
    public var appearance: SCLAlertView.SCLAppearance?
    public var buttonBackgroundColor: UIColor?
    public var buttonTextColor: UIColor?

    /// Custom UI text (skips localization)
    public var takePhotoText: String? = nil
    
    /// Custom UI text (skips localization)
    public var takeVideoText: String? = nil
    
    /// Custom UI text (skips localization)
    public var chooseFromLibraryText: String? = nil
    
    /// Custom UI text (skips localization)
    public var chooseFromPhotoRollText: String? = nil
    
    /// Custom UI text (skips localization)
    public var cancelText: String? = nil
    
    /// Custom UI text (skips localization)
    public var noSourcesText: String? = nil
    
    
    private var selectedSource: UIImagePickerControllerSourceType?
    
    // MARK: - String constants
    
    private let kTakePhotoKey: String = "takePhoto"
    
    private let kTakeVideoKey: String = "takeVideo"
    
    private let kChooseFromLibraryKey: String = "chooseFromLibrary"
    
    private let kChooseFromPhotoRollKey: String = "chooseFromPhotoRoll"
    
    private let kCancelKey: String = "cancel"
    
    private let kNoSourcesKey: String = "noSources"

    public func isLastPhotoFromCamera() -> Bool {
        if let source = self.selectedSource where source == .Camera {
            return true
        }
        return false
    }
    
    // MARK: - Private
    
    // Used as temporary storage for returned image info from the iOS image picker, in order to pass it back to the caller after crop & scale operations
    private var selectedMediaInfo: [String : AnyObject]?

    private lazy var imagePicker: UIImagePickerController = {
        [unowned self] in
        let retval = UIImagePickerController()
        retval.delegate = self
        retval.allowsEditing = true
        return retval
        }()
    
    private var alertController: SCLAlertView? = nil
    
    // This is a hack required on iPad if you want to select a photo and you already have a popup on the screen
    // see: http://stackoverflow.com/a/34392409/300224
    private func topViewController(rootViewController: UIViewController) -> UIViewController {
        var rootViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        repeat {
            guard let presentedViewController = rootViewController.presentedViewController else {
                return rootViewController
            }
            
            if let navigationController = rootViewController.presentedViewController as? UINavigationController {
                rootViewController = navigationController.topViewController ?? navigationController
                
            } else {
                rootViewController = presentedViewController
            }
        } while true
    }
    
    // MARK: - Localization
    
    private func textForButtonWithTitle(title: String) -> String {
        switch title {
        case kTakePhotoKey:
            return "Take Photo"
        case kTakeVideoKey:
            return "Take Video"
        case kChooseFromLibraryKey:
            return "Use Photo Library"
        case kChooseFromPhotoRollKey:
            return "Use Photo Roll"
        case kCancelKey:
            return "Cancel"
        case kNoSourcesKey:
            return "Not Available"
        default:
            NSLog("Invalid title passed to textForButtonWithTitle:")
            return "ERROR"
        }
    }
    
    /**
     *  Presents the user with an option to take a photo or choose a photo from the library
     */
    public func present() {
        var titleToSource = [(buttonTitle: String, source: UIImagePickerControllerSourceType)]()
        
        if self.allowsTake && UIImagePickerController.isSourceTypeAvailable(.Camera) {
            if self.allowsPhoto {
                titleToSource.append((buttonTitle: kTakePhotoKey, source: .Camera))
            }
            if self.allowsVideo {
                titleToSource.append((buttonTitle: kTakeVideoKey, source: .Camera))
            }
        }
        if self.allowsSelectFromLibrary {
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                titleToSource.append((buttonTitle: kChooseFromLibraryKey, source: .PhotoLibrary))
            } else if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) {
                titleToSource.append((buttonTitle: kChooseFromPhotoRollKey, source: .SavedPhotosAlbum))
            }
        }
        
        if let appearance = self.appearance {
            self.alertController = SCLAlertView(appearance: appearance)
        }
        else {
            self.alertController = SCLAlertView()
        }
        let buttonBGColor = self.buttonBackgroundColor ?? UIColor.whiteColor()
        let buttonTextColor = self.buttonTextColor ?? UIColor.blackColor()
        for (title, source) in titleToSource {
            alertController!.addButton(self.textForButtonWithTitle(title), backgroundColor: buttonBGColor, textColor: buttonTextColor, showDurationStatus: false, action: {
                self.imagePicker.sourceType = source
                self.selectedSource = source
                if source == .Camera && self.defaultsToFrontCamera && UIImagePickerController.isCameraDeviceAvailable(.Front) {
                    self.imagePicker.cameraDevice = .Front
                }
                // set the media type: photo or video
                self.imagePicker.allowsEditing = self.allowsEditing
                var mediaTypes = [String]()
                if self.allowsPhoto {
                    mediaTypes.append(String(kUTTypeImage))
                }
                if self.allowsVideo {
                    mediaTypes.append(String(kUTTypeMovie))
                }
                self.imagePicker.mediaTypes = mediaTypes

                let topVC = self.topViewController(self.presentingViewController)

                if UI_USER_INTERFACE_IDIOM() == .Phone || (source == .Camera && self.iPadUsesFullScreenCamera) {
                    topVC.presentViewController(self.imagePicker, animated: true, completion: { _ in })
                } else {
                    // On iPad use pop-overs.
                    self.imagePicker.modalPresentationStyle = .Popover
                    self.imagePicker.popoverPresentationController?.sourceView = self.presentingView
                    topVC.presentViewController(self.imagePicker, animated:true, completion:nil)
                }
            })
        }
        
        if let cbt = self.customButtonText {
            alertController!.addButton(cbt, backgroundColor: buttonBGColor, textColor: buttonTextColor, showDurationStatus: false, action: {
                self.customButtonPressed?()
            })
        }

        if let icon = self.headIcon {
            let headIconBGColor = self.headIconBackgroundColor ?? UIColor.clearColor()
            self.alertController!.showCustom(self.title, subTitle: self.subtitle, color: headIconBGColor, icon: icon, closeButtonTitle: "Close")
        }
        else {
            self.alertController!.showInfo(self.title, subTitle: self.subtitle, closeButtonTitle: "Close")
        }
    }
    
    /**
     *  Dismisses the displayed view (actionsheet or imagepicker).
     *  Especially handy if the sheet is displayed while suspending the app,
     *  and you want to go back to a default state of the UI.
     */
    public func dismiss() {
        alertController?.dismissViewControllerAnimated(true, completion: nil)
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension MediaSelection : UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate {
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        UIApplication.sharedApplication().statusBarHidden = true
        let mediaType: String = info[UIImagePickerControllerMediaType] as! String
        var imageToSave: UIImage
        // Handle a still image capture
        if mediaType == kUTTypeImage as String {
            if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                imageToSave = editedImage
            } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                imageToSave = originalImage
            } else {
                self.didCancel?()
                return
            }
            
            if self.allowsMasking {
                self.selectedMediaInfo = info
                picker.dismissViewControllerAnimated(true, completion: {
                    dispatch_async(dispatch_get_main_queue(), {
                        let imageCropVC = RSKImageCropViewController(image: imageToSave)
                        imageCropVC.avoidEmptySpaceAroundImage = true
                        imageCropVC.delegate = self
                        if let topVC = UIApplication.topViewController() {
                            topVC.presentViewController(imageCropVC, animated: true, completion: { _ in })
                        }
                    })
                })
                
                // Skip other cleanup, as we exit with image elsewhere
                return
            }
            else {
                self.didGetPhoto?(photo: imageToSave, info: info)
            }
        } else if mediaType == kUTTypeMovie as String {
            self.didGetVideo?(video: info[UIImagePickerControllerMediaURL] as! NSURL, info: info)
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        UIApplication.sharedApplication().statusBarHidden = true
        picker.dismissViewControllerAnimated(true, completion: { _ in })
        self.didDeny?()
    }
    
    // MARK: - RSKImageCropViewControllerDelegate
    
    public func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        self.didGetPhoto?(photo: croppedImage, info: self.selectedMediaInfo!)
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}

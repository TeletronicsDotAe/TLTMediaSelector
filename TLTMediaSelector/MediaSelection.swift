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
import IQAudioRecorderController

public class MediaSelection: NSObject {
    public override init() {
        super.init()
    }
    
    public class func getPhotoWithCallback(getPhotoWithCallback callback: (photo: UIImage, info: [NSObject : AnyObject]) -> Void) {
        let mSel = MediaSelection()
        mSel.allowsVideo = false
        mSel.allowsPhoto = true
        mSel.allowsVoiceRecording = false
        mSel.didGetPhoto = callback
        mSel.present()
    }
    
    public class func getVideoWithCallback(getVideoWithCallback callback: (video: NSURL, info: [NSObject : AnyObject]) -> Void) {
        let mSel = MediaSelection()
        mSel.allowsVideo = true
        mSel.allowsPhoto = false
        mSel.allowsVoiceRecording = false
        mSel.didGetVideo = callback
        mSel.present()
    }
    
    public class func getVoiceRecordingWithCallback(getVoiceRecordingWithCallback callback: (recording: String) -> Void) {
        let mSel = MediaSelection()
        mSel.allowsVideo = false
        mSel.allowsPhoto = false
        mSel.allowsVoiceRecording = true
        mSel.didGetVoiceRecording = callback
        mSel.present()
    }
    
    // MARK: - Configuration options

    public var allowsPhoto = true
    
    public var allowsVideo = false
    
    public var allowsVoiceRecording = false
    
    public var allowsTake = true
    
    public var allowsSelectFromLibrary = true
    
    public var allowsEditing = false

    public var allowsMasking = false

    public var iPadUsesFullScreenCamera = false
    
    public var defaultsToFrontCamera = false
    
    public var videoMaximumDuration = NSTimeInterval()
    
    public var voiceRecordingMaximumDuration = NSTimeInterval()
    
    public var videoQuality = UIImagePickerControllerQualityType.TypeHigh

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

    /// A voice recording was made
    public var didGetVoiceRecording: ((recording: String) -> Void)?
    
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
    public var recorderTintColor: UIColor?
    public var recorderHighlightedTintColor: UIColor?

    /// Custom UI text (skips localization)
    public var takePhotoText: String? = nil
    
    /// Custom UI text (skips localization)
    public var takeVideoText: String? = nil

    /// Custom UI text (skips localization)
    public var makeVoiceRecordingText: String? = nil
    
    /// Custom UI text (skips localization)
    public var chooseFromPhotoLibraryText: String? = nil

    /// Custom UI text (skips localization)
    public var chooseFromVideoLibraryText: String? = nil
    
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

    private let kMakeVoiceRecordingKey: String = "makeVoiceRecording"
    
    private let kChooseFromPhotoLibraryKey: String = "chooseFromPhotoLibrary"

    private let kChooseFromVideoLibraryKey: String = "chooseFromVideoLibrary"
    
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
    
    // MARK: - Localization
    
    private func textForButtonWithTitle(title: String) -> String {
        switch title {
        case kTakePhotoKey:
            return self.takePhotoText ?? "Take Photo"
        case kTakeVideoKey:
            return self.takeVideoText ?? "Take Video"
        case kMakeVoiceRecordingKey:
            return self.makeVoiceRecordingText ?? "Voice Recorder"
        case kChooseFromPhotoLibraryKey:
            return self.chooseFromPhotoLibraryText ?? "Use Photo Library"
        case kChooseFromVideoLibraryKey:
            return self.chooseFromVideoLibraryText ?? "Use Video Library"
        case kChooseFromPhotoRollKey:
            return self.chooseFromPhotoRollText ?? "Use Photo Roll"
        case kCancelKey:
            return self.cancelText ?? "Cancel"
        case kNoSourcesKey:
            return self.noSourcesText ?? "Not Available"
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
                if self.allowsPhoto {
                    titleToSource.append((buttonTitle: kChooseFromPhotoLibraryKey, source: .PhotoLibrary))
                }
                if self.allowsVideo {
                    titleToSource.append((buttonTitle: kChooseFromVideoLibraryKey, source: .PhotoLibrary))
                }
            } else if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) {
                titleToSource.append((buttonTitle: kChooseFromPhotoRollKey, source: .SavedPhotosAlbum))
            }
        }
        if self.allowsVoiceRecording {
            titleToSource.append((buttonTitle: kMakeVoiceRecordingKey, source: .Camera))
        }
        
        if let appearance = self.appearance {
            self.alertController = SCLAlertView(appearance: appearance)
        }
        else {
            self.alertController = SCLAlertView()
        }
        let buttonBGColor = self.buttonBackgroundColor ?? UIColor.whiteColor()
        let buttonTextColor = self.buttonTextColor ?? UIColor.blackColor()
        let rTintColor = self.recorderTintColor ?? UIColor.blueColor()
        let rHighlightedTintColor = self.recorderHighlightedTintColor ?? UIColor.redColor()
        for (title, source) in titleToSource {
            alertController!.addButton(self.textForButtonWithTitle(title), backgroundColor: buttonBGColor, textColor: buttonTextColor, showDurationStatus: false, action: {
                if title == self.kMakeVoiceRecordingKey {
                    let controller = IQAudioRecorderViewController()
                    controller.delegate = self
                    controller.title = "Recorder"
                    controller.maximumRecordDuration = self.voiceRecordingMaximumDuration
                    controller.allowCropping = self.allowsEditing
                    controller.barStyle = UIBarStyle.Default
                    controller.normalTintColor = rTintColor
                    controller.highlightedTintColor = rHighlightedTintColor
                    self.presentAudioRecorderViewControllerAnimated(controller)
                }
                else {
                    self.imagePicker.sourceType = source
                    self.selectedSource = source
                    if source == .Camera && self.defaultsToFrontCamera && UIImagePickerController.isCameraDeviceAvailable(.Front) {
                        self.imagePicker.cameraDevice = .Front
                    }
                    // set the media type: photo or video
                    var mediaTypes = [String]()
                    if title == self.kTakeVideoKey || title == self.kChooseFromVideoLibraryKey {
                        self.imagePicker.videoQuality = self.videoQuality
                        self.imagePicker.allowsEditing = self.allowsEditing
                        self.imagePicker.videoMaximumDuration = self.videoMaximumDuration
                        mediaTypes.append(String(kUTTypeMovie))
                    }
                    else {
                        self.imagePicker.allowsEditing = false
                        mediaTypes.append(String(kUTTypeImage))
                    }
                    self.imagePicker.mediaTypes = mediaTypes
                    
                    self.presentAVViewController(self.imagePicker, source: source)
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
    
    func presentAVViewController(controller: UIViewController, source: UIImagePickerControllerSourceType) {
        if let topVC = UIApplication.topViewController() {
            if UI_USER_INTERFACE_IDIOM() == .Phone || (source == .Camera && self.iPadUsesFullScreenCamera) {
                topVC.presentViewController(controller, animated: true, completion: { _ in })
            }
            else {
                // On iPad use pop-overs.
                controller.modalPresentationStyle = .Popover
                controller.popoverPresentationController?.sourceView = self.presentingView
                topVC.presentViewController(controller, animated:true, completion:nil)
            }
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

extension MediaSelection : UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, IQAudioRecorderViewControllerDelegate {
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType: String = info[UIImagePickerControllerMediaType] as! String
        // Handle a still image capture
        if mediaType == kUTTypeImage as String {
            var imageToSave: UIImage
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
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
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
    
    // MARK: - IQAudioRecorderViewControllerDelegate
    
    public func audioRecorderController(controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        self.didGetVoiceRecording?(recording: filePath)
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    public func audioRecorderControllerDidCancel(controller: IQAudioRecorderViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}

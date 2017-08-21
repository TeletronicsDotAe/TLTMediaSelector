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

open class MediaSelection: NSObject {
    public override init() {
        super.init()
    }
    
    open class func getPhotoWithCallback(getPhotoWithCallback callback: @escaping (_ photo: UIImage, _ info: [AnyHashable: Any]) -> Void) {
        let mSel = MediaSelection()
        mSel.allowsVideo = false
        mSel.allowsPhoto = true
        mSel.allowsVoiceRecording = false
        mSel.didGetPhoto = callback
        mSel.present()
    }
    
    open class func getVideoWithCallback(getVideoWithCallback callback: @escaping (_ video: URL, _ info: [AnyHashable: Any]) -> Void) {
        let mSel = MediaSelection()
        mSel.allowsVideo = true
        mSel.allowsPhoto = false
        mSel.allowsVoiceRecording = false
        mSel.didGetVideo = callback
        mSel.present()
    }
    
    open class func getVoiceRecordingWithCallback(getVoiceRecordingWithCallback callback: @escaping (_ recording: String) -> Void) {
        let mSel = MediaSelection()
        mSel.allowsVideo = false
        mSel.allowsPhoto = false
        mSel.allowsVoiceRecording = true
        mSel.didGetVoiceRecording = callback
        mSel.present()
    }
    
    // MARK: - Configuration options

    open var allowsPhoto = true
    
    open var allowsVideo = false
    
    open var allowsVoiceRecording = false
    
    open var allowsTake = true
    
    open var allowsSelectFromLibrary = true
    
    open var allowsEditing = false

    open var allowsMasking = false
    open var customMaskDatasource: RSKImageCropViewControllerDataSource?

    open var iPadUsesFullScreenCamera = false
    
    open var defaultsToFrontCamera = false
    
    open var videoMaximumDuration = TimeInterval()
    
    open var voiceRecordingMaximumDuration = TimeInterval()
    
    open var videoQuality = UIImagePickerControllerQualityType.typeHigh

    // Need to set this when using the control on an iPad
    open var presentingView: UIView? = nil
    
    open lazy var presentingViewController: UIViewController = {
        return UIApplication.shared.keyWindow!.rootViewController!
    }()
    
    
    // MARK: - Callbacks
    
    /// A photo was selected
    open var didGetPhoto: ((_ photo: UIImage, _ info: [AnyHashable: Any]) -> Void)?
    
    /// A video was selected
    open var didGetVideo: ((_ video: URL, _ info: [AnyHashable: Any]) -> Void)?

    /// A voice recording was made
    open var didGetVoiceRecording: ((_ recording: String) -> Void)?
    
    /// The user selected did not attempt to select a photo
    open var didDeny: (() -> Void)?
    
    /// The user started selecting a photo or took a photo and then hit cancel
    open var didCancel: (() -> Void)?
    
    /// A photo or video was selected but the ImagePicker had NIL for EditedImage and OriginalImage
    open var didFail: (() -> Void)?

    open var customButtonPressed: (() -> Void)?
    
    // MARK: - Localization overrides

    open var title = "Select"
    open var subtitle = ""
    open var headIcon: UIImage?
    open var headIconBackgroundColor: UIColor?
    open var customButtonText: String?
    open var appearance: SCLAlertView.SCLAppearance?
    open var buttonBackgroundColor: UIColor?
    open var closeButtonBackgroundColor: UIColor?
    open var closeButtonTextColor: UIColor?
    open var buttonTextColor: UIColor?
    open var recorderTintColor: UIColor?
    open var recorderHighlightedTintColor: UIColor?

    /// Custom UI text (skips localization)
    open var takePhotoText: String? = nil
    
    /// Custom UI text (skips localization)
    open var takeVideoText: String? = nil

    /// Custom UI text (skips localization)
    open var takePhotoOrVideoText: String? = nil

    /// Custom UI text (skips localization)
    open var makeVoiceRecordingText: String? = nil
    
    /// Custom UI text (skips localization)
    open var chooseFromPhotoLibraryText: String? = nil

    /// Custom UI text (skips localization)
    open var chooseFromVideoLibraryText: String? = nil

    /// Custom UI text (skips localization)
    open var chooseFromPhotoOrVideoLibraryText: String? = nil

    /// Custom UI text (skips localization)
    open var chooseFromPhotoRollText: String? = nil
    
    /// Custom UI text (skips localization)
    open var cancelText: String? = nil
    
    /// Custom UI text (skips localization)
    open var noSourcesText: String? = nil
    
    
    fileprivate var selectedSource: UIImagePickerControllerSourceType?
    
    // MARK: - String constants
    
    fileprivate let kTakePhotoKey: String = "takePhoto"
    
    fileprivate let kTakeVideoKey: String = "takeVideo"

    fileprivate let kTakePhotoOrVideoKey: String = "takePhotoOrVideo"

    fileprivate let kMakeVoiceRecordingKey: String = "makeVoiceRecording"
    
    fileprivate let kChooseFromPhotoLibraryKey: String = "chooseFromPhotoLibrary"

    fileprivate let kChooseFromVideoLibraryKey: String = "chooseFromVideoLibrary"
    
    fileprivate let kChooseFromPhotoOrVideoLibraryKey : String = "chooseFromPhotoOrVideoLibrary"
    
    fileprivate let kChooseFromPhotoRollKey: String = "chooseFromPhotoRoll"
    
    fileprivate let kCancelKey: String = "cancel"
    
    fileprivate let kNoSourcesKey: String = "noSources"

    open func isLastPhotoFromCamera() -> Bool {
        if let source = self.selectedSource, source == .camera {
            return true
        }
        return false
    }
    
    // MARK: - Private
    
    // Used as temporary storage for returned image info from the iOS image picker, in order to pass it back to the caller after crop & scale operations
    fileprivate var selectedMediaInfo: [String : AnyObject]?

    fileprivate lazy var imagePicker: UIImagePickerController = {
        [unowned self] in
        let retval = UIImagePickerController()
        retval.delegate = self
        retval.allowsEditing = true
        return retval
        }()
    
    fileprivate var alertController: SCLAlertView? = nil
    
    // MARK: - Localization
    
    fileprivate func textForButtonWithTitle(_ title: String) -> String {
        switch title {
        case kTakePhotoKey:
            return self.takePhotoText ?? "Photo"
        case kTakeVideoKey:
            return self.takeVideoText ?? "Video"
        case kTakePhotoOrVideoKey:
            return self.takePhotoOrVideoText ?? "Photo or Video"
        case kMakeVoiceRecordingKey:
            return self.makeVoiceRecordingText ?? "Voice Recorder"
        case kChooseFromPhotoLibraryKey:
            return self.chooseFromPhotoLibraryText ?? "Photo Library"
        case kChooseFromVideoLibraryKey:
            return self.chooseFromVideoLibraryText ?? "Video Library"
        case kChooseFromPhotoOrVideoLibraryKey:
            return self.chooseFromPhotoOrVideoLibraryText ?? "Photo or Video Library"
        case kChooseFromPhotoRollKey:
            return self.chooseFromPhotoRollText ?? "Photo Roll"
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
    open func present() {
        var titleToSource = [(buttonTitle: String, source: UIImagePickerControllerSourceType)]()
        
        if self.allowsTake && UIImagePickerController.isSourceTypeAvailable(.camera) {
            if self.allowsPhoto && !self.allowsVideo {
                titleToSource.append((buttonTitle: kTakePhotoKey, source: .camera))
            }
            else if self.allowsVideo && !self.allowsPhoto {
                titleToSource.append((buttonTitle: kTakeVideoKey, source: .camera))
            }
            else {
                titleToSource.append((buttonTitle: kTakePhotoOrVideoKey, source: .camera))
            }
        }
        if self.allowsSelectFromLibrary {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                if self.allowsPhoto && !self.allowsVideo {
                    titleToSource.append((buttonTitle: kChooseFromPhotoLibraryKey, source: .photoLibrary))
                }
                else if self.allowsVideo && !self.allowsPhoto {
                    titleToSource.append((buttonTitle: kChooseFromVideoLibraryKey, source: .photoLibrary))
                }
                else {
                    titleToSource.append((buttonTitle: kChooseFromPhotoOrVideoLibraryKey, source: .photoLibrary))
                }
            } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                titleToSource.append((buttonTitle: kChooseFromPhotoRollKey, source: .savedPhotosAlbum))
            }
        }
        if self.allowsVoiceRecording {
            titleToSource.append((buttonTitle: kMakeVoiceRecordingKey, source: .camera))
        }
        
        var showDefaultCloseButton = true
        if closeButtonBackgroundColor != nil && closeButtonTextColor != nil {
            showDefaultCloseButton = false
        }

        if let appearance = self.appearance {
            self.alertController = SCLAlertView(appearance: appearance)
        }
        else {
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: showDefaultCloseButton)
            self.alertController = SCLAlertView(appearance: appearance)
        }
        
        let buttonBGColor = self.buttonBackgroundColor ?? UIColor.white
        let buttonTextColor = self.buttonTextColor ?? UIColor.black
        let rTintColor = self.recorderTintColor ?? UIColor.blue
        let rHighlightedTintColor = self.recorderHighlightedTintColor ?? UIColor.red
        for (title, source) in titleToSource {
            alertController!.addButton(self.textForButtonWithTitle(title), backgroundColor: buttonBGColor, textColor: buttonTextColor, action: {
                if title == self.kMakeVoiceRecordingKey {
                    let controller = IQAudioRecorderViewController()
                    controller.delegate = self
                    controller.title = "Recorder"
                    controller.maximumRecordDuration = self.voiceRecordingMaximumDuration
                    controller.allowCropping = self.allowsEditing
                    controller.barStyle = UIBarStyle.default
                    controller.normalTintColor = rTintColor
                    controller.highlightedTintColor = rHighlightedTintColor
                    self.presentAudioRecorderViewControllerAnimated(controller)
                }
                else {
                    self.imagePicker.sourceType = source
                    self.selectedSource = source
                    if source == .camera && self.defaultsToFrontCamera && UIImagePickerController.isCameraDeviceAvailable(.front) {
                        self.imagePicker.cameraDevice = .front
                    }
                    // set the media type: photo or video
                    var mediaTypes = [String]()
                    if title == self.kTakePhotoOrVideoKey || title == self.kChooseFromPhotoOrVideoLibraryKey {
                        self.imagePicker.videoQuality = self.videoQuality
                        self.imagePicker.videoMaximumDuration = self.videoMaximumDuration
                        self.imagePicker.allowsEditing = false
                        mediaTypes.append(String(kUTTypeMovie))
                        mediaTypes.append(String(kUTTypeImage))
                    }
                    else if title == self.kTakeVideoKey || title == self.kChooseFromVideoLibraryKey {
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
            alertController!.addButton(cbt, backgroundColor: buttonBGColor, textColor: buttonTextColor, action: {
                self.customButtonPressed?()
            })
        }
        
        if !showDefaultCloseButton {
            alertController!.addButton("Close", backgroundColor: closeButtonBackgroundColor, textColor: closeButtonTextColor, action: {
                self.alertController?.dismiss(animated: true)
            })
        }

        let cbt = showDefaultCloseButton ? "Close" : nil
        if let icon = self.headIcon {
            let headIconBGColor = self.headIconBackgroundColor ?? UIColor.clear
            let _ = self.alertController!.showCustom(self.title, subTitle: self.subtitle, color: headIconBGColor, icon: icon, closeButtonTitle: cbt)
        }
        else {
            self.alertController!.showInfo(self.title, subTitle: self.subtitle, closeButtonTitle: cbt)
        }
    }
    
    func presentAVViewController(_ controller: UIViewController, source: UIImagePickerControllerSourceType) {
        if let topVC = UIApplication.topViewController() {
            if UI_USER_INTERFACE_IDIOM() == .phone || (source == .camera && self.iPadUsesFullScreenCamera) {
                topVC.present(controller, animated: true, completion: { _ in })
            }
            else {
                // On iPad use pop-overs.
                controller.modalPresentationStyle = .popover
                controller.popoverPresentationController?.sourceView = self.presentingView
                topVC.present(controller, animated:true, completion:nil)
            }
        }
    }

    /**
     *  Dismisses the displayed view (actionsheet or imagepicker).
     *  Especially handy if the sheet is displayed while suspending the app,
     *  and you want to go back to a default state of the UI.
     */
    open func dismiss() {
        alertController?.dismiss(animated: true, completion: nil)
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}

extension MediaSelection : UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, IQAudioRecorderViewControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
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
                self.selectedMediaInfo = info as [String : AnyObject]?
                picker.dismiss(animated: true, completion: {
                    DispatchQueue.main.async(execute: {
                        let imageCropVC = RSKImageCropViewController(image: imageToSave)
                        imageCropVC.avoidEmptySpaceAroundImage = true
                        imageCropVC.dataSource = self.customMaskDatasource
                        imageCropVC.delegate = self
                        if let topVC = UIApplication.topViewController() {
                            topVC.present(imageCropVC, animated: true, completion: { _ in })
                        }
                    })
                })
                
                // Skip other cleanup, as we exit with image elsewhere
                return
            }
            else {
                self.didGetPhoto?(imageToSave, info)
            }
        } else if mediaType == kUTTypeMovie as String {
            self.didGetVideo?(info[UIImagePickerControllerMediaURL] as! URL, info)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: { _ in })
        self.didDeny?()
    }
    
    // MARK: - RSKImageCropViewControllerDelegate
    
    public func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        self.didGetPhoto?(croppedImage, self.selectedMediaInfo!)
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - IQAudioRecorderViewControllerDelegate
    
    public func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        self.didGetVoiceRecording?(filePath)
        controller.dismiss(animated: true, completion: nil)
    }

    public func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

}

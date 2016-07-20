# TLTMediaSelector

A popover control to select media, such as images, inspired by and adapted from FDTake https://github.com/fulldecent/FDTake
Using SCLAlertView for the visual interaction and RSKImageCropper for optional post cropping selected images.

## Features
- [x] easily customizable
- [x] Objective-C compatible

## Usage

The simplest way to use the selector is as follows:

```swift
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
```

## License

TLTMediaSelector is available under the MIT license. See the LICENSE file for more info.

platform :ios, '9.0'
use_frameworks!

target 'TLTMediaSelector' do
    pod 'SCLAlertView', '0.5.9'
    pod 'RSKImageCropper', '1.5.1'
    pod 'IQAudioRecorderController', '1.2.0'
end

target 'Demo' do
    pod 'SCLAlertView', '0.5.9'
    pod 'RSKImageCropper', '1.5.1'
    pod 'IQAudioRecorderController', '1.2.0'
end

post_install do |installer|
    `rm -rf Pods/Headers/Private/RSKImageCropper*`
end

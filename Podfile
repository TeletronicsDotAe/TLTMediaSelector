platform :ios, '10.0'
use_frameworks!

target 'TLTMediaSelector' do
    pod 'SCLAlertView', '0.7.0'
    pod 'RSKImageCropper', '1.5.2'
    pod 'IQAudioRecorderController', '1.2.0'
end

target 'Demo' do
    pod 'SCLAlertView', '0.7.0'
    pod 'RSKImageCropper', '1.5.2'
    pod 'IQAudioRecorderController', '1.2.0'
end

post_install do |installer|
    `rm -rf Pods/Headers/Private/RSKImageCropper*`
end

platform :ios, '10.0'
use_frameworks!

pod 'StyledOverlay', '~> 3.2'
pod 'RSKImageCropper', '2.0.0'
pod 'IQAudioRecorderController', '1.2.2'

target 'TLTMediaSelector' do
end

target 'Demo' do
end

post_install do |installer|
    `rm -rf Pods/Headers/Private/RSKImageCropper*`
end

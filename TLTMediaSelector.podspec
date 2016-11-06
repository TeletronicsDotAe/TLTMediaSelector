#
# Be sure to run `pod lib lint TLTMediaSelector.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "TLTMediaSelector"
  s.version          = "1.2.5"
  s.summary          = "Popover control to select media items such as images"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                      A popover control inspired by and adapted from FDTake https://github.com/fulldecent/FDTake
                       DESC

  s.homepage         = "https://github.com/TeletronicsDotAe/TLTMediaSelector"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Martin Jacob Rehder" => "rehscopods_01@rehsco.com" }
  s.source           = { :git => "https://github.com/TeletronicsDotAe/TLTMediaSelector.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'TLTMediaSelector/**/*.swift'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'SCLAlertView', '0.5.9'
  s.dependency 'RSKImageCropper', '1.5.1'
end

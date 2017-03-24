#
# Be sure to run `pod lib lint ASInAppCallStatusBar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ASInAppCallStatusBar'
  s.version          = '0.0.3'
  s.summary          = 'A generic status bar for showing in app call is ongoing.
'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A UIView implementation of the native call status bar in iOS. Since the call status bar is only available outside the app, it is good to create an in-app version of this feature
                       DESC

  s.homepage         = 'https://github.com/alexiss03/ASInAppCallStatusBar.git'  
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mary Alexis Solis' => 'maryalexissolis@gmail.com' }
  s.source           = { :git => 'https://github.com/alexiss03/ASInAppCallStatusBar.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ASInAppCallStatusBar/Classes/**/*'
  
  s.resources = ['ASInAppCallStatusBar/**/*.png', 'ASInAppCallStatusBar/**/*.xib', 'ASInAppCallStatusBar/**/*.nib']

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

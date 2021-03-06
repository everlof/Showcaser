#
# Be sure to run `pod lib lint Showcaser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Showcaser'
  s.version          = '0.2.0'
  s.summary          = 'Showcase parts of an app in a tutorial-style.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This library is used to present parts of an app in a tutorial-style.

Predefined areas are showcased when the showcaser are presented.
DESC

  s.homepage         = 'https://github.com/everlof/Showcaser'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'everlof' => 'everlof@gmail.com' }
  s.source           = { :git => 'https://github.com/everlof/Showcaser.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }
  s.swift_version = '4.2'
  s.source_files = 'Showcaser/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Showcaser' => ['Showcaser/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

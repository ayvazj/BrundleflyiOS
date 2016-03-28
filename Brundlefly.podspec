#
# Be sure to run `pod lib lint Brundlefly.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Brundlefly"
  s.version          = "0.2.0"
  s.summary          = "Animation engine for playing Adobe After Effects animations."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC

Animation Engine that runs animation definitions exported from Adobe After Effects.
Designers build complex animations in Adobe After Effects and export them to your
iOS apps bundle files.  Then these animations can be played from the exported files without
having to write any code.
                       DESC

  s.homepage         = "https://github.com/ayvazj/BrundleflyiOS"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "James Ayvaz" => "james.ayvaz@gmail.com" }
  s.source           = { :git => "https://github.com/ayvazj/BrundleflyiOS.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/jamesayvaz'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Brundlefly' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

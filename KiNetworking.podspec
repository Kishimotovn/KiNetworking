#
# Be sure to run `pod lib lint KiNetworking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KiNetworking'
  s.version          = '1.1.2'
  s.summary          = 'This library is a modern network layer built for high configuration + TDD. The library has the uasge of Alamofire, Promises and SwiftyJSON to make operations that help you go from API call to model directly.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Kishimotovn/KiNetworking'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Anh Phan Tran' => 'anh@thedistance.co.uk' }
  s.source           = { :git => 'https://github.com/Kishimotovn/KiNetworking.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'KiNetworking/Commons/*', 'KiNetworking/Protocols/*', 'KiNetworking/Implementations/*'
  
  # s.resource_bundles = {
  #   'KiNetworking' => ['KiNetworking/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Alamofire'
  s.dependency 'PromisesSwift'
  s.dependency 'SwiftyJSON'
end

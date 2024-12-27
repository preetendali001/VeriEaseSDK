Pod::Spec.new do |s|
  s.name             = 'VeriEaseSDK'
<<<<<<< HEAD
<<<<<<< HEAD
  s.version          = '1.0.2'
=======
  s.version          = '1.0.1'
>>>>>>> 9d27f3b (Update podspec and project structure for CocoaPods)
=======
  s.version          = '1.0.2'
>>>>>>> 52ec4f0 (Update podspec and project structure for CocoaPods)
  s.swift_versions   = '5.0'
  s.summary          = 'A SDK for face recognition and camera-based applications.'
  s.description      = <<-DESC
                  VeriEaseSDK provides face recognition and camera functionality for iOS apps
                  using Vision and AVFoundation frameworks.
                  DESC
  s.homepage         = 'https://github.com/preetendali001/VeriEaseSDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Preeten Dali' => 'your.preeten@softmonks.com' }
  s.source           = { :git => 'https://github.com/preetendali001/VeriEaseSDK.git', :tag => s.version.to_s }
  s.platform         = :ios, '15.0'
  s.source_files     = 'Sources/VeriEaseSDK/**/*.{swift}'
<<<<<<< HEAD
<<<<<<< HEAD
  s.frameworks       = 'UIKit', 'Vision', 'AVFoundation'
  s.requires_arc     = true
=======
  s.frameworks       = 'UIKit', 'Vision', 'AVFoundation', 'SwiftUI'
>>>>>>> 9d27f3b (Update podspec and project structure for CocoaPods)
=======
  s.frameworks       = 'UIKit', 'Vision', 'AVFoundation'
  s.requires_arc     = true
>>>>>>> 52ec4f0 (Update podspec and project structure for CocoaPods)
  s.static_framework = true
end

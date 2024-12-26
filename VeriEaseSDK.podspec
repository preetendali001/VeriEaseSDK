Pod::Spec.new do |s|
  s.name             = 'VeriEaseSDK'
  s.version          = '1.0.1'
  s.swift_versions   = '5.0' # Update Swift version; 4.0 is outdated
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

  # Add frameworks required by your SDK
  s.frameworks       = 'UIKit', 'Vision', 'AVFoundation'
  s.dependency       'SwiftUI'

  # Enable compatibility with static frameworks (optional, if you face linking issues)
  s.static_framework = true
end

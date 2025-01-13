Pod::Spec.new do |s|
  s.name             = 'VeriEaseSDK'
  s.version          = '1.2.0'
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
  s.frameworks       = 'UIKit', 'Vision', 'AVFoundation'
  s.requires_arc     = true
  s.static_framework = true
end

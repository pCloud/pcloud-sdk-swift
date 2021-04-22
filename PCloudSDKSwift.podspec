Pod::Spec.new do |s|
  s.name                  = 'PCloudSDKSwift'
  s.version               = '3.0.0'
  s.summary               = 'Swift SDK for the pCloud API'
  s.homepage              = 'https://github.com/pcloud/pcloud-sdk-swift'
  s.license               = 'MIT'
  s.author                = 'pCloud'

  s.source                = { :git => "https://github.com/pcloud/pcloud-sdk-swift.git", :tag => 'v3.0.0' }
  s.swift_version         = '5'

  s.osx.deployment_target = '10.11'
  s.ios.deployment_target = '9.0'

  s.osx.frameworks        = 'AppKit', 'Webkit', 'SystemConfiguration', 'Foundation'
  s.ios.frameworks        = 'UIKit', 'Webkit', 'SystemConfiguration', 'Foundation'

  s.ios.public_header_files = 'PCloudSDKSwift/Source/**/*.h'
  s.osx.public_header_files = 'PCloudSDKSwift/Source/**/*.h'

  s.osx.source_files = "PCloudSDKSwift/Source/Common/**/*.{swift,h}", "PCloudSDKSwift/Source/macOS/**/*.swift"
  s.ios.source_files = "PCloudSDKSwift/Source/Common/**/*.{swift,h}", "PCloudSDKSwift/Source/iOS/**/*.swift"

  s.osx.resource_bundle = { 'PCloudSDKSwiftResources' => "PCloudSDKSwift/Source/macOS/*.xib" }

  s.requires_arc = true
end

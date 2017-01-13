Pod::Spec.new do |s|
  s.name                  = 'PCloudSDKSwift'
  s.version               = '1.0.2'
  s.summary               = 'Swift SDK for the pCloud API'
  s.homepage              = 'https://github.com/pcloud-oss/pcloud-sdk-swift'
  s.license               = 'MIT'
  s.author                = 'pCloud'

  s.source               = { :git => "https://github.com/pcloud-oss/pcloud-sdk-swift.git", :tag => "#{s.version}" }

  s.osx.deployment_target = '10.11'
  s.ios.deployment_target = '9.0'

  s.osx.frameworks        = 'AppKit', 'Webkit', 'SystemConfiguration', 'Foundation'
  s.ios.frameworks        = 'UIKit', 'Webkit', 'SystemConfiguration', 'Foundation'

  s.ios.public_header_files = 'PCloudSDKSwift/Source/**/*.h'
  s.osx.public_header_files = 'PCloudSDKSwift/Source/**/*.h'

  s.osx.source_files = "PCloudSDKSwift/Source/**/*.{swift,h}", "PCloudSDKSwift/SDK\ macOS/**/*.swift"
  s.ios.source_files = "PCloudSDKSwift/Source/**/*.{swift,h}", "PCloudSDKSwift/SDK\ iOS/**/*.swift"

  s.requires_arc = true
end

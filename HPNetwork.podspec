Pod::Spec.new do |spec|

  spec.name         = "HPNetwork"
  spec.version      = "0.3.2"
  spec.summary      = "A lightweight but customisable networking stack written in Swift"
  spec.swift_version = "5.0"

  spec.homepage     = "https://github.com/henrik-dmg/HPNetwork"

  spec.license      = "MIT"

  spec.author             = { "Henrik Panhans" => "henrik@panhans.dev" }
  spec.social_media_url   = "https://twitter.com/henrik_dmg"

  spec.ios.deployment_target = "8.0"
  spec.osx.deployment_target = "10.11"
  spec.watchos.deployment_target = "3.0"
  spec.tvos.deployment_target = "9.0"

  spec.source       = { :git => "https://github.com/henrik-dmg/HPNetwork.git", :tag => "#{spec.version}" }

  spec.source_files  = "Sources/HPNetwork/**/*.swift"

  spec.framework = "Foundation"
  spec.ios.framework = "UIKit"
  spec.watchos.framework = "UIKit"
  spec.tvos.framework = "UIKit"

  spec.requires_arc = true

end

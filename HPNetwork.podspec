Pod::Spec.new do |s|

  s.name         = "HPNetwork"
  s.version      = "1.1.1"
  s.summary      = "A lightweight but customisable networking stack written in Swift"

  s.homepage     = "https://panhans.dev/opensource/hpnetwork"

  s.license      = "MIT"

  s.author             = { "Henrik Panhans" => "henrik@panhans.dev" }
  s.social_media_url   = "https://twitter.com/henrik_dmg"

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.11"
  s.watchos.deployment_target = "3.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/henrik-dmg/HPNetwork.git", :tag => s.version }

  s.source_files  = "Sources/HPNetwork/**/*.swift"

  s.framework = "Foundation"
  s.ios.framework = "UIKit"
  s.watchos.framework = "UIKit"
  s.tvos.framework = "UIKit"
  s.osx.framework = "AppKit"

  s.swift_version = "5.3"
  s.requires_arc = true
  s.requires_arc = true

end

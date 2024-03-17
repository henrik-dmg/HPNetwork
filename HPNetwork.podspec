Pod::Spec.new do |s|
  s.name         = 'HPNetwork'
  s.version      = '4.0.0'
  s.summary      = 'A lightweight but customisable networking stack written in Swift'

  s.homepage     = 'https://panhans.dev/opensource/hpnetwork'
  s.license      = 'MIT'
  s.author             = { 'Henrik Panhans' => 'henrik@panhans.dev' }
  s.social_media_url   = 'https://twitter.com/henrik_dmg'

  s.ios.deployment_target = '15.0'
  s.watchos.deployment_target = '6.0'
  s.tvos.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'

  s.source = { git: 'https://github.com/henrik-dmg/HPNetwork.git', tag: s.version }
  s.source_files = 'Sources/HPNetwork/**/*.swift' # TODO: add HPNetworkMock
  s.framework = 'Foundation'

  s.swift_version = '5.7'
  s.requires_arc = true
end

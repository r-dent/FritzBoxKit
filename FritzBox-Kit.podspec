Pod::Spec.new do |s|
  s.name         = 'FritzBox-Kit'
  s.version      = '0.5.0'

  s.summary      = 'Swift SDK for communicating with Fritz! smart home devices.'
  s.author       = { 'Roman Gille' => 'developer@romangille.com' }
  s.homepage     = 'https://github.com/r-dent/FritzBoxKit'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.source       = { :git => 'https://github.com/r-dent/FritzBoxKit.git', :tag => "v#{s.version}" }
  s.source_files = 'Sources/**/*.swift'
  s.swift_version = '5.0'

  s.dependency 'AEXML'
  s.dependency 'XMLMapper'

  s.platform     = :ios, '9.0'
  s.ios.deployment_target = '9'
end
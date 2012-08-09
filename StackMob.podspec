Pod::Spec.new do |s|
  s.name     = 'StackMob'
  s.version  = '1.0.0'
  s.license  = 'Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)'
  s.summary  = "StackMob's SDK for accessing the StackMob Services on iOS."
  s.homepage = 'http://stackmob.com'
  s.author   = { 'StackMob' => 'info@stackmob.com' }
  s.source   = { :git => 'git@github.com:stackmob/stackmob-ios-sdk.git' }

  s.description = 'StackMob gives you everything you need to have a powerful platform so you can focus on creating feature-rich apps. Our flexible solution can help bring any app idea you have to life. From rapid implementation of persistence, to a proper workflow of development and production environments, to integrated services like Push Notifications and Social Integration so you no longer have to write the same code all your competitors write.
  We don’t believe in lock in. You own and have complete access to your data, and can export at anytime, so build with confidence.'

  s.platform = :ios
  s.source_files = 'SDK/*.{h,m}', 'SDK/API/*.{h,m}'
  s.dependency 'AFNetworking', '~> 1.0RC1'
  s.frameworks = 'CoreData', 'CoreLocation'
  s.requires_arc = true
end

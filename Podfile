# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'chating-seminar-ios' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for chating-seminar-ios
	pod 'Firebase/Core'
	pod 'Firebase/Auth'
	pod 'Firebase/Database'
	pod 'Firebase/Storage'
	pod 'Firebase/Crash'
	pod 'Fabric', '~> 1.7.6'
	pod 'Crashlytics', '~> 3.10.1'	
	use_frameworks!
	pod 'TextFieldEffects'
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end
end

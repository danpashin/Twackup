

target 'twackup' do
  platform :ios, '8.0'
  pod 'SSZipArchive'
end

target 'twackup_macos' do
  platform :osx, '10.10'
  pod 'SSZipArchive'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
    end
  end
end
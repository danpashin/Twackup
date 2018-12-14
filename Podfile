
platform :ios, '8.0'

target 'twackup' do
  pod 'SSZipArchive'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
    end
  end
end
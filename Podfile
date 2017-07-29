# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'E-chase' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for E-chase
  pod 'Firebase'
  pod 'Firebase/AdMob'
  pod 'Firebase/Analytics'
  pod 'Firebase/AppIndexing'
  pod 'Firebase/Auth'
  pod 'Firebase/Crash'
  pod 'Firebase/Database'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Messaging'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Storage'
  pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git' 
  
  pod 'GooglePlaces'
  pod 'GooglePlacePicker'
  pod 'GoogleMaps'

  pod 'SDWebImage', '~>3.8'

  pod 'GradientCircularProgress', :git => 'https://github.com/keygx/GradientCircularProgress'

  pod 'IQKeyboardManagerSwift'
  pod 'M13Checkbox'

  post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.0'
            end
        end
  end

  target 'E-chaseTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'E-chaseUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

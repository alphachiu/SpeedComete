# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def common_Pods
   use_frameworks!

  # Pods for SpeedRecord
  pod 'SnapKit', '~> 5.0.0'
  pod 'SwifterSwift'
  pod 'SQLite.swift'
  pod "SwiftChart"
  pod 'EmptyDataSet-Swift', '~> 4.2.0'
  pod 'SCLAlertView'
 #pod 'Firebase/Core'
 #pod 'Firebase/AdMob'
  pod 'Google-Mobile-Ads-SDK'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'GoogleMobileAdsMediationAdColony'
  pod 'GoogleMobileAdsMediationFacebook'


end

target 'SpeedRecord' do
  common_Pods
end

target 'SpeedRecord-Dev' do
  common_Pods
end

  target 'SpeedRecordTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SpeedRecordUITests' do
    # Pods for testing
  end



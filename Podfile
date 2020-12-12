# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

load 'remove_ios_only_frameworks.rb'
target 'Foodie Thing' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for Foodie Thing
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'GoogleSignIn'
  pod 'SPAlert'
  pod 'SwiftDate'
  pod 'TransitionableTab'
  pod 'SteviaLayout'
  pod 'PryntTrimmerView'
  
end

# 2. Define which libraries should be excluded for macCatalyst
def catalyst_unsupported_pods
  ["Firebase/Analytics", "GoogleSignIn"]
end

# 3. Run the script
post_install do |installer|
  installer.configure_support_catalyst
end

# iOS Setup

To ensure the SDK works for iOS, please follow these steps:

First, go to your Podfile located at ios/Podfile and add the following at the top of the file:

``` Ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://bitbucket.org/sencyai/ios_sdks_release.git'
```

Next, add these install hooks at the end of the file:

```Ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
        target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.5'
    end
  end
end
```

Now we need to add camera permission. The easiest way is to open the `.xcworkspace` file. This will open your iOS project in Xcode. From there, navigate to `Info.plist` and add the following:

```
<key>NSCameraUsageDescription</key>
<string>Camera access is needed</string>
```

These steps should ensure that the SDK is properly integrated and configured for your iOS project.

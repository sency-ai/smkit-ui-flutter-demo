# SMKitUI SDK - Demo App

### [Usage](#usage)
* [Initialization](#initialization)
* [Android](#Android)
* [iOS](#iOS)

### [API](#api)
* [Start Assessment](#start-assessment)
* [Start Custom Workout](#start-custom-workout)

## Usage
To use SMKitUI in your project, add these dependencies to your application in your `pubspec.yaml` file.
```yaml
dependencies:
flutter_smkit_ui: ^0.1.1
```

### Initialization
To initialize SMKitUI in your App, You need to use the dedicated flutter plugin 
```dart
import 'package:flutter_smkit_ui/flutter_smkit_ui_plugin.dart';

final _smkitUiFlutterPlugin = SmkitUiFlutterPlugin();
_smkitUiFlutterPlugin.configure(key: "YOUR_AUTH_KEY")
```

Also when `initState()` is being initialized please call this function in order to make sure the Platform messages are asynchronous.
We can achive that by initialize the state in an async method.

```dart
 Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }
```
### Android
In order to be compatible with SMKitUI, the Android project should make some changes.

At `gradle-wrapper.properties` please change gradle version to be 8^.

```groovy
  distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-bin.zip
```

Under `gradle.properties` on project level add the following: 

```groovy
  SMKitUI_Version = 0.1.2
  artifactory_contentUrl = https://artifacts.sency.ai/artifactory/release
```

Remove all the content in `settings.gradle` and insert the follow: 
```groovy
  include ":app" // YOUR Module Name
  def localPropertiesFile = new File(rootProject.projectDir, "local.properties")
  def properties = new Properties()

  assert localPropertiesFile.exists()
  localPropertiesFile.withReader("UTF-8") { reader -> properties.load(reader) }

  def flutterSdkPath = properties.getProperty("flutter.sdk")
  assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
  apply from: "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle"
```  

At `build.gradle` on project level insert buildscript block like the following:
And please make sure your kotlin_version is at least 1.9
```groovy
buildscript {
  ext.kotlin_version = '1.9.24'
  repositories {
      google()
      mavenCentral()
  }

  dependencies {
      classpath 'com.android.tools.build:gradle:8.0.2'
      classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
      classpath 'com.google.gms:google-services:4.3.8'
  }
}
```

Also please specify under allprojects.repositories our repo url
```groovy
allprojects {
  repositories {
      google()
      mavenCentral()
      maven {
          url "${artifactory_contentUrl}"
      }
  }
}
```

At `build.gradle` on module level please remove upper Plugin{} auto-generate block
And Insert the following:
```groovy
def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"
android{
  ...
}
```
> :warning: **Please make sure**: To declare def flutterRoot before applying plugins !

At `build.gradle` on module level please add packagingOptions and change `minSdkVersion` to 26
```groovy
android{
  ...
  packagingOptions {
      pickFirst '**/*.so'
  }
  defaultConfig {
    minSdkVersion 26
  }
}
```


### iOS
To ensure the SDK works for iOS, please follow these steps:

First, go to your Podfile located at ios/Podfile and add the following at the top of the file:

``` Ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://bitbucket.org/sency-ios/sency_ios_sdk.git'
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


## API
### Start Assessment
Start the Assessment screen. In the parameters method `startAssessment()` You can add `SencyHandlerStatus` to track the success of the method. 
You need to process the result that the methods return in the callback.

Please make sure you call `startAssessment()` only after configuring the plugin with your "AUTH_KEY".
```dart
  // Under Button Widget of sort
  onPressed: () {
    _smkitUiFlutterPlugin.startAssessment(
      onHandle: (status) {
        debugPrint('_startAssessment status: ${status.operation} ${status.data}');
        // status.operation => workoutSummrayData, exerciseData or error
        if (status.data == null) return;

        final workoutResult = status.data;
        debugPrint('_startAssessment workoutResult: $workoutResult');
        
        if (workoutResult == null || workoutResult.isEmpty) return;
        // Handle the Result
      },
    );
  }
```

`SencyHandlerStatus` object is a representative for the comminucation between Platform-to-Dart inside Sency's flutter plugin.
The comminucation is being done by json serialize and deserialize by EventSink native flutter object.
Here is a sneek peek to `SencyHandlerStatus` object: 

```dart
  enum SencyOperation {
    error,
    workoutSummaryData,
    exerciseData;
  }

  class SencyHandlerStatus {
    final SencyOperation operation;
    final String? data;
  }
```

Please address the code for further reading

### Start Custom Workout
Start the workout screen with custom workout. In the parameters method `startCustomWorkout()` add the `SencyHandlerStatus` listener as explained above. To track the success of the method or get the expected
data, you need to process the result that the methods return to the callback.
```dart
SMWorkout getDemoWorkout() {
    List<SMExercise> exercises = [
      SMExercise(
        name: "First Exercise", // => name:string | null
        totalSeconds: 35, // => totalSeconds: int | null
        introSeconds: 5, // => introSeconds: int | null
        videoInstruction: null,  // => videoInstruction: string | null (url for a video)
        exerciseIntro: null, // => exerciseIntro: string | null (url for a sound)
        uiElements: [UIElement.RepsCounter, UIElement.GaugeOfMotion], // => uiElements: UIElement[] | null
        detector: "HighKnees",  // => detector: string
        repBased: true, // => repBased: bool | null
        exerciseClosure: null, // => exerciseClosure: string | null (url for a sound)
        targetReps: 13, // => targetReps: int | null
        targetTime: 20, // => targetTime: int | null
        scoreFactor: 0.3, // => scoreFactor: double | null
      ),
      SMExercise(
        name: "Second Exercise",
        totalSeconds: 25,
        introSeconds: 5,
        videoInstruction: null,
        exerciseIntro: null,
        uiElements: [UIElement.GaugeOfMotion, UIElement.Timer],
        detector: "SquatRegularOverheadStatic",
        repBased: false,
        exerciseClosure: null,
        targetReps: null,
        targetTime: 20,
        scoreFactor: 0.3,
      ),
    ];

    return SMWorkout(
      id: "50", // => id: string | null
      name: "demo workout", // => name: string | null
      workoutIntro: null, // => workoutIntro: string | null (url for a sound)
      soundTrack: null, // => soundtrack: string | null (url for a sound)
      exercises: exercises, // => exercises: SMExercise[]
      getInFrame: null, // =>  getInFrame: string | null (url for a sound)
      bodycalFinished: null, // =>  bodycalFinished: string | null (url for a sound)
      workoutClosure: null, // =>  workoutClosure: string | null (url for a sound)
    );
}

// Under Button widget of sort 
onPressed: () {
  _smkitUiFlutterPlugin.startCustomWorkout(
    workout: getDemoWorkout(),
    onHandle: (status) {
      debugPrint('startCustomWorkout status: ${status.operation} ${status.data}');
      // status.operation => workoutSummrayData, exerciseData or error
      if (status.data == null) return;

      final workoutResult = status.data;
      debugPrint('startCustomWorkout workoutResult: $workoutResult');
      
      if (workoutResult == null || workoutResult.isEmpty) return;
      // Handle the Result
    },
  );
}
```

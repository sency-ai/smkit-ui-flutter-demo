# Migration Guide to v1.3.0

This guide helps you migrate your existing `flutter_smkit_ui` implementation to version 1.3.0.

## 🆕 What's New in v1.3.0

### Android 15 & 16 Compatibility

Version 1.3.0 brings comprehensive support for the latest Android versions with significant infrastructure upgrades:

- **Android 16 Support**: Full compatibility with Android 16 (API 36)
- **Android 15 Enhanced**: Improved 16KB page size compatibility
- **Native SDK Upgrade**: Updated to SMKitUI 1.3.9 for enhanced stability
- **Modern Build System**: Gradle 8.11.1/8.13 and Android Gradle Plugin 8.11.1
- **Kotlin 2.0**: Upgraded to Kotlin 2.0.21 for better performance

### Who Should Upgrade?

- **All developers** preparing for Android 16 compatibility
- **Production apps** targeting the latest Android versions
- **Apps experiencing build issues** with modern Android toolchains
- **Teams seeking improved build performance** with Kotlin 2.0

## Migration Steps

### 1. Update Dependencies

Update your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_smkit_ui: ^1.3.0  # Update from your current version
```

### 2. Clean and Rebuild

After updating the dependency:

```bash
flutter clean
flutter pub get
flutter build android
```

### 3. Test on Latest Android Versions

If you have access to Android 15 or 16 devices or emulators:

1. Test your app on devices with the latest Android versions
2. Verify 16KB page size compatibility on Android 15+
3. Monitor memory usage and performance metrics
4. Ensure all SMKitUI functionality works as expected

## No Code Changes Required

**Good News**: Version 1.3.0 is fully backward compatible. No code changes are required in your application. All existing APIs and functionality remain unchanged.

## Enhanced Features

### Rest Periods in Workouts

Version 1.3.0 (and earlier) supports rest periods between exercises using the `"Rest"` detector type:

```dart
List<SMKitExercise> exercises = [
  SMKitExercise(
    prettyName: "High Knees",
    exerciseIntro: highKneesIntroURL,
    totalSeconds: 30,
    videoInstruction: "https://example.com/highknees.mp4",
    uiElements: [SMKitUIElement.timer, SMKitUIElement.repsCounter],
    detector: "HighKnees",
    exerciseClosure: null,
  ),
  // Add a rest period
  SMKitExercise(
    prettyName: "Rest",
    exerciseIntro: restIntroURL,
    totalSeconds: 15,  // 15 seconds rest
    videoInstruction: null,
    uiElements: [SMKitUIElement.timer],
    detector: "Rest",  // Special detector type for rest periods
    exerciseClosure: null,
  ),
  SMKitExercise(
    prettyName: "Squats",
    exerciseIntro: squatsIntroURL,
    totalSeconds: 30,
    videoInstruction: "https://example.com/squats.mp4",
    uiElements: [SMKitUIElement.timer, SMKitUIElement.repsCounter],
    detector: "Squats",
    exerciseClosure: null,
  ),
];
```

### Features from Previous Versions

If you're upgrading from versions earlier than 1.2.8, you'll also benefit from:

#### Fire-and-Forget Preference Setters (v1.2.8+)

These methods are now fire-and-forget (don't use `await`):

```dart
// ✅ Correct way (v1.2.8+)
_smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english);
_smkitUiFlutterPlugin.setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly);
_smkitUiFlutterPlugin.setEndExercisePreferences(endExercisePrefernces: SMKitEndExercisePreferences.targetBased);
```

## Benefits of v1.3.0

- **Android 16 Ready**: Full compatibility with Android 16 (API 36)
- **Enhanced Android 15 Support**: Improved 16KB page size handling
- **Modern Build Tools**: Faster builds with Gradle 8.11.1 and Kotlin 2.0
- **Improved Stability**: Native SDK upgraded to version 1.3.9
- **Zero Breaking Changes**: Seamless upgrade with no code modifications needed
- **Future-Proof**: Ready for upcoming Android updates and requirements

## Platform Compatibility

### Supported Platforms
- **Android**: API level 21+ with full Android 15 and 16 support
- **iOS**: iOS 11.0+ (unchanged)
- **Flutter**: SDK 3.5.0+ (unchanged)

### Android-Specific Features
- Android 16 (API 36) compatibility
- 16KB page size optimization for Android 15+
- Kotlin 2.0.21 runtime improvements
- Enhanced build system performance

## Build System Updates

### Gradle Updates
- Gradle wrapper: 8.11.1/8.13
- Android Gradle Plugin: 8.11.1
- Kotlin: 2.0.21
- compileSdk: 36 (Android 16)

### Potential Build Issues

If you encounter build issues after updating:

```bash
# Clean all build artifacts
cd android
./gradlew clean
cd ..
flutter clean

# Update Flutter
flutter pub get
flutter pub upgrade

# Rebuild
flutter build android
```

## Testing Recommendations

### Before Deployment

1. **Android Version Testing**: Test on Android 15 and 16 devices/emulators
2. **Memory Testing**: Use Flutter's memory profiling tools
3. **Performance Monitoring**: Check app startup times and runtime performance
4. **Build System**: Verify builds complete successfully with new Gradle version
5. **Regression Testing**: Ensure all existing features work as expected

### Performance Monitoring

```dart
// Example: Monitor memory usage during SMKitUI operations
import 'dart:developer' as developer;

void monitorPerformance() {
  developer.Timeline.startSync('SMKitUI_Operation');
  // Your SMKitUI code here
  developer.Timeline.finishSync();
}
```

## Troubleshooting

### Common Issues

#### Build Errors After Update
If you encounter build errors:

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter pub upgrade
```

#### Gradle Version Conflicts
If you have custom Gradle configuration in your Android project, ensure compatibility with:
- Gradle 8.11.1+
- Android Gradle Plugin 8.11.1
- Kotlin 2.0.21

#### Memory Issues on Android 15/16
If you experience memory-related issues:

1. Ensure you're using version 1.3.0
2. Clean and rebuild your project
3. Test on devices with different page sizes
4. Check native library compatibility

### Getting Help

If you encounter issues during migration:

1. Check the [Error Handling Guide](errorHandling.md)
2. Review your implementation against the updated examples
3. Verify your Android build configuration matches requirements
4. Contact support with specific error messages and device information

## Complete Example

Here's a complete example using v1.3.0 with rest periods:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui_plugin.dart';

class SMKitUIExample extends StatefulWidget {
  @override
  _SMKitUIExampleState createState() => _SMKitUIExampleState();
}

class _SMKitUIExampleState extends State<SMKitUIExample> {
  final _smkitUiFlutterPlugin = SmkitUiFlutterPlugin();

  @override
  void initState() {
    super.initState();
    _initializeSDK();
  }

  Future<void> _initializeSDK() async {
    try {
      await _smkitUiFlutterPlugin.configure(key: "YOUR_AUTH_KEY");
      
      // Fire-and-forget preferences (v1.2.8+)
      _smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english);
      _smkitUiFlutterPlugin.setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly);
      
    } catch (e) {
      debugPrint('SMKitUI initialization error: $e');
    }
  }

  Future<SMKitWorkout> _createWorkoutWithRest() async {
    List<SMKitExercise> exercises = [
      SMKitExercise(
        prettyName: "High Knees",
        exerciseIntro: "intro.mp3",
        totalSeconds: 30,
        videoInstruction: null,
        uiElements: [SMKitUIElement.timer, SMKitUIElement.repsCounter],
        detector: "HighKnees",
        exerciseClosure: null,
      ),
      // Rest period
      SMKitExercise(
        prettyName: "Rest",
        exerciseIntro: "rest.mp3",
        totalSeconds: 15,
        videoInstruction: null,
        uiElements: [SMKitUIElement.timer],
        detector: "Rest",
        exerciseClosure: null,
      ),
      SMKitExercise(
        prettyName: "Squats",
        exerciseIntro: "squats.mp3",
        totalSeconds: 30,
        videoInstruction: null,
        uiElements: [SMKitUIElement.timer, SMKitUIElement.repsCounter],
        detector: "Squats",
        exerciseClosure: null,
      ),
    ];

    return SMKitWorkout(
      id: "workout-1",
      name: "HIIT Workout",
      workoutIntro: "intro.mp3",
      soundTrack: null,
      exercises: exercises,
      getInFrame: null,
      bodycalFinished: null,
      workoutClosure: null,
    );
  }

  void _startWorkout() async {
    final workout = await _createWorkoutWithRest();
    
    _smkitUiFlutterPlugin.startCustomaizedWorkout(
      workout: workout,
      onHandle: (status) {
        debugPrint('Workout status: ${status.operation}');
        // Handle results
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SMKitUI v1.3.0 Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: _startWorkout,
          child: Text('Start Workout with Rest'),
        ),
      ),
    );
  }
}
```

## Summary

Version 1.3.0 is a seamless upgrade that brings essential Android 16 compatibility and modern build tooling without requiring any code changes. The update ensures your app remains compatible with the latest Android versions while maintaining all existing functionality.

Key benefits:
- ✅ Android 16 (API 36) compatibility
- ✅ Enhanced Android 15 support with 16KB page size
- ✅ Modern build tools (Gradle 8.11.1, Kotlin 2.0)
- ✅ Zero breaking changes
- ✅ Improved build performance
- ✅ Future-proof compatibility
- ✅ Backward compatibility maintained

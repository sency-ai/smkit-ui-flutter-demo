# Migration Guide to v1.2.9

> **Note**: For the latest version (v1.3.0) with Android 16 compatibility and modern build tools, see the [Migration Guide v1.3.0](migration-v1.3.0.md).

This guide helps you migrate your existing `flutter_smkit_ui` implementation to version 1.2.9.

## 🆕 What's New in v1.2.9

### Android 15 16KB Page Size Compatibility

Version 1.2.9 introduces full compatibility with Android 15's new 16KB page size requirements. This ensures:

- **Optimal Performance**: Better memory alignment and reduced memory fragmentation on Android 15+ devices
- **Future-Proof Compatibility**: Seamless operation on devices with 16KB page sizes
- **Enhanced Stability**: Improved memory management for better app stability
- **Native Library Support**: All native components are optimized for 16KB page size systems

### Who Should Upgrade?

- **All developers** preparing for Android 15 compatibility
- **Production apps** targeting the latest Android versions
- **Apps experiencing memory-related issues** on newer Android devices

## Migration Steps

### 1. Update Dependencies

Update your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_smkit_ui: ^1.2.9  # Update from your current version
```

### 2. Clean and Rebuild

After updating the dependency:

```bash
flutter clean
flutter pub get
flutter build android
```

### 3. Test on Android 15

If you have access to Android 15 devices or emulators:

1. Test your app on devices with 16KB page size enabled
2. Monitor memory usage and performance metrics
3. Verify all SMKitUI functionality works as expected

## No Code Changes Required

**Good News**: Version 1.2.9 is fully backward compatible. No code changes are required in your application. All existing APIs and functionality remain unchanged.

## Enhanced Features from Previous Versions

If you're upgrading from versions earlier than 1.2.8, you'll also benefit from:

### Fire-and-Forget Preference Setters (v1.2.8+)

These methods are now fire-and-forget (don't use `await`):

```dart
// ✅ Correct way (v1.2.8+)
_smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english);
_smkitUiFlutterPlugin.setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly);
_smkitUiFlutterPlugin.setEndExercisePreferences(endExercisePrefernces: SMKitEndExercisePreferences.targetBased);
```

### Enhanced User Data Support

Improved user data handling:

```dart
userData: {
  'gender': 'male', // or 'female', 'idle' (case-insensitive)
  'birthday': DateTime(1990, 1, 1).millisecondsSinceEpoch,
  'email': 'user@example.com', // optional
  'height': 175, // in cm, optional
  'weight': 70,  // in kg, optional
}
```

## Benefits of v1.2.9

- **Android 15 Ready**: Full compatibility with Android 15's 16KB page size
- **Performance Optimized**: Better memory management on modern Android devices
- **Zero Breaking Changes**: Seamless upgrade with no code modifications needed
- **Future-Proof**: Ready for upcoming Android updates and requirements
- **Enhanced Stability**: Improved native library performance

## Platform Compatibility

### Supported Platforms
- **Android**: API level 21+ with full Android 15 support
- **iOS**: iOS 11.0+ (unchanged)
- **Flutter**: SDK 3.5.0+ (unchanged)

### Android 15 Specific Features
- 16KB page size compatibility
- Optimized native library loading
- Enhanced memory alignment
- Improved garbage collection efficiency

## Testing Recommendations

### Before Deployment

1. **Memory Testing**: Use Flutter's memory profiling tools to verify memory usage
2. **Device Testing**: Test on various Android devices, especially Android 15+
3. **Performance Monitoring**: Check app startup times and runtime performance
4. **Regression Testing**: Ensure all existing features work as expected

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
```

#### Memory Issues on Android 15
If you experience memory-related issues:

1. Ensure you're using version 1.2.9
2. Clean and rebuild your project
3. Test on devices with different page sizes
4. Check native library compatibility

### Getting Help

If you encounter issues during migration:

1. Check the [Error Handling Guide](errorHandling.md)
2. Review your implementation against the updated examples
3. Contact support with specific error messages and device information

## Complete Example

Here's a complete example using v1.2.9:

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

  void _startAssessment() {
    _smkitUiFlutterPlugin.startAssessment(
      type: AssessmentTypes.fitness,
      userData: {
        'gender': 'male',
        'birthday': DateTime(1990, 1, 1).millisecondsSinceEpoch,
      },
      onHandle: (status) {
        debugPrint('Assessment status: ${status.operation}');
        // Handle results
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SMKitUI v1.2.9 Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: _startAssessment,
          child: Text('Start Assessment'),
        ),
      ),
    );
  }
}
```

## Summary

Version 1.2.9 is a seamless upgrade that brings essential Android 15 compatibility without requiring any code changes. The update ensures your app remains compatible with the latest Android devices while maintaining all existing functionality.

Key benefits:
- ✅ Android 15 16KB page size compatibility
- ✅ Zero breaking changes
- ✅ Enhanced performance and stability
- ✅ Future-proof compatibility
- ✅ Backward compatibility maintained
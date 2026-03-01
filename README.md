
# SMKitUI SDK - Demo App

## Usage

To use SMKitUI in your project, add these dependencies to your application in your `pubspec.yaml` file.

```yaml
dependencies:
  flutter_smkit_ui: ^1.4.0
```

## 🆕 What's New

### v1.4.0 - Skeleton Customization, Pause Menu & Native SDK Upgrades

- **Android SDK**: Upgraded native SMKitUI to 1.5.0
- **iOS SDK**: Upgraded native SMKitUI to 1.5.0

✅ Multiple new exercises — check our movement catalog
🖐️ Pause by hovering palm over pause-menu icons (gesture-driven selection, no tap required)
🧠 Intelligence rest and exercise modification suggestions — automatically detects fatigue and recommends in-session rest
🦴 Full skeleton visualisation customisation system (presets, connection styles, joint shapes, colors, glow, opacity, and more)

**New Features**:
- **💀 Skeleton Customization**: Full control over the pose skeleton appearance via `setConfig` / `SMKitConfig`
  - Choose from 26 presets (e.g. `neonGlow`, `hologram`, `premium`, `accessibility`)
  - Control connection style (solid, dashed, dotted, rounded, etc.)
  - Control joint shape (circle, square, diamond, triangle, hexagon, star)
  - Fine-tune opacity, glow, line width, outline scale, softness, and colors for dots and connections
  - Hide skeleton entirely with `hidden: true`
  - Live preview in the new **UI Settings** screen in the demo app

- **⏸️ Pause Menu Configuration**: Control which buttons appear on the pause overlay via `pauseTypes` in `SMKitConfig`
  - Available types: `resume`, `startOver`, `skip`, `quit`, `rest` (Android only), `switchExercise` (Android only)

- **🔊 Audio & Session Config**: `SMKitConfig` now exposes `allowAudioMixing` and `showExternalAudioControl`

- **🧠 Intelligence Rest**: `enableIntelligenceRest` now uses the public `setIntelligenceRestEnabled()` API (Android), replacing the previous reflection-based approach

- **📊 Progress & Counters**: `showProgressBar` and `showCounters` added to the `modifications` map

**Bug Fixes**:
- Fixed crash on Android when network is unavailable during SDK configuration (`ConnectException` was not caught, causing a fatal crash on the main thread)

### v1.3.7 - Native SDK Updates
- **📱 Android SDK**: Upgraded SMKitUI to 1.4.7 for improved functionality and stability

### v1.3.6 - Platform improvements and stability enhancements
- Better synchronization and initialization handling
- Improved reliability across Android and iOS platforms

### v1.3.5
In Android, the SDK automatically selects the best pose estimation model based on device capabilities - Pro for maximum accuracy, Lite and UltraLite for smooth real-time performance on lower-end devices.

### v1.3.4 - Phone Calibration & Color Theme Customization

**New Features**:
- **🎨 Color Theme Customization**: Customize UI theme colors via `primaryColor` in modifications parameter
  - Supports 8 predefined themes: green, blue, orange, purple, red (maps to orange), silver, gold, and pink
  - Set via hex color codes (e.g., `'#4CAF50'` for green)
  - Applied globally across the SDK UI

- **📱 Phone Calibration Control**: Control phone calibration screen visibility via `phoneCalibration` settings
  - Show/hide calibration screen with `enabled` boolean
  - Additional settings: `autoCalibrate` and `calibrationSensitivity` (for future use)
  - Default: `true` (calibration screen shown by default)

### v1.3.0 - Android 15 & 16 Compatibility

**Android 15 & 16 Compatibility**: Version 1.3.0 includes full support for Android 15 and Android 16 (API 36) with 16KB page size compatibility, ensuring optimal performance on the latest Android devices.

**Key Updates**:
- Upgraded Android SMKitUI to version 1.3.9
- Modern build tools: Android Gradle Plugin 8.11.1 and Gradle 8.11.1/8.13
- Kotlin 2.0.21 for improved compilation speed
- Updated compileSdk to 36 (Android 16) for future-proof development

## ⚠️ Breaking Changes in v1.2.8+

**Important**: Preference setter methods (`setSessionLanguage`, `setCounterPreferences`, `setEndExercisePreferences`) no longer need to be awaited. Remove `await` from these calls to prevent hanging issues.

```dart
// ❌ Old way (v1.2.7 and earlier) - causes hanging
await _smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english);

// ✅ New way (v1.2.8+) - fire-and-forget
_smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english);
```

### Setup

- [Android Setup](docs/android-setup.md)
- [iOS Setup](docs/ios-setup.md)

## Initialization

To initialize SMKitUI in your app, use the dedicated Flutter plugin:

```dart
import 'package:flutter_smkit_ui/flutter_smkit_ui_plugin.dart';

final _smkitUiFlutterPlugin = SmkitUiFlutterPlugin();
await _smkitUiFlutterPlugin.configure(key: "YOUR_AUTH_KEY");
```

Also, when `initState()` is being initialized, please call this function in order to make sure the platform messages are asynchronous:

```dart
Future<void> initPlatformState() async {
  if (!mounted) return;
  setState(() {});
}
```

## API Guides

- [Start Assessment](docs/startAssessment.md) - Step-by-step guide for Blueprint assessments
- [Start Custom Workout](docs/startCustomWorkout.md) - Creating and running custom workouts
- [Start Customized Assessment](docs/startCustomizedAssessment.md) - Building custom assessments
- [Error Handling](docs/errorHandling.md) - Comprehensive error handling strategies
- [Migration Guide v1.4.0](docs/migration-v1.4.0.md) - Upgrade from previous versions (latest)
- [Migration Guide v1.3.0](docs/migration-v1.3.0.md) - Previous version upgrade guide
- [Migration Guide v1.2.9](docs/migration-v1.2.9.md) - Earlier version upgrade guide
- [Migration Guide v1.2.8](docs/migration-v1.2.8.md) - Earlier version upgrade guide

Each guide contains:
- Step-by-step instructions
- All available options (setters)
- Outputs and error handling
- Example code

## Assessment Types

Sency offers two primary types of assessments:

- **Sency Blueprint Assessments:** Developed in collaboration with Sency’s medical and fitness experts, these assessments provide a standardized, professional way to measure core aspects of movement, fitness, and a healthy lifestyle. See [Start Assessment](docs/startAssessment.md).
- **Sency Customized Assessments:** Create a customized evaluation using the exercises and movements from our movement catalog, according to your specific requirements. See [Start Customized Assessment](docs/startCustomizedAssessment.md).

## Advanced Options

### Session Preferences

You can customize the SDK behavior using setters before starting an assessment or workout.

**⚠️ Important for v1.2.8+**: These methods are now fire-and-forget (don't use `await`):

- `_smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english)`
- `_smkitUiFlutterPlugin.setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly)`
- `_smkitUiFlutterPlugin.setEndExercisePreferences(endExercisePrefernces: SMKitEndExercisePreferences.targetBased)`

### UI Customization (v1.3.3+)

Customize the SDK UI through the `modifications` parameter when starting assessments or workouts.

**Phone Calibration**: Control the phone calibration screen.

See the relevant guide for details.

## Migration from Previous Versions

If you're upgrading from an earlier version, please see the [Migration Guide v1.4.0](docs/migration-v1.4.0.md) for the latest upgrade instructions, including skeleton customization, pause menu configuration, and the native SDK 1.5.0 upgrades.

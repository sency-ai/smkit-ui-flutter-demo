
# SMKitUI SDK - Demo App

## Usage

To use SMKitUI in your project, add these dependencies to your application in your `pubspec.yaml` file.

```yaml
dependencies:
  flutter_smkit_ui: ^1.2.8
```

## ⚠️ Breaking Changes in v1.2.8

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
- [Migration Guide v1.2.8](docs/migration-v1.2.8.md) - Upgrade from previous versions

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

You can customize the SDK behavior using setters before starting an assessment or workout.

**⚠️ Important for v1.2.8**: These methods are now fire-and-forget (don't use `await`):

- `_smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english)`
- `_smkitUiFlutterPlugin.setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly)`
- `_smkitUiFlutterPlugin.setEndExercisePreferences(endExercisePrefernces: SMKitEndExercisePreferences.targetBased)`

See the relevant guide for details.

## Migration from Previous Versions

If you're upgrading from an earlier version, please see the [Migration Guide v1.2.8](docs/migration-v1.2.8.md) for important breaking changes and upgrade instructions.

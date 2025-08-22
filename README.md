
# SMKitUI SDK - Demo App

## Usage

To use SMKitUI in your project, add these dependencies to your application in your `pubspec.yaml` file.

```yaml
dependencies:
  flutter_smkit_ui: ^0.2.6
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

- [Start Assessment](docs/startAssessment.md)
- [Start Custom Workout](docs/startCustomWorkout.md)
- [Start Customized Assessment](docs/startCustomizedAssessment.md)

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

You can customize the SDK behavior using setters before starting an assessment or workout:

- `setSessionLanguage(language: SMKitLanguage.english)`
- `setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly)`
- `setEndExercisePreferences(endExercisePrefernces: SMKitEndExercisePreferences.targetBased)`

See the relevant guide for details.

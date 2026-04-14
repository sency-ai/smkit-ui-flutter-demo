
# SMKitUI SDK - Demo App

## Usage

To use SMKitUI in your project, add these dependencies to your application in your `pubspec.yaml` file.

```yaml
dependencies:
  flutter_smkit_ui: ^1.4.6
```
### Setup

- [Android Setup](docs/android-setup.md)
- [iOS Setup](docs/ios-setup.md)

## Initialization

To initialize SMKitUI in your app, use the dedicated Flutter plugin:

```dart

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

**Instruction video configuration**: Use `setConfig` with `instructionVideoConfig: InstructionVideoConfig(displayMode: ..., mediumSizeCycles: 1–5)`. See the commented example in `lib/main.dart` for all options.

See the relevant guide for details.

## Migration from Previous Versions

If you're upgrading from an earlier version, please see the [Migration Guide v1.4.0](docs/migration-v1.4.0.md) for the latest upgrade instructions, including skeleton customization, pause menu configuration, and the native SDK 1.5.0 upgrades.

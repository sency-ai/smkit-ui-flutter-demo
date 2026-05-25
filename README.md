# [smkit-ui-flutter-demo](https://github.com/sency-ai/smkit-sdk)

This demo is aligned with `flutter_smkit_ui` `1.4.8`.

Native versions used by the Flutter SDK:
- iOS: `SMKitUI` / `SMKit` `1.9.1`
- Android: `com.sency.smkitui:smkitui` / `com.sency.smkit:smkit` `1.6.5`

The app mirrors the native iOS demo structure with a Settings screen, a Build Workout flow, assessment examples, custom assessment examples, and workout-from-program examples.

## Table of Contents

1. [Installation](#installation)
2. [Setup](#setup)
3. [Configure](#configure)
4. [Start](#start)
5. [UI Customization and Phone Calibration](#ui-customization-and-phone-calibration)
6. [Excluding Feedback](#excluding-feedback)
7. [Setting Text Language](#setting-text-language)
8. [Setting Pause Types](#setting-pause-types)
9. [Advanced Configuration](#advanced-configuration)
10. [Exercise and Workout Options](#exercise-and-workout-options)
11. [Platform Notes](#platform-notes)
12. [Customer Update](#customer-update)

## Installation

Add the Flutter package to your app:

```yaml
dependencies:
  flutter_smkit_ui: ^1.4.8
```

Run:

```sh
flutter pub get
```

## Setup

- [Android Setup](docs/android-setup.md)
- [iOS Setup](docs/ios-setup.md)

The native setup must include camera permissions and the platform-specific dependency setup described in those guides.

## Configure

Configure SMKitUI as early as possible, usually on app launch:

```dart
final smkit = SmkitUiFlutterPlugin();

await smkit.configure(
  key: 'YOUR_AUTH_KEY',
  includesHighlights: false,
);
```

To reduce wait time, call `configure` before the user starts an assessment or workout.

**Important:** SMKitUI will not start a session until `configure` succeeds.

## Start

The demo includes examples for the main SDK entry points:

- [Start Assessment](docs/startAssessment.md)
- [Start Custom Workout](docs/startCustomWorkout.md)
- [Start Customized Assessment](docs/startCustomizedAssessment.md)
- Workout From Program, implemented in [lib/main.dart](lib/main.dart)
- Build Workout, implemented in [lib/WorkoutBuilderScreen.dart](lib/WorkoutBuilderScreen.dart)

### Start Assessment

```dart
await smkit.startAssessment(
  type: AssessmentTypes.fitness,
  showSummary: true,
  modifications: {
    'primaryColor': '#4CAF50',
    'phoneCalibration': {'enabled': true},
  },
  onHandle: handleSmkitEvent,
);
```

### Start a Custom Workout

```dart
final workout = SMKitWorkout(
  id: 'demo-workout',
  name: 'Demo Workout',
  workoutIntro: null,
  exercises: [
    SMKitExercise(
      prettyName: 'Squat Regular',
      totalSeconds: 30,
      videoInstruction: 'SquatRegularInstructionVideo',
      uiElements: const [
        SMKitUIElement.timer,
        SMKitUIElement.repsCounter,
        SMKitUIElement.gaugeOfMotion,
      ],
      detector: 'SquatRegular',
    ),
  ],
);

await smkit.startCustomizedWorkout(
  workout: workout,
  modifications: {
    'phoneCalibration': {'enabled': true},
  },
  onHandle: handleSmkitEvent,
);
```

## UI Customization and Phone Calibration

Use the `modifications` map when starting a session to customize simple UI values and phone calibration:

```dart
final modifications = {
  'primaryColor': '#4CAF50',
  'phoneCalibration': {
    'enabled': true,
  },
  'showProgressBar': true,
  'showCounters': true,
};
```

The demo keeps these values in `DemoSettings` and applies them to assessments, custom workouts, custom assessments, and workout-from-program sessions.

## Excluding Feedback

You can exclude feedback from the in-session UI:

```dart
await smkit.setFeedbacksUiToExclude(
  feedbacks: ['PushupKneesOnFloor'],
);
```

You can also exclude feedback from data and UI where supported:

```dart
await smkit.setExcludedFeedbacks(
  feedbacks: ['PushupKneesOnFloor'],
);
```

Platform note: data-level feedback exclusion depends on the native platform support. UI-only exclusion is the safer cross-platform default.

## Setting Text Language

Set session text and phone calibration text before starting a session:

```dart
await smkit.setSessionLanguage(language: SMKitLanguage.english);
await smkit.setPhoneCalibrationLanguage(language: SMKitLanguage.english);
```

Currently advertised demo languages are English and Hebrew.

## Setting Pause Types

Choose the pause dialog buttons before a session starts:

```dart
await smkit.setConfig(
  config: const SMKitConfig(
    pauseTypes: [
      SMKitPauseType.resume,
      SMKitPauseType.skip,
      SMKitPauseType.quit,
    ],
  ),
);
```

## Advanced Configuration

Set advanced SDK behavior before starting a session. The demo exposes these controls in the UI Settings screen.

```dart
await smkit.setConfig(
  config: const SMKitConfig(
    enableIntelligenceRest: true,
    enableHeartRateRest: true,
    heartRateRestThreshold: 160,
    allowAudioMixing: true,
    showExternalAudioControl: true,
    playPhoneCalibrationAudio: true,
    playBodyCalibrationAudio: true,
    enableButtonTutorial: true,
    enableWatchCompanion: true,
    startTimerOnFirstActivity: true,
    enablePhoneMovementCountPrevention: true,
    enableVariationMismatchFeedback: true,
    workoutContinuationTimerDuration: 8,
    colorTheme: SMKitColorTheme.green,
    instructionVideoConfig: InstructionVideoConfig(
      displayMode: InstructionVideoDisplayMode.mediumCycle,
      mediumSizeCycles: 3,
    ),
    skeletonConfig: SkeletonConfig(
      hidden: false,
      preset: SkeletonPreset.neonGlow,
      connectionStyle: SkeletonConnectionStyle.solid,
      jointShape: SkeletonJointShape.circle,
      dotsOpacity: 1,
      connectionsOpacity: 0.8,
    ),
    useDefaultGuidanceMode: true,
    guidanceDebugLogging: false,
  ),
);
```

### Android Guidance Config

Android also supports an optional native config string:

```dart
await smkit.setConfig(
  config: const SMKitConfig(
    androidConfigString: 'key=value',
  ),
);
```

### Runtime Controls

```dart
await smkit.quitWorkout();
await smkit.clearAdaptiveRomCache();
```

Platform note: `pauseSdk()` and `resumeSdk()` are iOS-only. On Android, use the in-session pause UI.

## Exercise and Workout Options

The Build Workout screen starts empty, loads supported movements on iOS, falls back to the demo catalog on Android, filters out Rowing, and lets you add, remove, reorder, configure, and start exercises.

The builder exposes:
- Duration
- Phone position
- Guidance mode
- Short intro
- Pre-exercise countdown audio
- Rep milestone voice and interval
- Sound on each rep
- Adaptive ROM feedback and warmup reps
- Stretch-set repetitions, seconds, and rest
- Workout continuation

The Android demo intentionally does not show wide-angle camera because that control is iOS-only.

### Adaptive ROM

```dart
SMKitExercise(
  prettyName: 'Squat Regular',
  totalSeconds: 30,
  videoInstruction: 'SquatRegularInstructionVideo',
  detector: 'SquatRegular',
  adaptiveRomFeedbackEnabled: true,
  adaptiveRomWarmupReps: 2,
);
```

### Per-Exercise Audio

```dart
SMKitExercise(
  prettyName: 'High Knees',
  totalSeconds: 30,
  videoInstruction: 'HighKneesInstructionVideo',
  detector: 'HighKnees',
  playPreExerciseCountdown: true,
  playRepMilestoneVoice: true,
  repMilestoneInterval: 5,
  playSoundOnEachRep: true,
);
```

### Stretch Sets

```dart
SMKitExercise(
  prettyName: 'Downward Dog',
  totalSeconds: 40,
  videoInstruction: 'DownwardDogStretchInstructionVideo',
  detector: 'DownwardDogStretch',
  stretchSetConfig: const SMKitStretchSetConfig(
    repetitions: 3,
    secondsPerStretch: 8,
    restSecondsBetweenStretches: 4,
  ),
);
```

### Workout Continuation

```dart
final continuation = SMKitWorkoutContinuation(
  introSoundKey: null,
  interactionUnlockSoundKey: '',
  exercises: [
    SMKitExercise(
      prettyName: 'Jumping Jacks',
      totalSeconds: 20,
      videoInstruction: 'JumpingJacksInstructionVideo',
      detector: 'JumpingJacks',
    ),
  ],
);

final workout = SMKitWorkout(
  id: 'built-workout',
  name: 'Built Workout',
  workoutIntro: null,
  exercises: [stretchExercise],
  continuation: continuation,
);
```

The demo Build Workout mode does not attach custom workout sounds.

## Platform Notes

- iOS-only: `pauseSdk`, `resumeSdk`, `getSupportedMovements`, `getExerciseType`, `includesHighlights`, exercise `useWideAngleCamera`, watch companion, heart-rate rest, and accurate pose estimation controls.
- Android-only: `clearAdaptiveRomCache`, `androidConfigString`, `poseModelChoice` during `configure`, and pause buttons `rest` / `switchExercise`.
- iOS-focused: audio mixing and external audio control depend on the native iOS audio session behavior.
- Cross-platform: phone calibration, session language, core pause buttons, instruction video config, skeleton styling, adaptive ROM, guidance mode, countdown audio, rep audio, stretch sets, phone movement prevention, variation mismatch feedback, button tutorial, and workout continuation.

Having issues? [Contact us](mailto:support@sency.ai) and let us know what the problem is.

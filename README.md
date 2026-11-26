# [smkit-ui-flutter-demo](https://github.com/sency-ai/smkit-sdk)

This demo uses the `flutter_smkit_ui` `1.6.2` release.

Native versions used by the Flutter SDK:
- iOS: `SMKitUI` / `SMKit` `2.7.3` (iOS 16+)
- Android: `com.sency.smkitui:smkitui` / `com.sency.smkit:smkit` / `com.sency.smbase.nativeclient:smbase-native-client` `1.9.9` (Android 7.0 / API 24+)

The app mirrors the native iOS demo structure with a Settings screen, a Build Workout flow, assessment examples, custom assessment examples, workout-from-program examples, feature examples, SDK tools, live workout controls and an event log.

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
11. [Feature Examples](#feature-examples)
12. [Live Controls and Events](#live-controls-and-events)
13. [SDK Tools](#sdk-tools)
14. [Platform Notes](#platform-notes)

## Installation

Add the Flutter package to your app:

```yaml
dependencies:
  flutter_smkit_ui: 1.6.2
```

Run:

```sh
cp .env.example .env
flutter pub get
```

Enter your auth key in the app or set `API_PUBLIC_KEY` in `.env`. The `.env` file is ignored by Git but is required as a Flutter asset for local builds.

## Setup

- [Android Setup](docs/android-setup.md)
- [iOS Setup](docs/ios-setup.md)
- [Voices and section title vocals](docs/custom-vocals.md)

The native setup must include camera permissions and the platform-specific dependency setup described in those guides.

The demo resolves Flutter 1.6.2 from pub.dev, Android 1.9.9 from the Sency artifact repository, and iOS 2.7.3 through CocoaPods.

## Configure

Configure SMKitUI as early as possible, usually on app launch:

```dart
final smkit = SmkitUiFlutterPlugin();

await smkit.configure(
  key: 'YOUR_AUTH_KEY',
  customerCode: 'YOUR_CUSTOMER_CODE', // optional, for customer assets
  includesHighlights: false,
);
```

To reduce wait time, call `configure` before the user starts an assessment or workout.

`configure` also chooses how models load. These options are read only by `configure`, so the demo's UI Settings › Configure section applies them on the next launch or when you tap Reconfigure SDK:

```dart
await smkit.configure(
  key: 'YOUR_AUTH_KEY',
  poseModelChoice: SmKitPoseModelChoice.adaptiveChoice, // Android only
  // iOS only: Android 1.9.9 rejects non-default values for these two.
  includesObjectDetectionFeedbacks: true,
  modelDownloadPolicy: SMKitModelDownloadPolicy.immediateFallback,
);
```

**Important:** SMKitUI will not start a session until `configure` succeeds.
In the app, `CUSTOMER_CODE` can be supplied in `.env`. UI Settings includes
configure-time voice choices, coaching frequency, diagnostics, and model preload
controls. The result screen shows exercise timing, position-rep data, and assessment
insights when the native SDK returns them. The guidance picker intentionally keeps
its existing detector catalog for this release.

## Start

The demo includes examples for the main SDK entry points:

- [Start Assessment](docs/startAssessment.md)
- [Start Custom Workout](docs/startCustomWorkout.md)
- [Start Customized Assessment](docs/startCustomizedAssessment.md)
- Workout From Program, implemented in [lib/main.dart](lib/main.dart)
- Build Workout, implemented in [lib/WorkoutBuilderScreen.dart](lib/WorkoutBuilderScreen.dart)
- Feature Examples, implemented in [lib/FeatureExamplesScreen.dart](lib/FeatureExamplesScreen.dart)

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

On iOS you can also stop the SDK from detecting a feedback at all. The demo's UI Settings screen has an "Excluded feedbacks" field for this:

```dart
await smkit.setExcludedFeedbacks(
  feedbacks: ['PushupKneesOnFloor'],
);
```

Platform note: `setExcludedFeedbacks` is iOS-only. `setFeedbacksUiToExclude` works on both platforms.

## Setting Text Language

Set session text and phone calibration text before starting a session:

```dart
await smkit.setSessionLanguage(language: SMKitLanguage.english);
await smkit.setPhoneCalibrationLanguage(language: SMKitLanguage.english);
```

The SDK supports English, Hebrew and Mandarin (`SMKitLanguage.mandarin`).

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

### Mobility Flow and Holds

```dart
await smkit.setConfig(
  config: const SMKitConfig(
    mobilityFlowVoice: SMKitVoice.female1,
    mobilityFlowHoldIndicatorStyle: MobilityFlowHoldIndicatorStyle.liquidGlass,
    holdPositionSoundEnabled: true,
    positionExitVocalsEnabled: false,
    // iOS only; Android rejects setConfig when these are present.
    enablePerExerciseBodyCalibration: true,
    showAllSkeletonKeypoints: true,
  ),
);
```

On Android, the voice, hold sound and position-exit vocals take effect after `configure` runs again.

### Object Detection and Rowing (iOS)

```dart
await smkit.setConfig(
  config: const SMKitConfig(
    // Body calibration waits until it sees each required object class.
    enableBodyCalibrationObjectDetection: true,
    bodyCalibrationRequiredObjectClasses: ['YOUR_OBJECT_CLASS'],
    enableObjectDetectionFeedbacks: true,
    showRowingPhoneCalibration: true,
  ),
);
```

The demo's "Object detection feedbacks" switch sets both `enableObjectDetectionFeedbacks` and configure's `includesObjectDetectionFeedbacks`. Android rejects `setConfig` when the object-detection keys are present, so the demo sends them only on iOS.

### Runtime Controls

```dart
await smkit.quitWorkout();
await smkit.pauseSdk();
await smkit.resumeSdk();
await smkit.clearAdaptiveRomCache(); // Android only
```

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

## Feature Examples

The Feature Examples screen starts one-exercise workouts that show exercise options the builder does not. Each card can also run `prepareWorkout` first to download its assets.

- **Mobility Flow**: a 10-second rhomboid stretch hold, then 3 butterfly reps.

  ```dart
  SMKitExercise.mobilityFlow(const SMKitMobilityFlowConfig([
    SMKitMobilityFlowBlock.hold('RhomboidStretch', repetitions: 1, secondsPerRep: 10),
    SMKitMobilityFlowBlock.reps('ButterflyPose', targetReps: 3),
  ]));
  ```

- **Mobility Flow without the 5-second cue**: two rhomboid stretch holds with `fiveSecondsLeftCueEnabled: false`.
- **Mobility reps**: butterfly pose counted as reps with `mobilityRepConfig: SMKitMobilityRepConfig(targetReps: 6)`.
- **Combination**: `Combo04` with `SMKitCombinationOptions(firstReps: 2, secondReps: 1, fixedSide: SMKitCombinationSide.left)`.
- **Quick motion**: high knees with `SMKitUIElement.quickMotion` and `SMKitQuickMotionParams`.
- **Stretch set with alternating positions**: `LumbarCamelCatSeated` as two sets of 5-second holds. The SDK alternates camel and cat from the detector; `positionDetectors` names both positions in the results.

  ```dart
  stretchSetConfig: const SMKitStretchSetConfig(
    repetitions: 2,
    secondsPerStretch: 5,
    restSecondsBetweenStretches: 3,
    positionDetectors: ['LumbarCamelSeated', 'LumbarCatSeated'],
  ),
  ```

- **Section title with a custom sound**: high knees under a "Cardio" block. `sectionTitleSoundKey` takes an asset key, URL or file path and plays before the exercise intro.

  ```dart
  displayContext: const SMKitExerciseDisplayContext(
    sectionTitle: 'Cardio',
    group: SMKitExerciseDisplayGroup(
      id: 'cardio',
      kind: SMKitExerciseDisplayGroupKind.block,
      number: 1,
    ),
    sectionTitleSoundKey: 'https://example.com/cardio-title.mp3',
  ),
  ```

- **Instruction-rep timing and pace**: squats with `instructionRepTiming`, `paceLimitEnabled: true` and `positionExitVocalsEnabled: false`.

## Live Controls and Events

The demo handles every workout event: `exerciseWillStart`, `exerciseData`, `workoutPreparationDidFinish` and `workoutPreparationDidCancel` are recorded in the Event Log screen, along with live-control results. When a summary arrives, the log also lists its `modifications`: swaps, added rests and other changes made during the workout, with `type`, `source`, `sourceDetector`, `appliedDetector`, `pairedDetector`, `restSeconds` and `timestamp`.

On iOS, turn on UI Settings › Emit diagnostics (iOS) to log each native diagnostic with its name, category, severity, message, timestamp, `errorDomain`, `errorCode` and `properties`. Recovered sessions are logged with `sessionResult` and, on iOS, `workoutSummary`.

The SDK screen covers the app during a workout, so UI Settings › Live Controls picks an action that runs a few seconds after each exercise starts:

| Action | API | Platforms |
|--------|-----|-----------|
| Log live progress | `getLiveWorkoutProgress()` | Both |
| Pause, then resume | `pauseSdk()`, `resumeSdk()` | Both |
| Skip / restart exercise | `skipCurrentExercise()`, `restartCurrentExercise()` | Both |
| Add 2 reps to later sets | `updateFutureExerciseTargets(...)` | Android |
| Insert 30 s rest, styled pause | `getWorkoutCommandToken()`, `performWorkoutCommand(...)` | iOS |

```dart
final token = await smkit.getWorkoutCommandToken();
if (token != null) {
  final result = await smkit.performWorkoutCommand(
    SMKitWorkoutCommand.insertRest(30),
    token: token,
  );
  if (!result.accepted) debugPrint(result.reason);
}
```

## SDK Tools

The SDK Tools screen covers calls that do not start a workout:

- `loadInstructionVideo` and `loadInstructionVideoThumbnail` for a detector.
- `predownloadWorkoutAssets` for a list of detectors, optionally with Mobility Flow assets.
- `consumeRecoveredSessionSummaries`: sessions the SDK saved after a fault or after the app was killed mid-workout. The demo also checks right after `configure`; each session is returned only once.
- `mergeAdaptiveRomPilotCache`: the demo saves each exercise's `adaptiveRom` snapshot from workout summaries to a local file and restores them into the SDK on request.
- `getCustomerAssetPath` (local copy only) and `requestCustomerAssetPath`.
- `setVideo` (iOS): run a session on a recorded video instead of the camera.

## Platform Notes

- iOS-only: `setExcludedFeedbacks`, `setVideo`, `getWorkoutCommandToken`, `performWorkoutCommand`, `includesHighlights`, `includesObjectDetectionFeedbacks`, `modelDownloadPolicy`, `enablePerExerciseBodyCalibration`, `showAllSkeletonKeypoints`, body-calibration object detection, object-detection feedbacks, rowing phone calibration, diagnostics, recovered `workoutSummary`, exercise `useWideAngleCamera`, watch companion, heart-rate rest, and accurate pose estimation controls.
- Android-only: `clearAdaptiveRomCache`, `updateFutureExerciseTargets`, `androidConfigString`, `poseModelChoice` during `configure`, and pause buttons `rest` / `switchExercise`.
- iOS-focused: audio mixing and external audio control depend on the native iOS audio session behavior.
- Cross-platform: `pauseSdk`, `resumeSdk`, live progress, skip and restart, `getSupportedMovements`, `getExerciseType`, Mobility Flow, recovered sessions, phone calibration, session language, core pause buttons, instruction video config, skeleton styling, adaptive ROM, guidance mode, countdown audio, rep audio, stretch sets, phone movement prevention, variation mismatch feedback, button tutorial, and workout continuation.

Having issues? [Contact us](mailto:support@sency.ai) and let us know what the problem is.

# Start Custom Workout Guide

This guide explains how to start a custom workout using the `flutter_smkit_ui` plugin (v1.3.0).

## Step-by-Step: Starting a Custom Workout

1. **Prepare a Workout Object**
   - Use the `SMKitWorkout` and `SMKitExercise` classes to build your workout.
   - You can use local or remote resources for sound and video instructions.

   ```dart
   Future<String> getFileUrl(String fileName) async {
     final byteData = await rootBundle.load(fileName);
     final file = File('${(await getTemporaryDirectory()).path}/$fileName');
     await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
     return file.path;
   }

   Future<SMKitWorkout> getDemoWorkout() async {
     var introURL = await getFileUrl("customWorkoutIntro.mp3");
     var highKneesIntroURL = "https://github.com/sency-ai/smkit-ui-flutter-demo/raw/main/HighKneesSound.mp3";

     List<SMKitExercise> exercises = [
       SMKitExercise(
         prettyName: "HighKnees",
         exerciseIntro: highKneesIntroURL,
         totalSeconds: 30,
         videoInstruction: "https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4",
         uiElements: [SMKitUIElement.timer, SMKitUIElement.repsCounter],
         detector: "HighKnees",
         exerciseClosure: null,
       ),
       // Add more exercises as needed
     ];

     return SMKitWorkout(
       id: "50",
       name: "demo workout",
       workoutIntro: introURL,
       soundTrack: null,
       exercises: exercises,
       getInFrame: null,
       bodycalFinished: null,
       workoutClosure: null,
     );
   }
   ```

## Adding Rest Periods Between Exercises

You can include rest periods between active exercises by using `"Rest"` as the detector type. The SDK will treat this as a rest period, allowing users to recover between exercises.

### Example: Workout with Rest Periods

```dart
Future<SMKitWorkout> getWorkoutWithRest() async {
  var introURL = await getFileUrl("customWorkoutIntro.mp3");
  var restIntroURL = await getFileUrl("restIntro.mp3");
  
  List<SMKitExercise> exercises = [
    SMKitExercise(
      prettyName: "High Knees",
      exerciseIntro: "https://github.com/sency-ai/smkit-ui-flutter-demo/raw/main/HighKneesSound.mp3",
      totalSeconds: 30,
      videoInstruction: "https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4",
      uiElements: [SMKitUIElement.timer, SMKitUIElement.repsCounter],
      detector: "HighKnees",
      exerciseClosure: null,
    ),
    // Add a 15-second rest period
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
      exerciseIntro: "https://example.com/squats-intro.mp3",
      totalSeconds: 30,
      videoInstruction: "https://example.com/squats.mp4",
      uiElements: [SMKitUIElement.timer, SMKitUIElement.repsCounter],
      detector: "Squats",
      exerciseClosure: null,
    ),
    // Another rest period
    SMKitExercise(
      prettyName: "Rest",
      exerciseIntro: restIntroURL,
      totalSeconds: 20,  // 20 seconds rest
      videoInstruction: null,
      uiElements: [SMKitUIElement.timer],
      detector: "Rest",
      exerciseClosure: null,
    ),
    SMKitExercise(
      prettyName: "Lunges",
      exerciseIntro: "https://example.com/lunges-intro.mp3",
      totalSeconds: 30,
      videoInstruction: null,
      uiElements: [SMKitUIElement.timer, SMKitUIElement.repsCounter],
      detector: "Lunges",
      exerciseClosure: null,
    ),
  ];

  return SMKitWorkout(
    id: "workout-with-rest",
    name: "HIIT Workout with Rest",
    workoutIntro: introURL,
    soundTrack: null,
    exercises: exercises,
    getInFrame: null,
    bodycalFinished: null,
    workoutClosure: null,
  );
}
```

**Key Points for Rest Periods**:
- Set `detector: "Rest"` to create a rest period
- Use `totalSeconds` to define the rest duration (typically 10-30 seconds)
- Only include `SMKitUIElement.timer` for UI elements during rest
- `videoInstruction` should be `null` for rest periods
- The SDK will display a rest screen without exercise tracking
- Users can see the countdown timer during the rest period

2. **Start the Custom Workout**
   ```dart
   _smkitUiFlutterPlugin.startCustomaizedWorkout(
     workout: workout,
     onHandle: (status) {
       debugPrint('startCustomWorkout status: ${status.operation} ${status.data}');
       // status.operation => workoutSummaryData, exerciseData, or error
       if (status.data == null) return;
       // Handle the result
     },
   );
   ```

## Options (Setters)

**⚠️ Important for v1.2.8+**: These methods are now fire-and-forget (don't use `await`):

- `_smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english)`
- `_smkitUiFlutterPlugin.setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly)`
- `_smkitUiFlutterPlugin.setEndExercisePreferences(endExercisePrefernces: SMKitEndExercisePreferences.targetBased)`

Call these before starting the workout to customize behavior.

## Outputs

The callback returns a `SencyHandlerStatus` object:
- `operation`: Indicates the type of event (`error`, `workoutSummaryData`, `exerciseData`).
- `data`: The result data (JSON string or object).

## Errors

If an error occurs, `operation` will be `error` and `data` will contain error details.

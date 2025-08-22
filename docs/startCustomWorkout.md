# Start Custom Workout Guide

This guide explains how to start a custom workout using the `flutter_smkit_ui` plugin.

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

- `setSessionLanguage(language: SMKitLanguage.english)`
- `setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly)`
- `setEndExercisePreferences(endExercisePrefernces: SMKitEndExercisePreferences.targetBased)`

Call these before starting the workout to customize behavior.

## Outputs

The callback returns a `SencyHandlerStatus` object:
- `operation`: Indicates the type of event (`error`, `workoutSummaryData`, `exerciseData`).
- `data`: The result data (JSON string or object).

## Errors

If an error occurs, `operation` will be `error` and `data` will contain error details.

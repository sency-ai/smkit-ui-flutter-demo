# Start Customized Assessment Guide

This guide explains how to start a customized assessment using the `flutter_smkit_ui` plugin (v1.2.9).

## Step-by-Step: Starting a Customized Assessment

1. **Prepare an Assessment Object**
   - Use the `SMKitWorkout` and `SMKitExercise` classes to build your assessment.
   - You can use local or remote resources for sound and video instructions.
   - Add scoring parameters for each exercise.

   ```dart
   Future<SMKitWorkout> getDemoAssessment() async {
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
         scoringParams: ScoringParams(
           type: ScoringType.reps,
           scoreFactor: 0.5,
           targetReps: 30,
           targetTime: 0,
           targetRom: "",
         ),
       ),
       // Add more exercises as needed
     ];

     return SMKitWorkout(
       id: "0",
       name: "demo Assessment",
       workoutIntro: introURL,
       soundTrack: null,
       exercises: exercises,
       getInFrame: introURL,
       bodycalFinished: highKneesIntroURL,
       workoutClosure: null,
     );
   }
   ```

2. **Set Options (Setters)**
   - **⚠️ Important for v1.2.8+**: These methods are now fire-and-forget (don't use `await`):
   ```dart
   _smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english);
   _smkitUiFlutterPlugin.setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly);
   _smkitUiFlutterPlugin.setEndExercisePreferences(endExercisePrefernces: SMKitEndExercisePreferences.targetBased);
   ```

3. **Start the Customized Assessment**
   ```dart
   _smkitUiFlutterPlugin.startCustomizedAssessment(
     assessment: assessment,
     onHandle: (status) {
       debugPrint('_startWorkout status: ${status.operation} ${status.data}');
       if (status.operation == SMKitOperation.assessmentSummaryData && status.data != null) {
         final workoutResult = status.data as SMKitAssessmentSummaryData;
         debugPrint('_startWorkout assessmentSummaryData: ${workoutResult.toString()}');
         // Handle the result
       }
     },
   );
   ```

## Outputs

The callback returns a `SencyHandlerStatus` object:
- `operation`: Indicates the type of event (`error`, `assessmentSummaryData`, etc.).
- `data`: The result data (JSON string or object).

## Errors

If an error occurs, `operation` will be `error` and `data` will contain error details.

## ScoringParams

- `type`: ScoringType (e.g., reps, time)
- `scoreFactor`: double
- `targetReps`: int
- `targetTime`: int
- `targetRom`: String

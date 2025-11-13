# Start Customized Assessment Guide

This guide explains how to start a customized assessment using the `flutter_smkit_ui` plugin (v1.3.0).

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

## Adding Rest Periods in Assessments

You can include rest periods between assessment exercises by using `"Rest"` as the detector type. This allows participants to recover between exercises during the assessment.

### Example: Assessment with Rest Periods

```dart
Future<SMKitWorkout> getAssessmentWithRest() async {
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
      scoringParams: ScoringParams(
        type: ScoringType.reps,
        scoreFactor: 0.5,
        targetReps: 30,
        targetTime: 0,
        targetRom: "",
      ),
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
      scoringParams: null,  // No scoring for rest periods
    ),
    SMKitExercise(
      prettyName: "Squats",
      exerciseIntro: "https://example.com/squats-intro.mp3",
      totalSeconds: 30,
      videoInstruction: null,
      uiElements: [SMKitUIElement.timer, SMKitUIElement.repsCounter],
      detector: "Squats",
      exerciseClosure: null,
      scoringParams: ScoringParams(
        type: ScoringType.reps,
        scoreFactor: 0.6,
        targetReps: 20,
        targetTime: 0,
        targetRom: "",
      ),
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
      scoringParams: null,
    ),
    SMKitExercise(
      prettyName: "Plank Hold",
      exerciseIntro: "https://example.com/plank-intro.mp3",
      totalSeconds: 30,
      videoInstruction: null,
      uiElements: [SMKitUIElement.timer],
      detector: "Plank",
      exerciseClosure: null,
      scoringParams: ScoringParams(
        type: ScoringType.time,
        scoreFactor: 1.0,
        targetReps: 0,
        targetTime: 30,
        targetRom: "",
      ),
    ),
  ];

  return SMKitWorkout(
    id: "assessment-with-rest",
    name: "Fitness Assessment with Rest",
    workoutIntro: introURL,
    soundTrack: null,
    exercises: exercises,
    getInFrame: introURL,
    bodycalFinished: "https://example.com/finished.mp3",
    workoutClosure: null,
  );
}
```

**Key Points for Rest Periods in Assessments**:
- Set `detector: "Rest"` to create a rest period
- Use `totalSeconds` to define the rest duration (typically 10-30 seconds)
- Set `scoringParams: null` since rest periods are not scored
- Only include `SMKitUIElement.timer` for UI elements during rest
- `videoInstruction` should be `null` for rest periods
- The SDK will display a rest screen without exercise tracking or scoring
- Rest periods do not contribute to the overall assessment score

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

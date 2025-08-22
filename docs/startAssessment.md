# Start Assessment Guide

This guide explains how to start a Sency Blueprint or Custom Assessment using the `flutter_smkit_ui` plugin.

## Step-by-Step: Starting an Assessment

1. **Configure the Plugin**
   ```dart
   final _smkitUiFlutterPlugin = SmkitUiFlutterPlugin();
   await _smkitUiFlutterPlugin.configure(key: "YOUR_AUTH_KEY");
   ```

2. **Start Assessment**
   ```dart
   _smkitUiFlutterPlugin.startAssessment(
     type: AssessmentTypes.fitness, // or any AssessmentTypes value
     assessmentID: "YOUR_ASSESSMENT_ID", // optional for custom assessments
     userData: {
       'gender': 'Male',
       'birthday': DateTime(1990, 1, 1).millisecondsSinceEpoch,
     },
     showSummary: true, // optional
     onHandle: (status) {
       debugPrint('_startAssessment status: [32m${status.operation}[0m [34m${status.data}[0m');
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

Call these before starting the assessment to customize behavior.

## Outputs

The callback returns a `SencyHandlerStatus` object:
- `operation`: Indicates the type of event (`error`, `workoutSummaryData`, `exerciseData`).
- `data`: The result data (JSON string or object).

## Errors

If an error occurs, `operation` will be `error` and `data` will contain error details.

## Assessment Types

| Name      | Description |
|-----------|-------------|
| fitness   | Standard fitness assessment |
| body360   | Full body assessment |
| strength  | Strength assessment |
| cardio    | Cardio assessment |
| custom    | Custom assessment |

See the main README for more details and links.

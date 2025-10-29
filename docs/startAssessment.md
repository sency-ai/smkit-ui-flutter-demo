# Start Assess   _smkitUiFlutterPlugin.startAssessment(
     type: AssessmentTypes.fitness, // or any AssessmentTypes value
     assessmentID: "YOUR_ASSESSMENT_ID", // optional for custom assessments
     userData: {
       'gender': 'male', // or 'female', 'idle' (case-insensitive)
       'birthday': DateTime(1990, 1, 1).millisecondsSinceEpoch,
       'email': 'user@example.com', // optional
     },
     showSummary: true, // optional
     onHandle: (status) {
       debugPrint('_startAssessment status: ${status.operation} ${status.data}');
       // status.operation => workoutSummaryData, exerciseData, or error
       if (status.data == null) return;
       // Handle the result
     },
   );

# Start Assessment

This guide explains how to start a Sency Blueprint or Custom Assessment using the `flutter_smkit_ui` plugin (v1.2.9).

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

**⚠️ Important for v1.2.8+**: These methods are now fire-and-forget (don't use `await`):

- `_smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english)`
- `_smkitUiFlutterPlugin.setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly)`
- `_smkitUiFlutterPlugin.setEndExercisePreferences(endExercisePrefernces: SMKitEndExercisePreferences.targetBased)`

Call these before starting the assessment to customize behavior.

## User Data Options

| Field      | Type     | Required | Description                           | Example                             |
|------------|----------|----------|---------------------------------------|-------------------------------------|
| gender     | String   | Yes      | 'male', 'female', or 'idle' (case-insensitive) | 'Male'                    |
| birthday   | int      | Yes      | Milliseconds since epoch              | `DateTime(1990, 1, 1).millisecondsSinceEpoch` |
| email      | String   | No       | User's email address                  | 'user@example.com'                  |

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
| custom    | Custom assessment (requires assessmentID) |

## Platform Details

- **Android**: Converts `birthday` to `age`, maps `gender` string to enum, supports both lowercase and capitalized values.
- **iOS**: Uses `gender` and `birthday` directly for native SDK.
- **Both**: Accept `showSummary` argument from Flutter.

See the main README for more details and links.

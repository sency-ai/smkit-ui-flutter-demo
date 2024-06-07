# SMKitUI SDK - Demo App

### [Usage](#usage)
* [Initialization](#initialization)
* [Android](#Android)

### [API](#api)
* [Start Assessment](#start-assessment)
* [Start Custom Workout](#start-custom-workout)

## Usage
To use SMKitUI in your project, add these dependencies to your application in your `pubspec.yaml` file.
```yaml
dependencies:
  smkit_ui_flutter_plugin: ^0.1.0
```

### Initialization
To initialize SMKitUI in your App, You need to use the dedicated flutter plugin 
```dart
import 'package:smkit_ui_flutter_plugin/smkit_ui_flutter_plugin.dart';

final _smkitUiFlutterPlugin = SmkitUiFlutterPlugin();
_smkitUiFlutterPlugin.configure(key: "YOUR_AUTH_KEY")
```

Also when `initState()` is being initialized please call this function in order to make sure the Platform messages are asynchronous.
We can achive that by initialize the state in an async method.

```dart
 Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }
```
### Android
In order to be compatible with SMKitUI, the Android project should make some changes.

At `gradle-wrapper.properties` please change gradle version to be 8^.

```groovy
  distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-bin.zip
```

Under `gradle.properties` on project level add the following: 

```groovy
  SMKitUI_Version = 0.1.1
  artifactory_contentUrl = 'https://artifacts.sency.ai/artifactory/release'
```

And please make sure your kotlin_version is at least 1.9
```groovy
  buildscript {
    ext.kotlin_version = '1.9.24'
  }
```

## API
### Start Assessment
Start the Assessment screen. In the parameters method `startAssessment()` You can add `SencyHandlerStatus` to track the success of the method. 
You need to process the result that the methods return in the callback.

Please make sure you call `startAssessment()` only after configuring the plugin with your "AUTH_KEY".
```dart
  // Under Button Widget of sort
  onPressed: () {
    _smkitUiFlutterPlugin.startAssessment(
      onHandle: (status) {
        debugPrint('_startAssessment status: ${status.operation} ${status.data}');
        if (status.operation != SencyOperation.workoutSummaryData && status.data == null) return;

        final workoutResult = status.data;
        debugPrint('_startAssessment workoutResult: $workoutResult');
        
        if (workoutResult == null || workoutResult.isEmpty) return;
        // Handle the Result
      },
    );
  }
```

`SencyHandlerStatus` object is a representative for the comminucation between Platform-to-Dart inside Sency's flutter plugin.
The comminucation is being done by json serialize and deserialize by EventSink native flutter object.
Here is a sneek peek to `SencyHandlerStatus` object: 

```dart
  enum SencyOperation {
    error,
    workoutSummaryData,
    exerciseData;
  }

  class SencyHandlerStatus {
    final SencyOperation operation;
    final String? data;
  }
```

Please address the code for further reading

### Start Custom Workout
Start the workout screen with custom workout. In the parameters method `startCustomWorkout()` add the `SencyHandlerStatus` listener as explained above. To track the success of the method or get the expected
data, you need to process the result that the methods return to the callback.
```dart
SMWorkout getDemoWorkout() {
    List<SMExercise> exercises = [
      SMExercise(
        name: "First Exercise", // => name:string | null
        totalSeconds: 35, // => totalSeconds: int | null
        introSeconds: 5, // => introSeconds: int | null
        videoInstruction: null,  // => videoInstruction: string | null (url for a video)
        exerciseIntro: null, // => exerciseIntro: string | null (url for a sound)
        uiElements: [UIElement.RepsCounter, UIElement.GaugeOfMotion], // => uiElements: UIElement[] | null
        detector: "HighKnees",  // => detector: string
        repBased: true, // => repBased: bool | null
        exerciseClosure: null, // => exerciseClosure: string | null (url for a sound)
        targetReps: 13, // => targetReps: int | null
        targetTime: 20, // => targetTime: int | null
        scoreFactor: 0.3, // => scoreFactor: double | null
      ),
      SMExercise(
        name: "Second Exercise",
        totalSeconds: 25,
        introSeconds: 5,
        videoInstruction: null,
        exerciseIntro: null,
        uiElements: [UIElement.GaugeOfMotion, UIElement.Timer],
        detector: "SquatRegularOverheadStatic",
        repBased: false,
        exerciseClosure: null,
        targetReps: null,
        targetTime: 20,
        scoreFactor: 0.3,
      ),
    ];

    return SMWorkout(
      id: "50", // => id: string | null
      name: "demo workout", // => name: string | null
      workoutIntro: null, // => workoutIntro: string | null (url for a sound)
      soundTrack: null, // => soundtrack: string | null (url for a sound)
      exercises: exercises, // => exercises: SMExercise[]
      getInFrame: null, // =>  getInFrame: string | null (url for a sound)
      bodycalFinished: null, // =>  bodycalFinished: string | null (url for a sound)
      workoutClosure: null, // =>  workoutClosure: string | null (url for a sound)
    );
}

// Under Button widget of sort 
onPressed: () {
  _smkitUiFlutterPlugin.startCustomWorkout(
    workout: getDemoWorkout(
      onHandle: (status) {
        debugPrint('startCustomWorkout status: ${status.operation} ${status.data}');
        if (status.operation != SencyOperation.workoutSummaryData && status.data == null) return;

        final workoutResult = status.data;
        debugPrint('startCustomWorkout workoutResult: $workoutResult');
        
        if (workoutResult == null || workoutResult.isEmpty) return;
        // Handle the Result
      },
    ),
  );
}
```

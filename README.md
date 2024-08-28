# SMKitUI SDK - Demo App

### [Usage](#usage)
* [Setup](#Setup)
* [Initialization](#initialization)

### [API](#api)
* [Assessment](#assessment)
* [Start Assessment](#start-assessment)
* [Start Custom Workout](#start-custom-workout)
* [Start Custom Assessment](#start-custom-assessmet)

## Usage <a name="usage"></a>
To use SMKitUI in your project, add these dependencies to your application in your `pubspec.yaml` file.
```yaml
dependencies:
flutter_smkit_ui: ^0.1.7
```

### Setup <a name="Setup"></a>
* [Android](https://github.com/sency-ai/smkit-ui-flutter-demo/blob/main/docs/android-setup.md)
* [iOS](https://github.com/sency-ai/smkit-ui-flutter-demo/blob/main/docs/ios-setup.md)


### Initialization <a name="initialization"></a>
To initialize SMKitUI in your App, You need to use the dedicated flutter plugin 
```dart
import 'package:flutter_smkit_ui/flutter_smkit_ui_plugin.dart';

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

## API <a name="api"></a>
### Assessment <a name="assessment"></a>
>Sency offers two primary types of assessments: Sency Blueprint assessments and Custom assessments.

>**Sency Blueprint Assessments:** Developed in collaboration with Sency’s medical and fitness experts, these assessments provide a standardized, professional way to measure core aspects of movement, fitness, and a healthy lifestyle. Simply follow the "start assessment" instructions and select the type of assessment you need.

>**Sency Custom Assessments:** For those who prefer to tailor their assessments, you can create a customized evaluation using the exercises and movements from our movement catalog, according to your specific requirements (check the CustomAssessment.md file for more info).

### Start Assessment <a name="start-assessment"></a>
Start the Assessment screen. In the parameters method `startAssessment()` You can add `SencyHandlerStatus` to track the success of the method. 
You need to process the result that the methods return in the callback.

Please make sure you call `startAssessment()` only after configuring the plugin with your "AUTH_KEY".
```dart
  // Under Button Widget of sort
  onPressed: () {
     _smkitUiFlutterPlugin.startAssessment(
      type: AssessmentTypes.custom,
      assessmentID: "YOUR_ASSESSMENT_ID", // If you don't have an assessment ID, please omit this line
      onHandle: (status) {
        debugPrint('_startAssessment status: ${status.operation} ${status.data}');
        // status.operation => workoutSummrayData, exerciseData or error
        if (status.data == null) return;

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

### Start Custom Workout <a name="start-custom-workout"></a>
Start the workout screen with custom workout. In the parameters method `startCustomWorkout()` add the `SencyHandlerStatus` listener as explained above. To track the success of the method or get the expected
data, you need to process the result that the methods return to the callback.
```dart

// Add path_provider package
import 'package:path_provider/path_provider.dart';

Future<String> getFileUrl(String fileName) async {
  final byteData = await rootBundle.load(fileName);
  final file = File('${(await getTemporaryDirectory()).path}/$fileName');
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  return file.path;
}

Future<SMKitWorkout> getDemoWorkout() async{
    var introURL = await getFileUrl("customWorkoutIntro.mp3"); // local sound url
    var highKneesIntroURL = "https://github.com/sency-ai/smkit-ui-flutter-demo/raw/main/HighKneesSound.mp3"; // remoth sound url

    List<SMExercise> exercises = [
      SMExercise(
        name: "First Exercise", // => name:string | null
        totalSeconds: 35, // => totalSeconds: int | null
        videoInstruction: null,  // => videoInstruction: string | null (url for a video)
        exerciseIntro: highKneesIntroURL, // => exerciseIntro: string | null (url for a sound)
        uiElements: [UIElement.RepsCounter, UIElement.GaugeOfMotion], // => uiElements: UIElement[] | null
        detector: "HighKnees",  // => detector: string
        repBased: true, // => repBased: bool | null
        exerciseClosure: null // => exerciseClosure: string | null (url for a sound)
      ),
      SMExercise(
        name: "Second Exercise",
        totalSeconds: 25,
        videoInstruction: null,
        exerciseIntro: null,
        uiElements: [UIElement.GaugeOfMotion, UIElement.Timer],
        detector: "SquatRegularOverheadStatic",
        repBased: false,
        exerciseClosure: null
      ),
    ];

    return SMWorkout(
      id: "50", // => id: string | null
      name: "demo workout", // => name: string | null
      workoutIntro: introURL, // => workoutIntro: string | null (url for a sound)
      soundTrack: null, // => soundtrack: string | null (url for a sound)
      exercises: exercises, // => exercises: SMExercise[]
      getInFrame: null, // =>  getInFrame: string | null (url for a sound)
      bodycalFinished: null, // =>  bodycalFinished: string | null (url for a sound)
      workoutClosure: null, // =>  workoutClosure: string | null (url for a sound)
    );
}

void startCustomWorkout() async{
    var workout = await getDemoWorkout();
    
    _smkitUiFlutterPlugin.startCustomWorkout(
        workout: workout,
        onHandle: (status) {
            debugPrint('startCustomWorkout status: ${status.operation} ${status.data}');
            // status.operation => workoutSummrayData, exerciseData or error
            if (status.data == null) return;
    
            final workoutResult = status.data;
            debugPrint('startCustomWorkout workoutResult: $workoutResult');
        
            if (workoutResult == null || workoutResult.isEmpty) return;
            // Handle the Result
    },
  );
}

// Under Button widget of sort 
onPressed: () {
  startCustomWorkout();
}
```
### Start Custom Assessment <a name="start-custom-assessmet"></a>
The custom assessment enables you to create a personalized evaluation using the exercises and movements from our [Movement catalog](https://github.com/sency-ai/smkit-sdk/blob/main/SDK-Movement-Catalog.md), tailored to your professional standards or personal preferences.
```dart

// Add path_provider package
import 'package:path_provider/path_provider.dart';

Future<String> getFileUrl(String fileName) async {
  final byteData = await rootBundle.load(fileName);
  final file = File('${(await getTemporaryDirectory()).path}/$fileName');
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  return file.path;
}

 Future<SMKitWorkout> getDemoAssessment() async{
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
        scoringParams: ScoringParams(type: ScoringType.reps, scoreFactor: 0.5, targetReps: 30),
      ),
      SMKitExercise(
        prettyName: "SquatRegularOverheadStatic",
        totalSeconds: 30,
        exerciseIntro: null,
        videoInstruction: "SquatRegularOverheadStaticInstructionVideo",
        uiElements: [SMKitUIElement.gaugeOfMotion, SMKitUIElement.timer],
        detector: "SquatRegularOverheadStatic",
        exerciseClosure: "",
        scoringParams: ScoringParams(type: ScoringType.time, scoreFactor: 0.5, targetTime: 20),
      ),
    ];

    return SMKitWorkout(
      id: "0",
      name: "demo Assessment",
      workoutIntro: introURL,
      soundTrack: null,
      exercises: exercises,
      getInFrame: null,
      bodycalFinished: null,
      workoutClosure: null,
    );
  }

 void startCustomAssessment() async {
    var assessment = await getDemoAssessment();
    _smkitUiFlutterPlugin.startCustomAssessment(assessment: assessment,
        onHandle: (status) {
          debugPrint(
              '_startWorkout status: ${status.operation} ${status.data}');
          if (status.operation == SMKitOperation.assessmentSummaryData &&
              status.data != null) {
            final workoutResult = status.data as SMKitAssessmentSummaryData;
            debugPrint('_startWorkout assessmentSummaryData: ${workoutResult.toString()}');
          }
        }
    );
  }

// Under Button widget of sort 
onPressed: () {
  startCustomWorkout();
}
```

### AssessmentTypes
| Name (enum)         | Description |More info|
|---------------------|---------------------|---------------------|
| Fitness             | For individuals of any activity level who seek to enhance their physical abilities, strength, and endurance through a tailored plan.| [Link](https://github.com/sency-ai/smkit-sdk/blob/main/Assessments/AI-Fitness-Assessment.md) |
| Body360                 | Designed for individuals of any age and activity level, this assessment determines the need for a preventative plan or medical support.| [Link](https://github.com/sency-ai/smkit-sdk/blob/main/Assessments/360-Body-Assessment.md) |
| Strength            |For individuals of any activity level who seek to assess their strength capabilities (core and endurance) * This assessment will be available soon. Contact us for more info.| [Link](https://github.com/sency-ai/smkit-sdk/blob/main/Assessments/Strength.md) |
| Custom              |If Sency created a tailored assessment for you, you probably know it, and you should use this enum.|  |

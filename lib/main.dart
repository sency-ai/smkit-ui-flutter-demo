import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_smkit_ui/models/sm_workout.dart';
import 'package:flutter_smkit_ui/models/smkit_ui_handlers.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _smkitUiFlutterPlugin = SmkitUiFlutterPlugin();
  String apiPublicKey = "YOUR_AUTH_KEY";
  bool isConfigured = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _smkitUiFlutterPlugin.configure(key: apiPublicKey).then(
          (result) => {
            setState(() {
              isConfigured = result == true;
            })
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isConfigured
                ? showHiddenButtons()
                : const Text("Loading Configure"),
          ],
        ),
      ),
    ));
  }

  Column showHiddenButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            _smkitUiFlutterPlugin.startAssessment(
              type: AssessmentTypes.fitness,
              onHandle: (status) {
                debugPrint(
                    '_startWorkout status: ${status.operation} ${status.data}');
                if (status.operation == SMKitOperation.exerciseData &&
                    status.data != null) {
                  final workoutResult = status.data;
                  debugPrint('_startWorkout workoutResult: $workoutResult');
                  if (workoutResult == null) {
                    return;
                  }
                }
              },
            );
          },
          child: const Text('start Assesment'),
        ),
        ElevatedButton(
          onPressed: () {
            startCustomWorkout();
          },
          child: const Text('start Custom Workout'),
        )
      ],
    );
  }

  void startCustomWorkout() async{
    var workout = await getDemoWorkout();

    _smkitUiFlutterPlugin.startCustomWorkout(
      workout: workout,
      onHandle: (status) {
        debugPrint(
            '_startWorkout status: ${status.operation} ${status.data}');
        if (status.operation == SMKitOperation.exerciseData &&
            status.data != null) {
          final workoutResult = status.data;
          debugPrint('_startWorkout workoutResult: $workoutResult');
          if (workoutResult == null) {
            return;
          }
        }
      },
    );
  }

  Future<String> getFileUrl(String fileName) async {
    final byteData = await rootBundle.load(fileName);
    final file = File('${(await getTemporaryDirectory()).path}/$fileName');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file.path;
  }

  Future<SMKitWorkout> getDemoWorkout() async{
    var introURL = await getFileUrl("customWorkoutIntro.mp3");
    var highKneesIntroURL =  await getFileUrl("HighKneesSound.mp3");

    List<SMKitExercise> exercises = [
      SMKitExercise(
        prettyName: "HighKnees",
        exerciseIntro: highKneesIntroURL,
        totalSeconds: 60,
        introSeconds: 5,
        videoInstruction: "HighKneesInstructionVideo",
        uiElements: [SMKitUIElement.Timer, SMKitUIElement.RepsCounter],
        detector: "HighKnees",
        repBased: true,
        exerciseClosure: null,
        targetReps: 60,
        targetTime: 0,
        scoreFactor: 0.5,
        passCriteria: null,
      ),
      SMKitExercise(
        prettyName: "Plank",
        totalSeconds: 60,
        introSeconds: 8,
        exerciseIntro: null,
        videoInstruction: "PlankHighStaticInstructionVideo",
        uiElements: [SMKitUIElement.GaugeOfMotion, SMKitUIElement.Timer],
        detector: "PlankHighStatic",
        repBased: false,
        exerciseClosure: "",
        targetReps: 60,
        targetTime: 0,
        scoreFactor: 0.5,
        passCriteria: null,
      ),
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
}

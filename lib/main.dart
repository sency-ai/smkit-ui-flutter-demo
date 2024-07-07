import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_smkit_ui/models/sm_workout.dart';
import 'package:flutter_smkit_ui/models/smkit_ui_handlers.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';

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
            _smkitUiFlutterPlugin.startCustomWorkout(
              workout: getDemoWorkout(),
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
          child: const Text('start Custom Workout'),
        )
      ],
    );
  }

  SMKitWorkout getDemoWorkout() {
    List<SMKitExercise> exercises = [
      SMKitExercise(
        prettyName: "Squat",
        exerciseIntro: "exerciseIntro_SquatRegular_60",
        totalSeconds: 60,
        introSeconds: 5,
        videoInstruction: "SquatRegularInstructionVideo",
        uiElements: [SMKitUIElement.Timer, SMKitUIElement.GaugeOfMotion],
        detector: "SquatRegular",
        repBased: true,
        exerciseClosure: "exerciseClosure_0_2.mp3",
        targetReps: 60,
        targetTime: 0,
        scoreFactor: 0.5,
        passCriteria: null,
      ),
      SMKitExercise(
        prettyName: "Plank",
        totalSeconds: 60,
        introSeconds: 8,
        exerciseIntro: "exerciseIntro_PlankHighStatic_60",
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
      workoutIntro: "introduction",
      soundTrack: "soundtrack_7",
      exercises: exercises,
      getInFrame: "bodycal_finished",
      bodycalFinished: "bodycal_get_in_frame",
      workoutClosure: "workoutClosure.mp3",
    );
  }
}

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

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _smkitUiFlutterPlugin.configure(key: apiPublicKey).then(
                      (result) => {
                        setState(() {
                          isConfigured = result == true;
                        })
                      },
                    );
              },
              child: const Text('Configure'),
            ),
            isConfigured ? showHiddenButtons() : const SizedBox(),
          ],
        ),
      ),
    )
    );
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
                  debugPrint(
                      '_startWorkout workoutResult: $workoutResult');
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
        name: "First Exercise",
        totalSeconds: 35,
        introSeconds: 5,
        videoInstruction: null,
        exerciseIntro: null,
        uiElements: [SMKitUIElement.RepsCounter, SMKitUIElement.GaugeOfMotion],
        detector: "HighKnees",
        repBased: true,
        exerciseClosure: null,
        targetReps: 13,
        targetTime: 20,
        scoreFactor: 0.3,
      ),
      SMKitExercise(
        name: "Second Exercise",
        totalSeconds: 25,
        introSeconds: 5,
        videoInstruction: null,
        exerciseIntro: null,
        uiElements: [SMKitUIElement.GaugeOfMotion, SMKitUIElement.Timer],
        detector: "SquatRegularOverheadStatic",
        repBased: false,
        exerciseClosure: null,
        targetReps: null,
        targetTime: 20,
        scoreFactor: 0.3,
      ),
    ];

    return SMKitWorkout(
      id: "50",
      name: "demo workout",
      workoutIntro: null,
      soundTrack: null,
      exercises: exercises,
      getInFrame: null,
      bodycalFinished: null,
      workoutClosure: null,
    );
  }
}

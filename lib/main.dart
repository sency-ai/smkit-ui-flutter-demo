import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smkit_ui_flutter_plugin/models/sm_workout.dart';
import 'package:smkit_ui_flutter_plugin/smkit_ui_flutter_plugin.dart';

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
            child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await _smkitUiFlutterPlugin
                    .configure(key: apiPublicKey)
                    .then((result) => {
                          setState(() {
                            isConfigured = result == true;
                          })
                        });
              },
              child: const Text('Configure'),
            ),
            isConfigured
                ? ElevatedButton(
                    onPressed: () {
                      _smkitUiFlutterPlugin.startAssessment();
                    },
                    child: const Text('start Assesment'),
                  )
                : const SizedBox(),
            isConfigured
                ? ElevatedButton(
                    onPressed: () {
                      _smkitUiFlutterPlugin.startCustomWorkout(
                        workout: getDemoWorkout(),
                      );
                    },
                    child: const Text('start Custom Workout'),
                  )
                : const SizedBox(),
          ],
        )),
      ),
    );
  }

  SMWorkout getDemoWorkout() {
    List<SMExercise> exercises = [
      SMExercise(
        name: "First Exercise",
        totalSeconds: 35,
        introSeconds: 5,
        videoInstruction: null,
        exerciseIntro: null,
        uiElements: [UIElement.RepsCounter, UIElement.GaugeOfMotion],
        detector: "HighKnees",
        repBased: true,
        exerciseClosure: null,
        targetReps: 13,
        targetTime: 20,
        scoreFactor: 0.3,
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

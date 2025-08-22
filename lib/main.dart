import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';
import 'package:flutter_smkit_ui/models/sm_workout.dart';
import 'package:flutter_smkit_ui/models/smkit_ui_handlers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override

  import 'dart:async';
  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';
  import 'package:flutter_smkit_ui/models/sm_workout.dart';
  import 'package:flutter_smkit_ui/models/smkit_ui_handlers.dart';
  import 'package:path_provider/path_provider.dart';
  import 'WorkoutResultScreen.dart';
  import 'package:flutter_dotenv/flutter_dotenv.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    runApp(const MyApp());
  }

  class MyApp extends StatefulWidget {
    const MyApp({super.key});

    @override
    State<MyApp> createState() => _MyAppState();
  }

  class _MyAppState extends State<MyApp> {
    final _smkitUiFlutterPlugin = SmkitUiFlutterPlugin();
    String apiPublicKey = dotenv.env['API_PUBLIC_KEY'] ?? '';
    bool showSummary = true;
    bool isConfigured = false;
    String assessmentId = '';
    AssessmentTypes selectedAssessmentType = AssessmentTypes.fitness;
    ValueNotifier<String> workoutResultNotifier = ValueNotifier<String>("");
    final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

    @override
    void initState() {
      super.initState();
      initPlatformState();
      workoutResultNotifier.addListener(_handleWorkoutResult);
    }

    void _handleWorkoutResult() {
      if (workoutResultNotifier.value.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(seconds: 1), () {
            _navigateToWorkoutResult();
          });
        });
      }
    }

    void _navigateToWorkoutResult() {
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => WorkoutResultScreen(
            workoutResult: workoutResultNotifier.value,
          ),
        ),
      );
    }

    Future<void> initPlatformState() async {
      if (!mounted) return;
      _smkitUiFlutterPlugin.configure(key: apiPublicKey).then(
        (result) {
          setState(() {
            isConfigured = result == true;
          });
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        navigatorKey: _navigatorKey,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isConfigured
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Assessment Type: '),
                              DropdownButton<AssessmentTypes>(
                                value: selectedAssessmentType,
                                items: AssessmentTypes.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type.name),
                                  );
                                }).toList(),
                                onChanged: (type) {
                                  if (type != null) {
                                    setState(() {
                                      selectedAssessmentType = type;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Show Summary'),
                              Switch(
                                value: showSummary,
                                onChanged: (val) {
                                  setState(() {
                                    showSummary = val;
                                  });
                                },
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _smkitUiFlutterPlugin.startAssessment(
                                type: selectedAssessmentType,
                                userData: {
                                  'gender': 'Male',
                                  'birthday': DateTime(1990, 1, 1).millisecondsSinceEpoch,
                                },
                                showSummary: showSummary,
                                onHandle: (status) {
                                  debugPrint('_startWorkout status: [32m${status.operation}[0m [34m${status.data}[0m');
                                  if (status.operation == SMKitOperation.exerciseData && status.data != null) {
                                    final workoutResult = status.data;
                                    debugPrint('_startWorkout workoutResult: $workoutResult');
                                    if (workoutResult == null) {
                                      return;
                                    }
                                  }
                                },
                              );
                            },
                            child: const Text('Start Sency Assessment'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              startCustomaizedWorkout();
                            },
                            child: const Text('Customized Workout'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              startCustomizedAssessment();
                            },
                            child: const Text('Customized Assessment'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  assessmentId = value;
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Assessment ID',
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              debugPrint('Custom Assessment ID: $assessmentId');
                              _smkitUiFlutterPlugin.startAssessment(
                                type: AssessmentTypes.custom,
                                assessmentID: assessmentId == "" ? null : assessmentId,
                                onHandle: (status) {
                                  debugPrint('_startWorkout status: ${status.operation} ${status.data}');
                                  if (status.operation == SMKitOperation.exerciseData && status.data != null) {
                                    final workoutResult = status.data;
                                    debugPrint('_startWorkout workoutResult: $workoutResult');
                                    if (workoutResult == null) {
                                      return;
                                    }
                                  }
                                },
                              );
                            },
                            child: const Text('Custom Assessment'),
                          ),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Configuring.."),
                          CircularProgressIndicator()
                        ],
                      ),
              ],
            ),
          ),
        ),
      );
    }

    void startCustomaizedWorkout() async {
      var workout = await getDemoWorkout();
      _smkitUiFlutterPlugin.startCustomaizedWorkout(
        workout: workout,
        onHandle: (status) {
          debugPrint('_startWorkout status: ${status.operation} ${status.data}');
          if (status.operation == SMKitOperation.exerciseData && status.data != null) {
            final workoutResult = status.data as SMCustomWorkoutData;
            debugPrint('_startWorkout assessmentSummaryData: ${workoutResult.toString()}');
            if (workoutResult == null) {
              return;
            }
          }
        },
      );
    }

    void startCustomizedAssessment() async {
      var assessment = await getDemoAssessment();
      _smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english);
      _smkitUiFlutterPlugin.setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly);
      _smkitUiFlutterPlugin.setEndExercisePreferences(endExercisePrefernces: SMKitEndExercisePreferences.targetBased);
      _smkitUiFlutterPlugin.startCustomizedAssessment(
        assessment: assessment,
        onHandle: (status) {
          debugPrint('_startWorkout status: ${status.operation} ${status.data}');
          if (status.operation == SMKitOperation.assessmentSummaryData && status.data != null) {
            final workoutResult = status.data as SMKitAssessmentSummaryData;
            debugPrint('_startWorkout assessmentSummaryData: ${workoutResult.toString()}');
            setState(() {
              workoutResultNotifier.value = workoutResult.toString();
            });
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

    Future<SMKitWorkout> getDemoWorkout() async {
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
        ),
        SMKitExercise(
          prettyName: "Plank",
          totalSeconds: 30,
          exerciseIntro: null,
          videoInstruction: "PlankHighStaticInstructionVideo",
          uiElements: [SMKitUIElement.gaugeOfMotion, SMKitUIElement.timer],
          detector: "PlankHighStatic",
          exerciseClosure: "",
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
        SMKitExercise(
          prettyName: "SquatRegularOverheadStatic",
          totalSeconds: 30,
          exerciseIntro: null,
          videoInstruction: "SquatRegularOverheadStaticInstructionVideo",
          uiElements: [SMKitUIElement.gaugeOfMotion, SMKitUIElement.timer],
          detector: "SquatRegularOverheadStatic",
          exerciseClosure: "",
          summaryTitle: "Steve",
          summarySubTitle: "JEEF",
          summaryMainMetricTitle: "CLOE",
          summaryMainMetricSubTitle: "MAKRON",
          scoringParams: ScoringParams(
            type: ScoringType.time,
            scoreFactor: 0.5,
            targetTime: 20,
            targetReps: 0,
            targetRom: "",
          ),
        ),
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
  }

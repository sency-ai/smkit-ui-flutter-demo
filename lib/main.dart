import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';
import 'package:flutter_smkit_ui/models/sm_workout.dart';
import 'package:flutter_smkit_ui/models/smkit_ui_handlers.dart';
import 'package:path_provider/path_provider.dart';
import 'WorkoutResultScreen.dart';
import 'UISettingsScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_smkit_ui/models/smkit_ui_config.dart';

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

  // UI / Session settings
  SkeletonConfig? _skeletonConfig;
  bool _allowAudioMixing = false;
  bool _showExternalAudioControl = false;
  bool _enableIntelligenceRest = false;

  // Color customization - using default 'green' theme
  final String selectedTheme = 'green';

  // Get modifications map with current customization settings
  Map<String, dynamic> get currentModifications => buildModifications();

  // Phone calibration settings - using default values
  final bool phoneCalibrationEnabled = true;
  final bool autoCalibrate = false;
  final double calibrationSensitivity = 0.8;

  // Map theme names to primary colors (only primaryColor is used to set the SDK theme)
  final Map<String, String> themePrimaryColors = {
    'green': '#4CAF50',
    'blue': '#2196F3',
    'orange': '#FF9800',
    'red': '#F44336',
    'purple': '#9C27B0',
    'silver': '#C0C0C0',
    'gold': '#FFD700',
    'pink': '#FF69B4',
  };

  @override
  void initState() {
    super.initState();
    initPlatformState();
    workoutResultNotifier.addListener(_handleWorkoutResult);
  }

  void _handleWorkoutResult() {
    if (workoutResultNotifier.value.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(seconds: 1), () {
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

  // Build modifications map with default customization settings
  Map<String, dynamic> buildModifications() {
    return {
      'primaryColor': themePrimaryColors[selectedTheme] ?? themePrimaryColors['green']!,
      'phoneCalibration': {
        'enabled': phoneCalibrationEnabled,
        'autoCalibrate': autoCalibrate,
        'calibrationSensitivity': calibrationSensitivity,
      },
      'showProgressBar': true,
      'showCounters': true,
    };
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
                        // Assessment type dropdown
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
                        // show summary toggle
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
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.tune),
                          label: Text(_skeletonConfig == null ? 'UI Settings' : 'UI Settings ✓'),
                          onPressed: () async {
                            final result = await _navigatorKey.currentState!.push<UISettingsResult>(
                              MaterialPageRoute(
                                builder: (_) => UISettingsScreen(
                                  plugin: _smkitUiFlutterPlugin,
                                  initialConfig: _skeletonConfig,
                                  initialAllowAudioMixing: _allowAudioMixing,
                                  initialShowExternalAudioControl: _showExternalAudioControl,
                                  initialEnableIntelligenceRest: _enableIntelligenceRest,
                                ),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                _skeletonConfig = result.skeletonConfig;
                                _allowAudioMixing = result.allowAudioMixing;
                                _showExternalAudioControl = result.showExternalAudioControl;
                                _enableIntelligenceRest = result.enableIntelligenceRest;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _smkitUiFlutterPlugin.startAssessment(
                              type: selectedAssessmentType,
                              userData: {
                                'gender': 'Male',
                                'birthday': DateTime(1990, 1, 1).millisecondsSinceEpoch,
                              },
                              showSummary: showSummary,
                              modifications: currentModifications,
                              onHandle: (status) {
                                debugPrint(
                                    '_startWorkout status: ${status.operation} ${status.data}');
                                if (status.operation ==
                                        SMKitOperation.exerciseData &&
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
                          child: const Text('Start Sency Assessment'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            startCustomizedWorkout();
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
                            // Add logic to handle custom assessment with assessmentId
                            debugPrint('Custom Assessment ID: $assessmentId');

                            _smkitUiFlutterPlugin.startAssessment(
                              type: AssessmentTypes.custom,
                              assessmentID:
                                  assessmentId == "" ? null : assessmentId,
                              modifications: currentModifications,
                              onHandle: (status) {
                                debugPrint(
                                    '_startWorkout status: ${status.operation} ${status.data}');
                                if (status.operation ==
                                        SMKitOperation.exerciseData &&
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

  void startCustomizedWorkout() async {
    var workout = await getDemoWorkout();

    _smkitUiFlutterPlugin.startCustomizedWorkout(
      workout: workout,
      modifications: currentModifications,
      onHandle: (status) {
        debugPrint('_startWorkout status: ${status.operation} ${status.data}');
        if (status.operation == SMKitOperation.exerciseData &&
            status.data != null) {
          final workoutResult = status.data as SMCustomWorkoutData;
          debugPrint(
              '_startWorkout assessmentSummaryData: ${workoutResult.toString()}');

          if (workoutResult == null) {
            return;
          }
        }
      },
    );
  }

  void startCustomizedAssessment() async {
    try {
      debugPrint('🚀 Starting customized assessment...');

      // Check if plugin is configured
      if (!isConfigured) {
        debugPrint('❌ Plugin not configured yet');
        _showErrorDialog('Plugin not configured yet. Please wait for configuration to complete.');
        return;
      }

      var assessment = await getDemoAssessment();
      debugPrint('✅ Assessment created: ${assessment.name}');

      // Set session preferences (fire-and-forget)
      _smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english);
      _smkitUiFlutterPlugin.setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly);
      _smkitUiFlutterPlugin.setEndExercisePreferences(endExercisePrefernces: SMKitEndExercisePreferences.targetBased);

      debugPrint('🚀 Starting assessment with theme: $selectedTheme...');

      _smkitUiFlutterPlugin.startCustomizedAssessment(
          assessment: assessment,
          modifications: currentModifications,
          onHandle: (status) {
            debugPrint('📊 Assessment status: ${status.operation}');

            // Handle SUCCESS case
            if (status.operation == SMKitOperation.assessmentSummaryData &&
                status.data != null) {
              final workoutResult = status.data as SMKitAssessmentSummaryData;
              debugPrint('✅ Assessment completed');
              debugPrint('📊 ASSESSMENT SUMMARY DATA:');
              debugPrint('════════════════════════════════════════');
              debugPrint('Session ID: ${workoutResult.sessionId}');
              debugPrint('Activity Type: ${workoutResult.activityType}');
              debugPrint('Start Time: ${workoutResult.startTime}');
              debugPrint('End Time: ${workoutResult.endTime}');
              debugPrint('Total Time: ${workoutResult.totalTime}');
              debugPrint('Total Score: ${workoutResult.totalScore}');
              debugPrint('Total Score Segmented: ${workoutResult.totalScoreSegmented}');
              debugPrint('User Data: ${workoutResult.userData}');
              debugPrint('Number of Exercises: ${workoutResult.exercises.length}');
              debugPrint('────────────────────────────────────────');
              for (int i = 0; i < workoutResult.exercises.length; i++) {
                final exercise = workoutResult.exercises[i];
                debugPrint('Exercise ${i + 1}:');
                debugPrint('  Exercise ID: ${exercise.exerciseInfo?.exerciseID}');
                debugPrint('  Pretty Name: ${exercise.exerciseInfo?.prettyName}');
                debugPrint('  Total Score: ${exercise.totalScore}');
                debugPrint('  Performance Score: ${exercise.performanceScore}');
                debugPrint('  Technique Score: ${exercise.techniqueScore}');
                debugPrint('  Reps Performed: ${exercise.repsPerformed}');
                debugPrint('  UI Elements: ${exercise.exerciseInfo?.uiElements}');
                debugPrint('  Instruction Video: ${exercise.exerciseInfo?.instructionVideo}');
                debugPrint('  Voice Intro: ${exercise.exerciseInfo?.voiceIntro}');
                debugPrint('  Voice Outro: ${exercise.exerciseInfo?.voiceOutro}');
                debugPrint('  Scoring Params: ${exercise.exerciseInfo?.scoringParams?.toString()}');
                debugPrint('  Feedbacks: ${exercise.feedbacks}');
              }
              debugPrint('════════════════════════════════════════');
              debugPrint('Full toString: ${workoutResult.toString()}');
              debugPrint('════════════════════════════════════════');
              setState(() {
                workoutResultNotifier.value = workoutResult.toString();
              });
            }
            // Handle ERROR case
            else if (status.operation == SMKitOperation.error) {
              String errorMessage = 'Unknown error occurred';

              if (status.data != null) {
                try {
                  if (status.data is String) {
                    errorMessage = status.data as String;
                    if (errorMessage.startsWith('{"error"')) {
                      final match = RegExp(r'"error":\s*"([^"]*)"').firstMatch(errorMessage);
                      if (match != null) {
                        errorMessage = match.group(1) ?? errorMessage;
                      }
                    }
                  } else if (status.data is SMKitError) {
                    final error = status.data as SMKitError;
                    errorMessage = error.error ?? 'SMKit error occurred';
                  } else {
                    errorMessage = status.data.toString();
                  }
                } catch (e) {
                  errorMessage = 'Error parsing response: ${status.data}';
                }
              }

              debugPrint('❌ Assessment error: $errorMessage');
              _showErrorDialog(errorMessage);
            }
          });

    } catch (e, stackTrace) {
      debugPrint('❌ Exception in startCustomizedAssessment: $e');
      _showErrorDialog('Exception occurred: $e');
    }
  }

  void _showErrorDialog(String message) {
    // Use navigatorKey to ensure we have a valid context
    final navigatorContext = _navigatorKey.currentContext;
    if (navigatorContext == null) {
      debugPrint('⚠️ Cannot show error dialog: No navigator context available');
      debugPrint('Error message: $message');
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: navigatorContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Assessment Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('An error occurred:'),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  Future<String> getFileUrl(String fileName) async {
    final byteData = await rootBundle.load(fileName);
    final file = File('${(await getTemporaryDirectory()).path}/$fileName');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file.path;
  }

  Future<SMKitWorkout> getDemoWorkout() async {
    var introURL = await getFileUrl("customWorkoutIntro.mp3");
    var highKneesIntroURL =
        "https://github.com/sency-ai/smkit-ui-flutter-demo/raw/main/HighKneesSound.mp3";

    List<SMKitExercise> exercises = [
      SMKitExercise(
        prettyName: "HighKnees",
        exerciseIntro: highKneesIntroURL,
        totalSeconds: 30,
        videoInstruction: "HighKneesInstructionVideo",
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
    var highKneesIntroURL =
        "https://github.com/sency-ai/smkit-ui-flutter-demo/raw/main/HighKneesSound.mp3";

    List<SMKitExercise> exercises = [
      SMKitExercise(
        prettyName: "Squat Regular",
        exerciseIntro: null,
        totalSeconds: 10,
        videoInstruction:
            "SquatRegularInstructionVideo",
        uiElements: [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion, SMKitUIElement.repsCounter],
        detector: "SquatRegular",
        exerciseClosure: "",
        scoringParams: ScoringParams(
          type: ScoringType.reps,
          scoreFactor: 0.5,
          targetReps: 3,
          targetTime: 0,
          targetRom: "",
        ),
      ),
      SMKitExercise(
        prettyName: "Rest",
        exerciseIntro: null,
        totalSeconds: 10,
        videoInstruction:
            "Rest",
        uiElements: [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion, SMKitUIElement.repsCounter],
        detector: "Rest",
        exerciseClosure: "",
        scoringParams: ScoringParams(
          type: ScoringType.reps,
          scoreFactor: 0.5,
          targetReps: 3,
          targetTime: 0,
          targetRom: "",
        ),
      ),
      SMKitExercise(
        prettyName: "SquatRegularOverheadStatic",
        totalSeconds: 10,
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

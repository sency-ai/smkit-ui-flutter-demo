import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'WorkoutResultScreen.dart';
import 'UISettingsScreen.dart';
import 'AssessmentBuilderScreen.dart';
import 'WorkoutBuilderScreen.dart';
import 'demo_settings.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env", isOptional: true);
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

  final DemoSettings _settings = DemoSettings();

  // Workout From Program
  bool _showWFPUI = false;
  final _wfpProgramIdController = TextEditingController(text: '');
  final _wfpWeekController = TextEditingController(text: '1');
  WorkoutDuration _wfpDuration = WorkoutDuration.long;
  BodyZone _wfpBodyZone = BodyZone.fullBody;
  SencySupportedLanguage _wfpLanguage = SencySupportedLanguage.english;
  DifficultyLevel _wfpDifficulty = DifficultyLevel.lowDifficulty;

  Map<String, dynamic> get currentModifications => _settings.modifications;

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
        builder: (context) =>
            WorkoutResultScreen(workoutResult: workoutResultNotifier.value),
      ),
    );
  }

  /// Shared result handling for all flows (assessment, workout, WFP).
  void _handleStatus(SMKitStatus status) {
    if (status.operation == SMKitOperation.assessmentSummaryData ||
        status.operation == SMKitOperation.workoutSummaryData) {
      if (status.data != null) {
        workoutResultNotifier.value = status.data.toString();
      }
    } else if (status.operation ==
        SMKitOperation.workoutContinuationPromptDidAppear) {
      debugPrint('Workout continuation prompt appeared');
    } else if (status.operation ==
        SMKitOperation.workoutContinuationUserDidChoose) {
      final data = status.data;
      if (data is SMKitWorkoutContinuationChoiceData) {
        debugPrint('Workout continuation choice: ${data.continueWorkout}');
      }
    } else if (status.operation == SMKitOperation.error) {
      String message = 'Unknown error';
      if (status.data != null) {
        if (status.data is SMKitError) {
          message = (status.data as SMKitError).error ?? message;
        } else {
          message = status.data.toString();
        }
      }
      _showErrorDialog(message);
    }
  }

  @override
  void dispose() {
    _wfpProgramIdController.dispose();
    _wfpWeekController.dispose();
    workoutResultNotifier.removeListener(_handleWorkoutResult);
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    if (apiPublicKey.trim().isEmpty) {
      debugPrint('❌ API_PUBLIC_KEY is missing or empty');
      setState(() => isConfigured = false);
      return;
    }

    debugPrint('⏳ Configuring SMKitUI...');
    final result = await _smkitUiFlutterPlugin.configure(
      key: apiPublicKey,
      includesHighlights: _settings.configureHighlightsOnNextLaunch,
      // Android only: force a specific pose model instead of the adaptive default.
      // Options: SmKitPoseModelChoice.prime | .pro | .lite | .ultraLite | .basic
      // Example: poseModelChoice: SmKitPoseModelChoice.pro,
      // iOS ignores this value — it uses accuratePoseEstimation (bool) in setConfig instead.
    );
    if (!mounted) return;

    final ok = result == true;
    debugPrint('✅ SMKitUI configure result: $result');
    setState(() => isConfigured = ok);

    if (ok) {
      _applyDemoSettingsConfig();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(
          'SMKitUI configuration failed. Please verify API key / connectivity.',
        );
      });
    }

    // Optional: set instruction video cycle (see options below)
    // await _smkitUiFlutterPlugin.setConfig(
    //   config: SMKitConfig(
    //     instructionVideoConfig: InstructionVideoConfig(
    //       displayMode: InstructionVideoDisplayMode.mediumCycle,
    //       mediumSizeCycles: 2,
    //     ),
    //   ),
    // );
    // displayMode: InstructionVideoDisplayMode.defaultMode | InstructionVideoDisplayMode.mediumCycle
    // mediumSizeCycles: 1–5 (used when displayMode is mediumCycle)
  }

  void _applyDemoSettingsConfig() {
    unawaited(_settings.applyTo(_smkitUiFlutterPlugin));
  }

  @override
  Widget build(BuildContext context) {
    if (_showWFPUI) {
      return MaterialApp(navigatorKey: _navigatorKey, home: _buildWFPScreen());
    }
    return MaterialApp(
      navigatorKey: _navigatorKey,
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
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
                          label: const Text('UI Settings'),
                          onPressed: () async {
                            await _navigatorKey.currentState!.push<void>(
                              MaterialPageRoute(
                                builder: (_) => UISettingsScreen(
                                  plugin: _smkitUiFlutterPlugin,
                                  settings: _settings,
                                ),
                              ),
                            );
                            if (mounted) setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            if (!isConfigured) {
                              _showErrorDialog(
                                'Plugin not configured yet. Please wait for configuration to complete.',
                              );
                              return;
                            }
                            await _settings.applyTo(_smkitUiFlutterPlugin);
                            _smkitUiFlutterPlugin.startAssessment(
                              type: selectedAssessmentType,
                              userData: {
                                'gender': 'Male',
                                'birthday': DateTime(
                                  1990,
                                  1,
                                  1,
                                ).millisecondsSinceEpoch,
                              },
                              showSummary: showSummary,
                              modifications: currentModifications,
                              onHandle: _handleStatus,
                            );
                          },
                          child: const Text('Start Sency Assessment'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (_) => WorkoutBuilderScreen(
                                  plugin: _smkitUiFlutterPlugin,
                                  settings: _settings,
                                  onHandle: _handleStatus,
                                ),
                              ),
                            );
                          },
                          child: const Text('Build Workout'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (!isConfigured) {
                              _showErrorDialog(
                                'Plugin not configured yet. Please wait for configuration to complete.',
                              );
                              return;
                            }
                            _navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (_) => AssessmentBuilderScreen(
                                  plugin: _smkitUiFlutterPlugin,
                                  settings: _settings,
                                  showSummary: showSummary,
                                  onHandle: _handleStatus,
                                ),
                              ),
                            );
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
                          onPressed: () async {
                            if (!isConfigured) {
                              _showErrorDialog(
                                'Plugin not configured yet. Please wait for configuration to complete.',
                              );
                              return;
                            }
                            debugPrint('Custom Assessment ID: $assessmentId');
                            await _settings.applyTo(_smkitUiFlutterPlugin);
                            _smkitUiFlutterPlugin.startAssessment(
                              type: AssessmentTypes.custom,
                              assessmentID: assessmentId == ""
                                  ? null
                                  : assessmentId,
                              modifications: currentModifications,
                              onHandle: _handleStatus,
                            );
                          },
                          child: const Text('Custom Assessment'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _showWFPUI = true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                          ),
                          child: const Text('Workout From Program'),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Configuring.."),
                        CircularProgressIndicator(),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWFPScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout From Program')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Program ID',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _wfpProgramIdController,
                decoration: const InputDecoration(
                  hintText: 'Program name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Week', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: _wfpWeekController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Week number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Duration',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Long'),
                      selected: _wfpDuration == WorkoutDuration.long,
                      onSelected: (_) =>
                          setState(() => _wfpDuration = WorkoutDuration.long),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Short'),
                      selected: _wfpDuration == WorkoutDuration.short,
                      onSelected: (_) =>
                          setState(() => _wfpDuration = WorkoutDuration.short),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Body Zone',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Upper Body'),
                    selected: _wfpBodyZone == BodyZone.upperBody,
                    onSelected: (_) =>
                        setState(() => _wfpBodyZone = BodyZone.upperBody),
                  ),
                  ChoiceChip(
                    label: const Text('Lower Body'),
                    selected: _wfpBodyZone == BodyZone.lowerBody,
                    onSelected: (_) =>
                        setState(() => _wfpBodyZone = BodyZone.lowerBody),
                  ),
                  ChoiceChip(
                    label: const Text('Full Body'),
                    selected: _wfpBodyZone == BodyZone.fullBody,
                    onSelected: (_) =>
                        setState(() => _wfpBodyZone = BodyZone.fullBody),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Language',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Hebrew'),
                      selected: _wfpLanguage == SencySupportedLanguage.hebrew,
                      onSelected: (_) => setState(
                        () => _wfpLanguage = SencySupportedLanguage.hebrew,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('English'),
                      selected: _wfpLanguage == SencySupportedLanguage.english,
                      onSelected: (_) => setState(
                        () => _wfpLanguage = SencySupportedLanguage.english,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Difficulty',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Low'),
                    selected: _wfpDifficulty == DifficultyLevel.lowDifficulty,
                    onSelected: (_) => setState(
                      () => _wfpDifficulty = DifficultyLevel.lowDifficulty,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Mid'),
                    selected: _wfpDifficulty == DifficultyLevel.midDifficulty,
                    onSelected: (_) => setState(
                      () => _wfpDifficulty = DifficultyLevel.midDifficulty,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('High'),
                    selected: _wfpDifficulty == DifficultyLevel.highDifficulty,
                    onSelected: (_) => setState(
                      () => _wfpDifficulty = DifficultyLevel.highDifficulty,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: startWorkoutProgramSession,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Start'),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() => _showWFPUI = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> startWorkoutProgramSession() async {
    try {
      final weekStr = _wfpWeekController.text.trim();
      final week = int.tryParse(weekStr);
      if (week == null || week < 1) {
        _showErrorDialog('Invalid week. Please enter a positive number.');
        return;
      }
      final programId = _wfpProgramIdController.text.trim();
      if (programId.isEmpty) {
        _showErrorDialog('Please enter a Program ID.');
        return;
      }
      final smkitLang = _wfpLanguage == SencySupportedLanguage.hebrew
          ? SMKitLanguage.hebrew
          : SMKitLanguage.english;
      _settings.sessionLanguage = smkitLang;
      await _settings.applyTo(_smkitUiFlutterPlugin);
      final config = WorkoutConfig(
        programId: programId,
        week: week,
        bodyZone: _wfpBodyZone,
        difficultyLevel: _wfpDifficulty,
        workoutDuration: _wfpDuration,
        language: _wfpLanguage,
        phonePosition: SMKitPhonePosition.floor,
        shortIntro: true,
      );
      await _smkitUiFlutterPlugin.startWorkoutProgram(
        config: config,
        modifications: currentModifications,
        onHandle: _handleStatus,
      );
    } catch (e) {
      _showErrorDialog('Unable to start workout program: $e');
    }
  }

  void startCustomizedWorkout() async {
    await _settings.applyTo(_smkitUiFlutterPlugin);
    var workout = await getDemoWorkout();
    _smkitUiFlutterPlugin.startCustomizedWorkout(
      workout: workout,
      modifications: currentModifications,
      onHandle: _handleStatus,
    );
  }

  void startCustomizedAssessment() async {
    try {
      debugPrint('🚀 Starting customized assessment...');

      // Check if plugin is configured
      if (!isConfigured) {
        debugPrint('❌ Plugin not configured yet');
        _showErrorDialog(
          'Plugin not configured yet. Please wait for configuration to complete.',
        );
        return;
      }

      var assessment = await getDemoAssessment();
      debugPrint('✅ Assessment created: ${assessment.name}');

      await _settings.applyTo(_smkitUiFlutterPlugin);
      await _smkitUiFlutterPlugin.setEndExercisePreferences(
        endExercisePrefernces: SMKitEndExercisePreferences.targetBased,
      );
      debugPrint(
        'Target-based ending enabled: rep exercises end when targetReps is reached.',
      );
      debugPrint(
        '🚀 Starting assessment with theme: ${_settings.colorTheme.name}...',
      );

      _smkitUiFlutterPlugin.startCustomizedAssessment(
        assessment: assessment,
        modifications: currentModifications,
        onHandle: _handleStatus,
      );
    } catch (e) {
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
    await file.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );
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
        shortIntro: true,
        playPreExerciseCountdown: true,
        playSoundOnEachRep: true,
        playRepMilestoneVoice: true,
        repMilestoneInterval: 10,
        adaptiveRomFeedbackEnabled: true,
        adaptiveRomWarmupReps: 3,
        guidanceMode: true,
        guidanceVideoSegments: const {
          'phase1_orient': SMKitGuidanceVideoSegment.freeze(0),
          'phase4_action': SMKitGuidanceVideoSegment.play(from: 1),
        },
      ),
      SMKitExercise(
        prettyName: "Plank",
        totalSeconds: 30,
        exerciseIntro: null,
        videoInstruction: "PlankHighStaticInstructionVideo",
        uiElements: [
          SMKitUIElement.gaugeOfMotion,
          SMKitUIElement.timer,
          SMKitUIElement.countdownTimer,
          SMKitUIElement.holdingPosition,
        ],
        detector: "PlankHighStatic",
        exerciseClosure: "",
        shortIntro: true,
        playPreExerciseCountdown: true,
        stretchSetConfig: const SMKitStretchSetConfig(
          repetitions: 2,
          secondsPerStretch: 10,
          restSecondsBetweenStretches: 3,
        ),
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
      continuation: SMKitWorkoutContinuation(
        introSoundKey: introURL,
        interactionUnlockSoundKey: introURL,
        exercises: [
          SMKitExercise(
            prettyName: "Rest",
            totalSeconds: 10,
            detector: "Rest",
            uiElements: [SMKitUIElement.timer],
          ),
          SMKitExercise(
            prettyName: "HighKnees Bonus",
            totalSeconds: 20,
            videoInstruction: "HighKneesInstructionVideo",
            detector: "HighKnees",
            uiElements: [SMKitUIElement.timer, SMKitUIElement.repsCounter],
            shortIntro: true,
            playSoundOnEachRep: true,
          ),
        ],
      ),
    );
  }

  Future<SMKitWorkout> getDemoAssessment() async {
    var introURL = await getFileUrl("customWorkoutIntro.mp3");
    var highKneesIntroURL =
        "https://github.com/sency-ai/smkit-ui-flutter-demo/raw/main/HighKneesSound.mp3";
    const targetReps = 3;

    List<SMKitExercise> exercises = [
      SMKitExercise(
        prettyName: "Squat Regular",
        exerciseIntro: null,
        totalSeconds: 45,
        videoInstruction: "SquatRegularInstructionVideo",
        uiElements: [
          SMKitUIElement.timer,
          SMKitUIElement.gaugeOfMotion,
          SMKitUIElement.repsCounter,
        ],
        detector: "SquatRegular",
        exerciseClosure: "",
        scoringParams: ScoringParams.targetReps(
          scoreFactor: 0.5,
          targetReps: targetReps,
        ),
      ),
      SMKitExercise(
        prettyName: "Rest",
        exerciseIntro: null,
        totalSeconds: 10,
        videoInstruction: "Rest",
        uiElements: [SMKitUIElement.timer],
        detector: "Rest",
        exerciseClosure: "",
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
          targetTime: 10,
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

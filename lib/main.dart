import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'WorkoutResultScreen.dart';
import 'UISettingsScreen.dart';
import 'AssessmentBuilderScreen.dart';
import 'GuidanceModeScreen.dart';
import 'WorkoutBuilderScreen.dart';
import 'demo_settings.dart';
import 'adaptive_rom_store.dart';
import 'demo_event_log.dart';
import 'FeatureExamplesScreen.dart';
import 'live_controls.dart';
import 'SdkToolsScreen.dart';
import 'demo_presets.dart';
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
  bool isConfiguring = false;
  String? configurationError;
  String assessmentId = '';
  AssessmentTypes selectedAssessmentType = AssessmentTypes.fitness;
  ValueNotifier<Object?> workoutResultNotifier = ValueNotifier<Object?>(null);
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  final DemoSettings _settings = DemoSettings();

  /// True while a home-screen preset runs with its own blue theme.
  bool _presetThemeActive = false;

  /// Name of the preset whose assets are downloading before it starts.
  String? _preparingPreset;
  late final LiveControlRunner _liveControls = LiveControlRunner(
    _smkitUiFlutterPlugin,
    _settings,
  );

  // Workout From Program
  bool _showWFPUI = false;
  final _wfpProgramIdController = TextEditingController(text: '');
  final _wfpWeekController = TextEditingController(text: '1');
  final _customerAssetIdController = TextEditingController();
  StreamSubscription<SMKitDiagnosticEvent>? _diagnosticsSubscription;
  String? _latestDiagnostic;
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
    if (Platform.isIOS) {
      _diagnosticsSubscription = _smkitUiFlutterPlugin.diagnostics.listen((
        event,
      ) {
        DemoEventLog.instance.add(
          'Diagnostic ${event.severity}/${event.category}: ${event.name}',
          DemoEventLog.diagnosticDetails(event),
        );
        if (mounted) {
          setState(() => _latestDiagnostic = '${event.name}: ${event.message}');
        }
      });
    }
  }

  void _handleWorkoutResult() {
    if (workoutResultNotifier.value != null) {
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
            WorkoutResultScreen(workoutResult: workoutResultNotifier.value!),
      ),
    );
  }

  /// Shared result handling for all flows (assessment, workout, WFP).
  void _handleStatus(SMKitStatus status) {
    DemoEventLog.instance.addStatus(status);
    if (status.operation == SMKitOperation.exerciseWillStart) {
      final data = status.data;
      if (data is SMKitExerciseStartData) {
        _liveControls.onExerciseWillStart(data);
      }
    } else if (status.operation == SMKitOperation.assessmentSummaryData ||
        status.operation == SMKitOperation.workoutSummaryData) {
      _liveControls.cancel();
      _restoreThemeAfterPreset();
      unawaited(_saveAdaptiveRom(status.data));
      if (status.data != null) {
        workoutResultNotifier.value = status.data;
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
      _liveControls.cancel();
      _restoreThemeAfterPreset();
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

  Future<void> _saveAdaptiveRom(Object? summary) async {
    await AdaptiveRomStore.instance.load();
    final saved = await AdaptiveRomStore.instance.saveFrom(summary);
    if (saved > 0) {
      DemoEventLog.instance.add('Saved $saved adaptive ROM snapshot(s)');
    }
  }

  /// The SDK returns each recovered session once, so check right after
  /// configuring, outside a workout.
  Future<void> _checkRecoveredSessions() async {
    try {
      final sessions = await _smkitUiFlutterPlugin
          .consumeRecoveredSessionSummaries();
      if (sessions.isEmpty) return;
      recoveredSessions.addAll(sessions);
      for (final session in sessions) {
        DemoEventLog.instance.addRecoveredSession(session);
      }
      final context = _navigatorKey.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recovered ${sessions.length} interrupted session(s). '
              'See SDK Tools.',
            ),
          ),
        );
      }
    } catch (error) {
      DemoEventLog.instance.add(
        'consumeRecoveredSessionSummaries failed',
        '$error',
      );
    }
  }

  @override
  void dispose() {
    _liveControls.cancel();
    _wfpProgramIdController.dispose();
    _wfpWeekController.dispose();
    _customerAssetIdController.dispose();
    _diagnosticsSubscription?.cancel();
    workoutResultNotifier.removeListener(_handleWorkoutResult);
    unawaited(_smkitUiFlutterPlugin.quitWorkout());
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted || isConfiguring) return;
    if (apiPublicKey.trim().isEmpty) {
      setState(() {
        isConfigured = false;
        configurationError = 'Enter an auth key to configure SMKitUI.';
      });
      return;
    }

    setState(() {
      isConfiguring = true;
      configurationError = null;
    });
    try {
      // Configure-time settings must be queued before the native SDK is constructed.
      await _settings.applyTo(_smkitUiFlutterPlugin);
      final result = await _smkitUiFlutterPlugin.configure(
        key: apiPublicKey.trim(),
        configureLanguage: _settings.sessionLanguage,
        customerCode: dotenv.env['CUSTOMER_CODE']?.trim().isEmpty == true
            ? null
            : dotenv.env['CUSTOMER_CODE']?.trim(),
        includesHighlights: _settings.configureHighlightsOnNextLaunch,
        poseModelChoice: _settings.poseModelChoice,
        // Android 1.9.9 rejects non-default values for these two.
        includesObjectDetectionFeedbacks: Platform.isIOS
            ? _settings.objectDetectionFeedbacks
            : false,
        modelDownloadPolicy: Platform.isIOS
            ? _settings.modelDownloadPolicy
            : SMKitModelDownloadPolicy.waitForRemoteModelsThenFallback,
      );
      if (!mounted) return;
      final ok = result == true;
      setState(() {
        isConfigured = ok;
        configurationError = ok
            ? null
            : 'Configuration failed. Check your auth key and connection, then retry.';
      });
      if (ok) {
        _applyDemoSettingsConfig();
        unawaited(_checkRecoveredSessions());
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isConfigured = false;
        configurationError =
            'Configuration failed. Check your auth key and connection, then retry.';
      });
    } finally {
      if (mounted) setState(() => isConfiguring = false);
    }
  }

  Widget _buildConfigurationStatus() {
    if (isConfiguring) {
      return const Column(
        key: ValueKey('configuring'),
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(strokeWidth: 4),
          ),
          SizedBox(height: 20),
          Text(
            'Authenticating with SMKitUI…',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text('Please wait while your SDK session is prepared.'),
        ],
      );
    }
    return Column(
      key: const ValueKey('configuration-error'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(configurationError ?? 'SMKitUI is not configured.'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            onChanged: (value) => apiPublicKey = value,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Auth key',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: initPlatformState,
          child: const Text('Configure SDK'),
        ),
      ],
    );
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
        // Scrolls on short screens; stays centred when the content fits.
        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - 32).clamp(
                  0,
                  double.infinity,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isConfiguring || !isConfigured
                          ? _buildConfigurationStatus()
                          : Column(
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
                                FilledButton.icon(
                                  icon: const Icon(Icons.self_improvement),
                                  label: Text(
                                    _preparingPreset == 'Mobility Flow'
                                        ? 'Preparing Mobility Flow…'
                                        : 'Mobility Flow',
                                  ),
                                  onPressed: _preparingPreset != null
                                      ? null
                                      : () => _startPreset(
                                          'Mobility Flow',
                                          DemoPresets.mobilityFlow(),
                                          prepareFirst: true,
                                        ),
                                ),
                                FilledButton.icon(
                                  icon: const Icon(Icons.fitness_center),
                                  label: const Text('Example workout'),
                                  onPressed: () => _startPreset(
                                    'Example workout',
                                    DemoPresets.showcaseWorkout(),
                                    guidanceSuggestion: true,
                                  ),
                                ),
                                FilledButton.icon(
                                  icon: const Icon(Icons.repeat),
                                  label: const Text(
                                    'Rounds (warm-up + 2 rounds)',
                                  ),
                                  onPressed: () => _startPreset(
                                    'Rounds',
                                    DemoPresets.rounds(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.tune),
                                  label: const Text('UI Settings'),
                                  onPressed: () async {
                                    await _navigatorKey.currentState!
                                        .push<void>(
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
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Reconfigure SDK'),
                                  onPressed: () async {
                                    await initPlatformState();
                                  },
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.cleaning_services_outlined,
                                  ),
                                  label: const Text('Clear Adaptive ROM Cache'),
                                  onPressed: () async {
                                    await _smkitUiFlutterPlugin
                                        .clearAdaptiveRomCache();
                                    debugPrint('Adaptive ROM cache cleared');
                                  },
                                ),
                                if (Platform.isIOS)
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.download_outlined),
                                    label: const Text(
                                      'Preload models in background',
                                    ),
                                    onPressed: () async =>
                                        _smkitUiFlutterPlugin.preloadModels(),
                                  ),
                                TextField(
                                  controller: _customerAssetIdController,
                                  decoration: const InputDecoration(
                                    labelText: 'Customer asset identifier',
                                  ),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.folder_open),
                                  label: const Text('Get customer asset path'),
                                  onPressed: () async {
                                    final identifier =
                                        _customerAssetIdController.text.trim();
                                    if (identifier.isEmpty) return;
                                    final path = await _smkitUiFlutterPlugin
                                        .requestCustomerAssetPath(
                                          identifier: identifier,
                                        );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            path ??
                                                'Customer asset unavailable',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                if (_latestDiagnostic != null)
                                  Text('Latest diagnostic: $_latestDiagnostic'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (!isConfigured) {
                                      _showErrorDialog(
                                        'Plugin not configured yet. Please wait for configuration to complete.',
                                      );
                                      return;
                                    }
                                    await _settings.applyTo(
                                      _smkitUiFlutterPlugin,
                                    );
                                    await _smkitUiFlutterPlugin.startAssessment(
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
                                    _navigatorKey.currentState?.push(
                                      MaterialPageRoute(
                                        builder: (_) => GuidanceModeScreen(
                                          plugin: _smkitUiFlutterPlugin,
                                          settings: _settings,
                                          showSummary: showSummary,
                                          onHandle: _handleStatus,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Guidance Mode'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _navigatorKey.currentState?.push(
                                      MaterialPageRoute(
                                        builder: (_) => FeatureExamplesScreen(
                                          plugin: _smkitUiFlutterPlugin,
                                          settings: _settings,
                                          onHandle: _handleStatus,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Feature Examples'),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.build_outlined),
                                  label: const Text('SDK Tools'),
                                  onPressed: () {
                                    _navigatorKey.currentState?.push(
                                      MaterialPageRoute(
                                        builder: (_) => SdkToolsScreen(
                                          plugin: _smkitUiFlutterPlugin,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.list_alt),
                                  label: const Text('Event Log'),
                                  onPressed: () {
                                    _navigatorKey.currentState?.push(
                                      MaterialPageRoute(
                                        builder: (_) => const EventLogScreen(),
                                      ),
                                    );
                                  },
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
                                    debugPrint(
                                      'Custom Assessment ID: $assessmentId',
                                    );
                                    await _settings.applyTo(
                                      _smkitUiFlutterPlugin,
                                    );
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
                            ),
                    ),
                  ],
                ),
              ),
            ),
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
                      label: const Text('Mandarin'),
                      selected: _wfpLanguage == SencySupportedLanguage.mandarin,
                      onSelected: (_) => setState(
                        () => _wfpLanguage = SencySupportedLanguage.mandarin,
                      ),
                    ),
                  ),
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
      final smkitLang = switch (_wfpLanguage) {
        SencySupportedLanguage.hebrew => SMKitLanguage.hebrew,
        SencySupportedLanguage.mandarin => SMKitLanguage.mandarin,
        _ => SMKitLanguage.english,
      };
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

  /// Starts a home-screen preset with the current UI settings, but always in
  /// the blue color theme. [guidanceSuggestion] also turns on the SDK-wide
  /// guidance-mode suggestion (it then shows as on in UI Settings).
  Future<void> _startPreset(
    String name,
    SMKitWorkout workout, {
    bool guidanceSuggestion = false,
    bool prepareFirst = false,
  }) async {
    try {
      if (guidanceSuggestion) _settings.guidanceModeSuggestion = true;
      await _settings.applyTo(_smkitUiFlutterPlugin);
      if (prepareFirst) await _prepareBeforeStart(name, workout);
      // Blue for this session only; the user's theme is restored when it ends.
      _presetThemeActive = true;
      await _smkitUiFlutterPlugin.setConfig(
        config: const SMKitConfig(colorTheme: SMKitColorTheme.blue),
      );
      await _smkitUiFlutterPlugin.startCustomizedWorkout(
        workout: workout,
        modifications: {
          ...currentModifications,
          'primaryColor': SMKitColorTheme.blue.hexColor,
        },
        onHandle: _handleStatus,
      );
    } catch (error) {
      _restoreThemeAfterPreset();
      _showErrorDialog('Could not start $name: $error');
    }
  }

  /// SMKitUI 2.7.3 plays its opening prompts as soon as a session starts. If
  /// the Mobility Flow voice copies are still downloading, it falls back to the
  /// main voice. Preparing the same workout first downloads them; the SDK
  /// reuses that download because it caches assets by workout contents.
  Future<void> _prepareBeforeStart(String name, SMKitWorkout workout) async {
    setState(() => _preparingPreset = name);
    try {
      // A first download can take ~25 s; on stage, start after 15 s anyway.
      final ready = await _smkitUiFlutterPlugin
          .prepareWorkout(workout)
          .timeout(const Duration(seconds: 15));
      DemoEventLog.instance.add('prepareWorkout($name)', 'returned $ready');
    } catch (error) {
      // Start anyway; the session downloads what it still needs.
      DemoEventLog.instance.add('prepareWorkout($name) failed', '$error');
    } finally {
      if (mounted) setState(() => _preparingPreset = null);
    }
  }

  void _restoreThemeAfterPreset() {
    if (!_presetThemeActive) return;
    _presetThemeActive = false;
    unawaited(_settings.applyTo(_smkitUiFlutterPlugin));
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
        videoInstruction: "HighKnees",
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
        videoInstruction: "PlankHighStatic",
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
            videoInstruction: "HighKnees",
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
        videoInstruction: "SquatRegular",
        uiElements: [SMKitUIElement.gaugeOfMotion, SMKitUIElement.repsCounter],
        detector: "SquatRegular",
        exerciseClosure: "",
        showTargetProgress: true,
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
        videoInstruction: "SquatRegularOverheadStatic",
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

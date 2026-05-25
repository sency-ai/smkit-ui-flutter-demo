import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';

import 'demo_settings.dart';
import 'exercise_catalog.dart';

enum WorkoutPhonePositionChoice { sdkDefault, floor, elevated }

enum WorkoutTriStateChoice { sdkDefault, on, off }

class BuiltWorkoutExercise {
  final int id;
  String detector;
  int duration;
  WorkoutPhonePositionChoice phonePositionChoice;
  WorkoutTriStateChoice guidanceChoice;
  WorkoutTriStateChoice wideAngleChoice;
  bool shortIntro;
  bool playPreExerciseCountdown;
  bool playRepMilestoneVoice;
  int repMilestoneInterval;
  bool playSoundOnEachRep;
  bool adaptiveRomFeedbackEnabled;
  int adaptiveRomWarmupReps;
  bool stretchSetEnabled;
  int stretchSetRepetitions;
  int stretchSetSeconds;
  int stretchSetRestSeconds;

  BuiltWorkoutExercise({
    required this.id,
    required this.detector,
    required this.duration,
    this.phonePositionChoice = WorkoutPhonePositionChoice.sdkDefault,
    this.guidanceChoice = WorkoutTriStateChoice.sdkDefault,
    this.wideAngleChoice = WorkoutTriStateChoice.sdkDefault,
    this.shortIntro = false,
    this.playPreExerciseCountdown = false,
    this.playRepMilestoneVoice = false,
    this.repMilestoneInterval = 10,
    this.playSoundOnEachRep = false,
    this.adaptiveRomFeedbackEnabled = false,
    this.adaptiveRomWarmupReps = 2,
    this.stretchSetEnabled = false,
    this.stretchSetRepetitions = 3,
    this.stretchSetSeconds = 8,
    this.stretchSetRestSeconds = 4,
  });

  SMKitExercise toExercise() {
    final entry = ExerciseCatalog.byDetector[detector];
    final uiElements = entry?.uiElements ?? _fallbackUiElements;
    return SMKitExercise(
      prettyName: displayNameForDetector(detector),
      totalSeconds: duration,
      videoInstruction:
          entry?.videoInstruction ?? '${detector}InstructionVideo',
      uiElements: uiElements,
      detector: detector,
      phonePosition: phonePositionChoice.phonePosition,
      guidanceMode: guidanceChoice.boolValue,
      useWideAngleCamera: Platform.isIOS ? wideAngleChoice.boolValue : null,
      shortIntro: shortIntro,
      playPreExerciseCountdown: playPreExerciseCountdown,
      playRepMilestoneVoice: playRepMilestoneVoice,
      repMilestoneInterval: repMilestoneInterval,
      playSoundOnEachRep: playSoundOnEachRep,
      adaptiveRomFeedbackEnabled: adaptiveRomFeedbackEnabled,
      adaptiveRomWarmupReps: adaptiveRomWarmupReps,
      stretchSetConfig: stretchSetEnabled
          ? SMKitStretchSetConfig(
              repetitions: stretchSetRepetitions,
              secondsPerStretch: stretchSetSeconds,
              restSecondsBetweenStretches: stretchSetRestSeconds,
            )
          : null,
    );
  }

  static const _fallbackUiElements = [
    SMKitUIElement.timer,
    SMKitUIElement.repsCounter,
  ];
}

class WorkoutBuilderScreen extends StatefulWidget {
  final SmkitUiFlutterPlugin plugin;
  final DemoSettings settings;
  final void Function(SMKitStatus) onHandle;

  const WorkoutBuilderScreen({
    super.key,
    required this.plugin,
    required this.settings,
    required this.onHandle,
  });

  @override
  State<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends State<WorkoutBuilderScreen> {
  final _searchController = TextEditingController();
  final List<BuiltWorkoutExercise> _workoutExercises = [];
  final List<BuiltWorkoutExercise> _continuationExercises = [];
  List<String> _availableDetectors = [];
  bool _loadingExercises = true;
  int _nextId = 1;
  int _addTargetIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAvailableExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableExercises() async {
    List<String> detectors;
    try {
      detectors = await widget.plugin.getSupportedMovements() ?? [];
    } catch (_) {
      detectors = [];
    }
    if (detectors.isEmpty) {
      detectors = ExerciseCatalog.byDetector.keys.toList();
    }
    detectors = detectors
        .where((detector) => detector.toLowerCase() != 'rowing')
        .toSet()
        .toList()
      ..sort((a, b) =>
          displayNameForDetector(a).compareTo(displayNameForDetector(b)));
    if (!mounted) return;
    setState(() {
      _availableDetectors = detectors;
      _loadingExercises = false;
    });
  }

  List<String> get _filteredDetectors {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _availableDetectors;
    return _availableDetectors
        .where(
          (detector) =>
              detector.toLowerCase().contains(query) ||
              displayNameForDetector(detector).toLowerCase().contains(query),
        )
        .toList();
  }

  void _addDetector(String detector) {
    final item = BuiltWorkoutExercise(
      id: _nextId++,
      detector: detector,
      duration: _defaultDuration(detector),
    );
    setState(() {
      if (widget.settings.enableWorkoutContinuation && _addTargetIndex == 1) {
        _continuationExercises.add(item);
      } else {
        _workoutExercises.add(item);
      }
    });
  }

  int _defaultDuration(String detector) {
    final entry = ExerciseCatalog.byDetector[detector];
    if (entry?.type == ExerciseTypeFilter.mobility ||
        entry?.type == ExerciseTypeFilter.bodyAssessment ||
        entry?.type == ExerciseTypeFilter.static_) {
      return 10;
    }
    return 20;
  }

  Future<void> _startWorkout() async {
    if (_workoutExercises.isEmpty) return;
    await widget.settings.applyTo(widget.plugin);
    final continuation = widget.settings.enableWorkoutContinuation &&
            _continuationExercises.isNotEmpty
        ? SMKitWorkoutContinuation(
            introSoundKey: null,
            interactionUnlockSoundKey: '',
            exercises: _continuationExercises
                .map((item) => item.toExercise())
                .toList(),
          )
        : null;
    await widget.plugin.startCustomizedWorkout(
      workout: SMKitWorkout(
        id: 'built-workout',
        name: 'Built Workout',
        workoutIntro: null,
        exercises: _workoutExercises.map((item) => item.toExercise()).toList(),
        continuation: continuation,
      ),
      modifications: widget.settings.modifications,
      onHandle: widget.onHandle,
    );
  }

  Future<void> _editExercise(
    BuiltWorkoutExercise exercise,
    List<BuiltWorkoutExercise> owner,
  ) async {
    final updated = await Navigator.of(context).push<BuiltWorkoutExercise>(
      MaterialPageRoute(
        builder: (_) => ExerciseConfigScreen(exercise: exercise),
      ),
    );
    if (updated == null) return;
    setState(() {
      final index = owner.indexWhere((item) => item.id == updated.id);
      if (index >= 0) {
        owner[index] = updated;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Workout'),
        actions: [
          TextButton(
            onPressed: _workoutExercises.isEmpty ? null : _startWorkout,
            child: const Text('Start'),
          ),
          TextButton(
            onPressed:
                _workoutExercises.isEmpty && _continuationExercises.isEmpty
                    ? null
                    : () => setState(() {
                          _workoutExercises.clear();
                          _continuationExercises.clear();
                        }),
            child: const Text('Clear'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search SDK exercises',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable workout continuation'),
              value: widget.settings.enableWorkoutContinuation,
              onChanged: (value) {
                setState(() {
                  widget.settings.enableWorkoutContinuation = value;
                  if (!value) _addTargetIndex = 0;
                });
              },
            ),
            if (widget.settings.enableWorkoutContinuation)
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Workout')),
                  ButtonSegment(value: 1, label: Text('Continuation')),
                ],
                selected: {_addTargetIndex},
                onSelectionChanged: (value) =>
                    setState(() => _addTargetIndex = value.single),
              ),
            _selectedSection(
              title: 'Workout',
              items: _workoutExercises,
              emptyText: 'Add at least one exercise to enable Start.',
            ),
            if (widget.settings.enableWorkoutContinuation)
              _selectedSection(
                title: 'Continuation',
                items: _continuationExercises,
                emptyText:
                    'Continuation exercises run only when continuation is enabled.',
              ),
            const SizedBox(height: 16),
            const Text(
              'Available exercises',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_loadingExercises)
              const Center(child: CircularProgressIndicator())
            else if (_filteredDetectors.isEmpty)
              const Text('No supported movements found.')
            else
              ..._filteredDetectors.map(
                (detector) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.add_circle_outline),
                  title: Text(displayNameForDetector(detector)),
                  subtitle: Text(detector),
                  onTap: () => _addDetector(detector),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _selectedSection({
    required String title,
    required List<BuiltWorkoutExercise> items,
    required String emptyText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title (${items.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(emptyText),
            )
          else
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Card(
                child: ListTile(
                  leading: Text('${index + 1}.'),
                  title: Text(displayNameForDetector(item.detector)),
                  subtitle: Text(_exerciseSummary(item)),
                  onTap: () => _editExercise(item, items),
                  trailing: Wrap(
                    spacing: 2,
                    children: [
                      IconButton(
                        tooltip: 'Move up',
                        icon: const Icon(Icons.arrow_upward),
                        onPressed: index == 0
                            ? null
                            : () => setState(() {
                                  final moved = items.removeAt(index);
                                  items.insert(index - 1, moved);
                                }),
                      ),
                      IconButton(
                        tooltip: 'Move down',
                        icon: const Icon(Icons.arrow_downward),
                        onPressed: index == items.length - 1
                            ? null
                            : () => setState(() {
                                  final moved = items.removeAt(index);
                                  items.insert(index + 1, moved);
                                }),
                      ),
                      IconButton(
                        tooltip: 'Remove',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(() => items.removeAt(index)),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  String _exerciseSummary(BuiltWorkoutExercise item) {
    final flags = <String>['${item.duration}s'];
    if (item.shortIntro) flags.add('short intro');
    if (item.guidanceChoice != WorkoutTriStateChoice.sdkDefault) {
      flags.add('guidance ${item.guidanceChoice.displayName.toLowerCase()}');
    }
    if (item.adaptiveRomFeedbackEnabled) flags.add('adaptive ROM');
    if (item.stretchSetEnabled) flags.add('stretch set');
    return flags.join(' • ');
  }
}

class ExerciseConfigScreen extends StatefulWidget {
  final BuiltWorkoutExercise exercise;

  const ExerciseConfigScreen({super.key, required this.exercise});

  @override
  State<ExerciseConfigScreen> createState() => _ExerciseConfigScreenState();
}

class _ExerciseConfigScreenState extends State<ExerciseConfigScreen> {
  late BuiltWorkoutExercise exercise;

  @override
  void initState() {
    super.initState();
    exercise = BuiltWorkoutExercise(
      id: widget.exercise.id,
      detector: widget.exercise.detector,
      duration: widget.exercise.duration,
      phonePositionChoice: widget.exercise.phonePositionChoice,
      guidanceChoice: widget.exercise.guidanceChoice,
      wideAngleChoice: widget.exercise.wideAngleChoice,
      shortIntro: widget.exercise.shortIntro,
      playPreExerciseCountdown: widget.exercise.playPreExerciseCountdown,
      playRepMilestoneVoice: widget.exercise.playRepMilestoneVoice,
      repMilestoneInterval: widget.exercise.repMilestoneInterval,
      playSoundOnEachRep: widget.exercise.playSoundOnEachRep,
      adaptiveRomFeedbackEnabled: widget.exercise.adaptiveRomFeedbackEnabled,
      adaptiveRomWarmupReps: widget.exercise.adaptiveRomWarmupReps,
      stretchSetEnabled: widget.exercise.stretchSetEnabled,
      stretchSetRepetitions: widget.exercise.stretchSetRepetitions,
      stretchSetSeconds: widget.exercise.stretchSetSeconds,
      stretchSetRestSeconds: widget.exercise.stretchSetRestSeconds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(displayNameForDetector(exercise.detector)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(exercise),
            child: const Text('Done'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Detector: ${exercise.detector}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            _stepperTile(
              'Duration',
              exercise.duration,
              5,
              300,
              5,
              's',
              (value) => setState(() => exercise.duration = value),
            ),
            _segmentedTile<WorkoutPhonePositionChoice>(
              'Phone position',
              exercise.phonePositionChoice,
              WorkoutPhonePositionChoice.values,
              (value) => setState(() => exercise.phonePositionChoice = value),
            ),
            _segmentedTile<WorkoutTriStateChoice>(
              'Guidance mode',
              exercise.guidanceChoice,
              WorkoutTriStateChoice.values,
              (value) => setState(() => exercise.guidanceChoice = value),
            ),
            if (Platform.isIOS)
              _segmentedTile<WorkoutTriStateChoice>(
                'Wide angle camera',
                exercise.wideAngleChoice,
                WorkoutTriStateChoice.values,
                (value) => setState(() => exercise.wideAngleChoice = value),
              ),
            _switchTile(
              'Short intro',
              exercise.shortIntro,
              (value) => setState(() => exercise.shortIntro = value),
            ),
            _switchTile(
              'Pre-exercise countdown',
              exercise.playPreExerciseCountdown,
              (value) =>
                  setState(() => exercise.playPreExerciseCountdown = value),
            ),
            _switchTile(
              'Rep milestone voice',
              exercise.playRepMilestoneVoice,
              (value) => setState(() => exercise.playRepMilestoneVoice = value),
            ),
            _segmentedTile<int>(
              'Milestone interval',
              exercise.repMilestoneInterval,
              const [10, 5],
              (value) => setState(() => exercise.repMilestoneInterval = value),
              labelBuilder: (value) => '$value reps',
            ),
            _switchTile(
              'Sound on each rep',
              exercise.playSoundOnEachRep,
              (value) => setState(() => exercise.playSoundOnEachRep = value),
            ),
            _switchTile(
              'Adaptive ROM feedback',
              exercise.adaptiveRomFeedbackEnabled,
              (value) =>
                  setState(() => exercise.adaptiveRomFeedbackEnabled = value),
            ),
            _stepperTile(
              'Adaptive warmup reps',
              exercise.adaptiveRomWarmupReps,
              1,
              5,
              1,
              '',
              (value) => setState(() => exercise.adaptiveRomWarmupReps = value),
            ),
            const SizedBox(height: 12),
            const Text(
              'Stretch set',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _switchTile(
              'Enable stretch set',
              exercise.stretchSetEnabled,
              (value) => setState(() => exercise.stretchSetEnabled = value),
            ),
            _stepperTile(
              'Stretch repetitions',
              exercise.stretchSetRepetitions,
              1,
              10,
              1,
              '',
              (value) => setState(() => exercise.stretchSetRepetitions = value),
            ),
            _stepperTile(
              'Seconds per stretch',
              exercise.stretchSetSeconds,
              3,
              60,
              1,
              's',
              (value) => setState(() => exercise.stretchSetSeconds = value),
            ),
            _stepperTile(
              'Rest between stretches',
              exercise.stretchSetRestSeconds,
              0,
              30,
              1,
              's',
              (value) => setState(() => exercise.stretchSetRestSeconds = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _segmentedTile<T>(
    String title,
    T selected,
    List<T> values,
    ValueChanged<T> onChanged, {
    String Function(T value)? labelBuilder,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<T>(
            segments: values
                .map(
                  (value) => ButtonSegment<T>(
                    value: value,
                    label: Text(labelBuilder?.call(value) ??
                        (value as Object).displayName),
                  ),
                )
                .toList(),
            selected: {selected},
            onSelectionChanged: (value) => onChanged(value.single),
          ),
        ],
      ),
    );
  }

  Widget _stepperTile(
    String title,
    int value,
    int min,
    int max,
    int step,
    String suffix,
    ValueChanged<int> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value <= min
                ? null
                : () => onChanged((value - step).clamp(min, max)),
          ),
          SizedBox(
            width: 72,
            child: Text(
              suffix.isEmpty ? '$value' : '$value $suffix',
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: value >= max
                ? null
                : () => onChanged((value + step).clamp(min, max)),
          ),
        ],
      ),
    );
  }
}

String displayNameForDetector(String detector) {
  return detector
      .replaceAll('QL', 'Q L')
      .replaceAll('IT', 'I T')
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match[1]} ${match[2]}',
      );
}

extension _WorkoutPhonePositionMapping on WorkoutPhonePositionChoice {
  SMKitPhonePosition? get phonePosition => switch (this) {
        WorkoutPhonePositionChoice.sdkDefault => null,
        WorkoutPhonePositionChoice.floor => SMKitPhonePosition.floor,
        WorkoutPhonePositionChoice.elevated => SMKitPhonePosition.elevated,
      };
}

extension _TriStateMapping on WorkoutTriStateChoice {
  bool? get boolValue => switch (this) {
        WorkoutTriStateChoice.sdkDefault => null,
        WorkoutTriStateChoice.on => true,
        WorkoutTriStateChoice.off => false,
      };
}

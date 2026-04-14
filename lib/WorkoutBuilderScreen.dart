import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';
import 'package:path_provider/path_provider.dart';

import 'exercise_catalog.dart';

class _WorkoutExercise {
  final String detector;

  const _WorkoutExercise({required this.detector});
}

class WorkoutBuilderScreen extends StatefulWidget {
  final SmkitUiFlutterPlugin plugin;
  final Map<String, dynamic> modifications;
  final bool enableIntelligenceRest;
  final void Function(SMKitStatus) onHandle;

  const WorkoutBuilderScreen({
    super.key,
    required this.plugin,
    required this.modifications,
    this.enableIntelligenceRest = false,
    required this.onHandle,
  });

  @override
  State<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends State<WorkoutBuilderScreen> {
  ExerciseTypeFilter _selectedFilter = ExerciseTypeFilter.all;
  String? _selectedExercise;
  final List<_WorkoutExercise> _selectedExercises = [];

  List<ExerciseCatalogEntry> get _filteredExercises =>
      ExerciseCatalog.filteredExercises(_selectedFilter);

  void _chooseExercise() {
    final exercises = _filteredExercises;
    if (exercises.isEmpty) {
      return;
    }

    int tempIndex = 0;
    if (_selectedExercise != null) {
      final currentIndex = exercises.indexWhere(
        (exercise) => exercise.detector == _selectedExercise,
      );
      if (currentIndex >= 0) {
        tempIndex = currentIndex;
      }
    }

    final scrollController =
        FixedExtentScrollController(initialItem: tempIndex);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _selectedFilter == ExerciseTypeFilter.all
              ? 'Choose Exercise'
              : 'Choose Exercise (${exerciseFilterLabel(_selectedFilter)})',
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 180,
          child: ListWheelScrollView.useDelegate(
            controller: scrollController,
            itemExtent: 40,
            diameterRatio: 1.5,
            onSelectedItemChanged: (index) => tempIndex = index,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: exercises.length,
              builder: (_, index) => Center(
                child: Text(
                  exercises[index].detector,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedExercise = exercises[tempIndex].detector;
              });
              Navigator.pop(context);
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  void _addExercise() {
    if (_selectedExercise == null) {
      return;
    }

    setState(() {
      _selectedExercises.add(_WorkoutExercise(detector: _selectedExercise!));
    });
  }

  void _clearExercises() {
    setState(() {
      _selectedExercises.clear();
    });
  }

  Future<void> _startWorkout() async {
    if (_selectedExercises.isEmpty) {
      return;
    }

    await widget.plugin.setConfig(
      config:
          SMKitConfig(enableIntelligenceRest: widget.enableIntelligenceRest),
    );

    final exercises = _selectedExercises.map((exercise) {
      final entry = ExerciseCatalog.byDetector[exercise.detector];
      return SMKitExercise(
        prettyName: exercise.detector,
        totalSeconds: 60,
        videoInstruction:
            entry?.videoInstruction ?? '${exercise.detector}InstructionVideo',
        detector: exercise.detector,
        uiElements: entry?.uiElements ?? const [SMKitUIElement.timer],
      );
    }).toList();

    String? introUrl;
    try {
      final byteData = await rootBundle.load('customWorkoutIntro.mp3');
      final file = File(
        '${(await getTemporaryDirectory()).path}/customWorkoutIntro.mp3',
      );
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
      introUrl = file.path;
    } catch (_) {}

    await widget.plugin.startCustomizedWorkout(
      workout: SMKitWorkout(
        id: '',
        name: 'TEST WORKOUT',
        workoutIntro: introUrl,
        soundTrack: null,
        exercises: exercises,
        workoutClosure: null,
      ),
      modifications: widget.modifications,
      onHandle: widget.onHandle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final exerciseSummary = _selectedExercises.isEmpty
        ? 'Workout Exercises: None'
        : 'Workout Exercises (${_selectedExercises.length}):\n'
            '${_selectedExercises.asMap().entries.map((entry) => '${entry.key + 1}. ${entry.value.detector}').join('\n')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Builder')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ExerciseTypeFilter.values.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: ChoiceChip(
                        label: Text(exerciseFilterLabel(filter)),
                        selected: _selectedFilter == filter,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = filter;
                            if (_selectedExercise != null &&
                                !_filteredExercises.any(
                                  (exercise) =>
                                      exercise.detector == _selectedExercise,
                                )) {
                              _selectedExercise = null;
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedExercise != null
                        ? Colors.blue
                        : Colors.blueGrey,
                  ),
                  onPressed: _chooseExercise,
                  child: Text(
                    _selectedExercise ?? 'Choose exercise',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 300,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedExercise != null
                        ? Colors.green
                        : Colors.green.withValues(alpha: 0.5),
                  ),
                  onPressed: _selectedExercise != null ? _addExercise : null,
                  child: const Text(
                    '+ Add Exercise to Workout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                exerciseSummary,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 150,
                height: 35,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.8),
                  ),
                  onPressed: _clearExercises,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedExercises.isNotEmpty
                        ? Colors.blue
                        : Colors.grey.withValues(alpha: 0.5),
                  ),
                  onPressed:
                      _selectedExercises.isNotEmpty ? _startWorkout : null,
                  child: const Text(
                    'START WORKOUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

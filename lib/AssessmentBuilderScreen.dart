import 'package:flutter/material.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';

import 'exercise_catalog.dart';

class _SelectedAssessmentExercise {
  final int id;
  final ExerciseCatalogEntry entry;
  AssessmentScoringMode scoringMode;
  int duration;
  int targetReps;
  int targetTime;

  _SelectedAssessmentExercise({
    required this.id,
    required this.entry,
  })  : scoringMode = entry.defaultAssessmentMode,
        duration = entry.defaultDuration,
        targetReps = entry.defaultTargetReps,
        targetTime = entry.defaultTargetTime;
}

class AssessmentBuilderScreen extends StatefulWidget {
  final SmkitUiFlutterPlugin plugin;
  final Map<String, dynamic> modifications;
  final bool enableIntelligenceRest;
  final bool showSummary;
  final void Function(SMKitStatus) onHandle;

  const AssessmentBuilderScreen({
    super.key,
    required this.plugin,
    required this.modifications,
    required this.enableIntelligenceRest,
    required this.showSummary,
    required this.onHandle,
  });

  @override
  State<AssessmentBuilderScreen> createState() =>
      _AssessmentBuilderScreenState();
}

class _AssessmentBuilderScreenState extends State<AssessmentBuilderScreen> {
  ExerciseTypeFilter _selectedFilter = ExerciseTypeFilter.all;
  final List<_SelectedAssessmentExercise> _selectedExercises = [];
  int _nextExerciseId = 1;
  bool _isStarting = false;

  List<ExerciseCatalogEntry> get _filteredExercises =>
      ExerciseCatalog.filteredExercises(_selectedFilter);

  void _addExercise(ExerciseCatalogEntry entry) {
    setState(() {
      _selectedExercises.add(
        _SelectedAssessmentExercise(
          id: _nextExerciseId++,
          entry: entry,
        ),
      );
    });
  }

  void _removeExercise(int id) {
    setState(() {
      _selectedExercises.removeWhere((exercise) => exercise.id == id);
    });
  }

  void _clearExercises() {
    setState(() {
      _selectedExercises.clear();
    });
  }

  Future<void> _startAssessment() async {
    if (_selectedExercises.isEmpty || _isStarting) {
      return;
    }

    setState(() {
      _isStarting = true;
    });

    try {
      await widget.plugin.setSessionLanguage(language: SMKitLanguage.english);
      await widget.plugin.setCounterPreferences(
        counterPreferences: SMKitCounterPreferences.perfectOnly,
      );
      await widget.plugin.setEndExercisePreferences(
        endExercisePrefernces: SMKitEndExercisePreferences.targetBased,
      );
      await widget.plugin.setConfig(
        config: SMKitConfig(
          enableIntelligenceRest: widget.enableIntelligenceRest,
        ),
      );

      final exercises = _selectedExercises.map((selectedExercise) {
        final scoringType = switch (selectedExercise.scoringMode) {
          AssessmentScoringMode.reps => ScoringType.reps,
          AssessmentScoringMode.time => ScoringType.time,
          AssessmentScoringMode.rom => ScoringType.rom,
        };

        return SMKitExercise(
          prettyName: selectedExercise.entry.detector,
          totalSeconds: selectedExercise.duration,
          videoInstruction: selectedExercise.entry.videoInstruction,
          detector: selectedExercise.entry.detector,
          uiElements: selectedExercise.entry.uiElements,
          scoringParams: ScoringParams(
            type: scoringType,
            scoreFactor: 0.5,
            targetTime:
                selectedExercise.scoringMode == AssessmentScoringMode.time
                    ? selectedExercise.targetTime
                    : 0,
            targetReps:
                selectedExercise.scoringMode == AssessmentScoringMode.reps
                    ? selectedExercise.targetReps
                    : 0,
            targetRom: selectedExercise.scoringMode == AssessmentScoringMode.rom
                ? selectedExercise.entry.currentPlatformRomTarget ?? ''
                : '',
          ),
        );
      }).toList();

      await widget.plugin.startCustomizedAssessment(
        assessment: SMKitWorkout(
          id: 'demo-custom-assessment',
          name: 'Custom Assessment',
          exercises: exercises,
        ),
        showSummary: widget.showSummary,
        modifications: widget.modifications,
        onHandle: widget.onHandle,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to start assessment: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Builder'),
        actions: [
          TextButton(
            onPressed: _selectedExercises.isEmpty ? null : _clearExercises,
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PaneShell(
                title: 'Assessment',
                child: _buildSelectedExercisesSection(),
              ),
              const SizedBox(height: 20),
              _PaneShell(
                title: 'All Exercises',
                child: _buildCatalogSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exercise Types',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ExerciseTypeFilter.values
                .where((filter) => filter != ExerciseTypeFilter.bodyAssessment)
                .map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  key: ValueKey('filter-${filter.name}'),
                  label: Text(exerciseFilterLabel(filter)),
                  selected: _selectedFilter == filter,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredExercises.length,
          itemBuilder: (context, index) {
            final entry = _filteredExercises[index];
            final displayType = entry.type == ExerciseTypeFilter.bodyAssessment
                ? ExerciseTypeFilter.mobility
                : entry.type;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.detector,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text(
                            exerciseFilterLabel(displayType),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        for (final mode in entry.assessmentModes)
                          Chip(
                            label: Text(
                              assessmentScoringModeLabel(mode),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        key: ValueKey('add-${entry.detector}'),
                        onPressed: () => _addExercise(entry),
                        child: const Text('Add To Assessment'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSelectedExercisesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Exercises (${_selectedExercises.length})'),
        const SizedBox(height: 8),
        if (_selectedExercises.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Add at least one exercise to build an assessment.',
              ),
            ),
          ),
        if (_selectedExercises.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedExercises.length,
            itemBuilder: (context, index) {
              final selectedExercise = _selectedExercises[index];
              return _AssessmentExerciseCard(
                exercise: selectedExercise,
                onRemove: () => _removeExercise(selectedExercise.id),
                onScoringModeChanged: (mode) {
                  setState(() {
                    selectedExercise.scoringMode = mode;
                  });
                },
                onDurationChanged: (value) {
                  setState(() {
                    selectedExercise.duration = value;
                  });
                },
                onTargetRepsChanged: (value) {
                  setState(() {
                    selectedExercise.targetReps = value;
                  });
                },
                onTargetTimeChanged: (value) {
                  setState(() {
                    selectedExercise.targetTime = value;
                  });
                },
              );
            },
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedExercises.isEmpty || _isStarting
                ? null
                : _startAssessment,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _isStarting ? 'STARTING...' : 'START ASSESSMENT',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaneShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _PaneShell({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _AssessmentExerciseCard extends StatelessWidget {
  final _SelectedAssessmentExercise exercise;
  final VoidCallback onRemove;
  final ValueChanged<AssessmentScoringMode> onScoringModeChanged;
  final ValueChanged<int> onDurationChanged;
  final ValueChanged<int> onTargetRepsChanged;
  final ValueChanged<int> onTargetTimeChanged;

  const _AssessmentExerciseCard({
    required this.exercise,
    required this.onRemove,
    required this.onScoringModeChanged,
    required this.onDurationChanged,
    required this.onTargetRepsChanged,
    required this.onTargetTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final entry = exercise.entry;

    return Card(
      key: ValueKey('selected-${exercise.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.detector,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Supports: ${entry.assessmentModes.map(assessmentScoringModeLabel).join(' / ')}',
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove exercise',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AdjustableValueRow(
              key: ValueKey('duration-${exercise.id}'),
              label: 'Duration',
              value: exercise.duration,
              min: 1,
              max: 60,
              unit: 'sec',
              onChanged: onDurationChanged,
            ),
            if (entry.assessmentModes.length > 1) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<AssessmentScoringMode>(
                key: ValueKey('mode-${exercise.id}'),
                initialValue: exercise.scoringMode,
                decoration: const InputDecoration(
                  labelText: 'Scoring Type',
                  border: OutlineInputBorder(),
                ),
                items: entry.assessmentModes.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(assessmentScoringModeLabel(mode)),
                  );
                }).toList(),
                onChanged: (mode) {
                  if (mode != null) {
                    onScoringModeChanged(mode);
                  }
                },
              ),
            ],
            if (exercise.scoringMode == AssessmentScoringMode.reps) ...[
              const SizedBox(height: 12),
              _AdjustableValueRow(
                key: ValueKey('reps-${exercise.id}'),
                label: 'Target reps',
                value: exercise.targetReps,
                min: 1,
                max: 10,
                unit: 'reps',
                onChanged: onTargetRepsChanged,
              ),
            ],
            if (exercise.scoringMode == AssessmentScoringMode.time) ...[
              const SizedBox(height: 12),
              _AdjustableValueRow(
                key: ValueKey('time-${exercise.id}'),
                label: 'Target time',
                value: exercise.targetTime,
                min: 1,
                max: 60,
                unit: 'sec',
                onChanged: onTargetTimeChanged,
              ),
            ],
            if (exercise.scoringMode == AssessmentScoringMode.rom) ...[
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Target ROM',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  entry.currentPlatformRomTarget ?? 'Unavailable',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdjustableValueRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final String unit;
  final ValueChanged<int> onChanged;

  const _AdjustableValueRow({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label: $value $unit',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';

class WorkoutResultScreen extends StatelessWidget {
  final SMKitData workoutResult;

  const WorkoutResultScreen({super.key, required this.workoutResult});

  @override
  Widget build(BuildContext context) {
    final data = workoutResult;
    final exercises = data is SMKitAssessmentSummaryData
        ? data.exercises
        : data is SMCustomWorkoutData
        ? data.exercises ?? <SMKitExerciseData>[]
        : <SMKitExerciseData>[];
    final sessionId = data is SMKitAssessmentSummaryData
        ? data.sessionId
        : data is SMCustomWorkoutData
        ? data.sessionId
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Result')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (sessionId != null) Text('Session: $sessionId'),
          if (exercises.isEmpty) Text(data.toString()),
          for (var index = 0; index < exercises.length; index++)
            _exerciseCard(index + 1, exercises[index]),
        ],
      ),
    );
  }

  Widget _exerciseCard(int number, SMKitExerciseData exercise) {
    final insights = exercise.internalInsights?['entries'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercise $number: ${exercise.exerciseInfo?.prettyName ?? exercise.summaryTitle ?? 'Unknown'}',
            ),
            Text(
              'Duration: ${exercise.startTime ?? '—'} → ${exercise.endTime ?? '—'}',
            ),
            if (exercise.repsPerformed != null)
              Text(
                'Reps: ${exercise.repsPerformed} (${exercise.repsPerformedPerfect ?? 0} perfect)',
              ),
            if (exercise.timeInPosition != null)
              Text('Time in position: ${exercise.timeInPosition}s'),
            if (exercise.positionRepConfig != null)
              Text('Position reps: ${exercise.positionRepConfig}'),
            if (exercise.avgRepTimeSeconds != null)
              Text('Average rep time: ${exercise.avgRepTimeSeconds}s'),
            if (exercise.maxConsecutiveHoldSeconds != null)
              Text('Longest hold: ${exercise.maxConsecutiveHoldSeconds}s'),
            if (exercise.maxConsecutivePerfectHoldSeconds != null)
              Text(
                'Longest perfect hold: ${exercise.maxConsecutivePerfectHoldSeconds}s',
              ),
            if (insights is List && insights.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Assessment insights',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              for (final entry in insights)
                if (entry is Map)
                  Text(
                    '${entry['insight'] ?? ''}${entry['impact'] == null ? '' : ' (${entry['impact']})'}',
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

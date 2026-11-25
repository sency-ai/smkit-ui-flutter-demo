import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';

/// In-memory log of SDK events and live-control results, newest first.
class DemoEventLog extends ChangeNotifier {
  DemoEventLog._();
  static final DemoEventLog instance = DemoEventLog._();

  static const _maxEntries = 200;
  final List<DemoLogEntry> _entries = [];

  List<DemoLogEntry> get entries => List.unmodifiable(_entries);

  void add(String title, [Object? details]) {
    final text = details == null ? null : _format(details);
    debugPrint('SMKitUI demo: $title${text == null ? '' : ' $text'}');
    _entries.insert(0, DemoLogEntry(DateTime.now(), title, text));
    if (_entries.length > _maxEntries) _entries.removeLast();
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }

  void addRecoveredSession(SMKitRecoveredSessionSummary session) =>
      add('Recovered session (${session.faultCode})', {
        'recoveredAfterRelaunch': session.recoveredAfterRelaunch,
        'recoveredAt': session.recoveredAt.toIso8601String(),
        'sessionResult': session.sessionResult,
        // iOS only; always null on Android.
        'workoutSummary': session.workoutSummary,
      });

  /// Records the workout events the demo does not otherwise act on.
  void addStatus(SMKitStatus status) {
    final data = status.data;
    switch (status.operation) {
      case SMKitOperation.exerciseWillStart:
        if (data is SMKitExerciseStartData) {
          add('Exercise will start: ${data.exerciseName ?? data.detector}', {
            'sessionId': data.sessionId,
            'detector': data.detector,
            'exerciseIndex': data.exerciseIndex,
            'exerciseCount': data.exerciseCount,
            'durationSeconds': data.durationSeconds,
            'targetReps': data.targetReps,
            'targetHoldSeconds': data.targetHoldSeconds,
            'logicalExerciseId': data.logicalExerciseId,
            'isMobilityFlow': data.isMobilityFlow,
          });
        }
      case SMKitOperation.exerciseData:
        if (data is SMKitExerciseData) {
          add(
            'Exercise finished: ${data.exerciseInfo?.prettyName ?? data.activityType ?? ''}',
            {
              'repsPerformed': data.repsPerformed,
              'timeInPosition': data.timeInPosition,
              'techniqueScore': data.techniqueScore,
              'mobilityFlowSummary': data.mobilityFlowSummary,
              'mobilityRepConfig': data.mobilityRepConfig,
              'paceLimitDetectedCount': data.paceLimitDetectedCount,
            },
          );
        } else {
          add('Exercise finished', data?.toString());
        }
      case SMKitOperation.assessmentSummaryData ||
          SMKitOperation.workoutSummaryData:
        final modifications = switch (data) {
          SMKitAssessmentSummaryData summary => summary.modifications,
          SMCustomWorkoutData summary => summary.modifications,
          _ => null,
        };
        if (modifications != null && modifications.isNotEmpty) {
          add(
            'Workout modifications (${modifications.length})',
            modifications.map(modificationDetails).toList(),
          );
        }
      case SMKitOperation.workoutPreparationDidFinish:
        add('Workout preparation finished');
      case SMKitOperation.workoutPreparationDidCancel:
        add('Workout preparation cancelled');
      default:
        break;
    }
  }

  /// A swap, added rest or similar change the user made during the workout.
  static Map<String, Object?> modificationDetails(
    SMKitWorkoutModificationEvent event,
  ) => {
    'type': event.type,
    'timestamp': event.timestamp,
    'source': event.source,
    'sourceDetector': event.sourceDetector,
    'appliedDetector': event.appliedDetector,
    'pairedDetector': event.pairedDetector,
    'restSeconds': event.restSeconds,
  };

  /// Every field of a native diagnostic, for the event log.
  static Map<String, Object?> diagnosticDetails(SMKitDiagnosticEvent event) => {
    'name': event.name,
    'category': event.category,
    'severity': event.severity,
    'message': event.message,
    'timestamp': event.timestamp.toIso8601String(),
    'errorDomain': event.errorDomain,
    'errorCode': event.errorCode,
    if (event.properties.isNotEmpty) 'properties': event.properties,
  };

  static String _format(Object details) {
    if (details is String) return details;
    if (details is List) {
      final clean = details
          .map(
            (item) => item is Map
                ? (Map.of(item)..removeWhere((_, value) => value == null))
                : item,
          )
          .toList();
      try {
        return const JsonEncoder.withIndent('  ').convert(clean);
      } catch (_) {
        return clean.toString();
      }
    }
    if (details is Map) {
      final clean = Map.of(details)..removeWhere((_, value) => value == null);
      try {
        return const JsonEncoder.withIndent('  ').convert(clean);
      } catch (_) {
        return clean.toString();
      }
    }
    return details.toString();
  }
}

class DemoLogEntry {
  final DateTime time;
  final String title;
  final String? details;
  const DemoLogEntry(this.time, this.title, this.details);
}

class EventLogScreen extends StatelessWidget {
  const EventLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final log = DemoEventLog.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Log'),
        actions: [TextButton(onPressed: log.clear, child: const Text('Clear'))],
      ),
      body: ListenableBuilder(
        listenable: log,
        builder: (context, _) {
          final entries = log.entries;
          if (entries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Exercise starts, exercise results, preparation events and '
                  'live-control results appear here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final time = TimeOfDay.fromDateTime(entry.time).format(context);
              return ExpansionTile(
                title: Text(entry.title),
                subtitle: Text(time),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                children: [
                  if (entry.details != null)
                    SelectableText(
                      entry.details!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

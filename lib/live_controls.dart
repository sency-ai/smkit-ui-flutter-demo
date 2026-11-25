import 'dart:async';
import 'dart:io';

import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';

import 'demo_event_log.dart';
import 'demo_settings.dart';

/// A host-side action the demo runs a few seconds after an exercise starts.
/// The SDK screen covers the app during a workout, so the demo scripts these
/// instead of showing buttons.
enum LiveControlAction {
  none,
  logProgress,
  pauseThenResume,
  skipExercise,
  restartExercise,
  updateFutureTargets,
  insertRest,
  commandPauseThenResume;

  bool get isAvailable => switch (this) {
    LiveControlAction.updateFutureTargets => Platform.isAndroid,
    LiveControlAction.insertRest ||
    LiveControlAction.commandPauseThenResume => Platform.isIOS,
    _ => true,
  };

  String get label => switch (this) {
    LiveControlAction.none => 'None',
    LiveControlAction.logProgress => 'Log live progress',
    LiveControlAction.pauseThenResume => 'Pause 5 s, then resume',
    LiveControlAction.skipExercise => 'Skip exercise',
    LiveControlAction.restartExercise => 'Restart exercise (once)',
    LiveControlAction.updateFutureTargets => 'Add 2 reps to later sets',
    LiveControlAction.insertRest => 'Insert 30 s rest',
    LiveControlAction.commandPauseThenResume => 'Styled pause, then resume',
  };
}

class LiveControlRunner {
  LiveControlRunner(this._plugin, this._settings);

  final SmkitUiFlutterPlugin _plugin;
  final DemoSettings _settings;
  final DemoEventLog _log = DemoEventLog.instance;
  Timer? _timer;
  final Set<String> _restartedSessions = {};

  void onExerciseWillStart(SMKitExerciseStartData data) {
    _timer?.cancel();
    final selected = _settings.liveControlAction;
    if (selected == LiveControlAction.none || !selected.isAvailable) return;
    // Restarting starts the same exercise again; do it once per session.
    if (selected == LiveControlAction.restartExercise &&
        !_restartedSessions.add(data.sessionId)) {
      return;
    }
    _timer = Timer(Duration(seconds: _settings.liveControlDelaySeconds), () {
      unawaited(_run(selected, data));
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _run(
    LiveControlAction selected,
    SMKitExerciseStartData data,
  ) async {
    final name = selected.label;
    try {
      switch (selected) {
        case LiveControlAction.none:
          return;
        case LiveControlAction.logProgress:
          _log.add(
            'Live progress',
            await _plugin.getLiveWorkoutProgress() ??
                'null (no current exercise)',
          );
        case LiveControlAction.pauseThenResume:
          await _plugin.pauseSdk();
          _log.add('pauseSdk sent');
          await Future<void>.delayed(const Duration(seconds: 5));
          await _plugin.resumeSdk();
          _log.add('resumeSdk sent');
        case LiveControlAction.skipExercise:
          _log.add(
            'skipCurrentExercise',
            'returned ${await _plugin.skipCurrentExercise()}',
          );
        case LiveControlAction.restartExercise:
          _log.add(
            'restartCurrentExercise',
            'returned ${await _plugin.restartCurrentExercise()}',
          );
        case LiveControlAction.updateFutureTargets:
          final progress = await _plugin.getLiveWorkoutProgress();
          final sessionId = progress?['sessionId'] as String? ?? data.sessionId;
          final logicalId =
              progress?['logicalExerciseId'] as String? ??
              data.logicalExerciseId;
          final reps =
              (progress?['targetReps'] as num?)?.toInt() ?? data.targetReps;
          if (logicalId == null || reps == null) {
            _log.add(
              'updateFutureExerciseTargets skipped',
              'The current exercise has no logical ID or rep target.',
            );
            return;
          }
          final changed = await _plugin.updateFutureExerciseTargets(
            sessionId: sessionId,
            logicalExerciseId: logicalId,
            reps: reps + 2,
          );
          _log.add(
            'updateFutureExerciseTargets',
            'Changed $changed later set(s) to ${reps + 2} reps.',
          );
        case LiveControlAction.insertRest:
          await _command(SMKitWorkoutCommand.insertRest(30));
        case LiveControlAction.commandPauseThenResume:
          final paused = await _command(
            SMKitWorkoutCommand.pause(showsPauseMenu: false),
          );
          if (!paused) return;
          await Future<void>.delayed(const Duration(seconds: 5));
          await _command(SMKitWorkoutCommand.resume(playsCue: true));
      }
    } catch (error) {
      _log.add('$name failed', error.toString());
    }
  }

  Future<bool> _command(SMKitWorkoutCommand command) async {
    // The token pins the command to the exercise the decision was made for.
    final token = await _plugin.getWorkoutCommandToken();
    if (token == null) {
      _log.add('${command.type} skipped', 'No workout is active.');
      return false;
    }
    final result = await _plugin.performWorkoutCommand(command, token: token);
    _log.add(
      '${command.type} ${result.accepted ? 'accepted' : 'rejected'}',
      result.reason,
    );
    return result.accepted;
  }
}

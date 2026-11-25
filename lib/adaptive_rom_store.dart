import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';
import 'package:path_provider/path_provider.dart';

/// Keeps each exercise's latest `adaptiveRom` snapshot from workout summaries
/// in a JSON file, so the demo can restore ROM history with
/// `mergeAdaptiveRomPilotCache` on a later launch. A real app would keep these
/// in the user's account history.
class AdaptiveRomStore {
  AdaptiveRomStore._();
  static final AdaptiveRomStore instance = AdaptiveRomStore._();

  final Map<String, Map<String, dynamic>> _byKey = {};
  bool _loaded = false;

  int get count => _byKey.length;
  List<Map<String, dynamic>> get snapshots => _byKey.values.toList();

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/adaptive_rom_snapshots.json');
  }

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final file = await _file();
      if (!await file.exists()) return;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map) {
        decoded.forEach((key, value) {
          if (value is Map) _byKey['$key'] = Map<String, dynamic>.from(value);
        });
      }
    } catch (error) {
      debugPrint('Could not read adaptive ROM snapshots: $error');
    }
  }

  /// Saves the adaptive ROM payload of every exercise in a summary.
  Future<int> saveFrom(Object? summary) async {
    final exercises = switch (summary) {
      SMCustomWorkoutData data => data.exercises ?? const <SMKitExerciseData>[],
      SMKitAssessmentSummaryData data => data.exercises,
      _ => const <SMKitExerciseData>[],
    };
    var saved = 0;
    for (final exercise in exercises) {
      final snapshot = exercise.adaptiveRom;
      if (snapshot == null || snapshot.isEmpty) continue;
      final key =
          '${snapshot['detector'] ?? exercise.exerciseInfo?.exerciseID ?? exercise.activityType}';
      _byKey[key] = snapshot;
      saved++;
    }
    if (saved > 0) await _write();
    return saved;
  }

  Future<void> clear() async {
    _byKey.clear();
    await _write();
  }

  Future<void> _write() async {
    try {
      await (await _file()).writeAsString(jsonEncode(_byKey));
    } catch (error) {
      debugPrint('Could not save adaptive ROM snapshots: $error');
    }
  }
}

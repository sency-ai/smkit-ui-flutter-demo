import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';

import 'demo_settings.dart';
import 'exercise_catalog.dart';

class GuidanceModeScreen extends StatefulWidget {
  final SmkitUiFlutterPlugin plugin;
  final DemoSettings settings;
  final bool showSummary;
  final void Function(SMKitStatus) onHandle;

  const GuidanceModeScreen({
    super.key,
    required this.plugin,
    required this.settings,
    required this.showSummary,
    required this.onHandle,
  });

  @override
  State<GuidanceModeScreen> createState() => _GuidanceModeScreenState();
}

class _GuidanceModeScreenState extends State<GuidanceModeScreen> {
  final _searchController = TextEditingController();
  List<String> _detectors = [];
  bool _loading = true;
  String? _startingDetector;

  @override
  void initState() {
    super.initState();
    _loadDetectors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDetectors() async {
    List<String> detectors;
    try {
      detectors = await widget.plugin.getSupportedMovements() ?? [];
    } catch (_) {
      // Android 1.8.0 does not expose the catalog through SMKitUI. Its static
      // catalog keeps this demo flow available there as well.
      detectors = [];
    }
    if (detectors.isEmpty) {
      detectors = ExerciseCatalog.byDetector.keys.toList();
    }
    detectors =
        detectors
            .where((detector) => detector.toLowerCase() != 'rowing')
            .toSet()
            .toList()
          ..sort(
            (a, b) => _displayNameForDetector(
              a,
            ).compareTo(_displayNameForDetector(b)),
          );

    if (!mounted) return;
    setState(() {
      _detectors = detectors;
      _loading = false;
    });
  }

  List<String> get _filteredDetectors {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _detectors;
    return _detectors
        .where(
          (detector) =>
              detector.toLowerCase().contains(query) ||
              _displayNameForDetector(detector).toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> _startGuidance(String detector) async {
    setState(() => _startingDetector = detector);
    try {
      // getExerciseType is part of the iOS demo's runtime catalog. Android
      // 1.8.0 falls back to the bundled catalog until the native UI API offers
      // the same accessor.
      final nativeType = Platform.isIOS
          ? await widget.plugin.getExerciseType(detector: detector)
          : null;
      final entry = ExerciseCatalog.byDetector[detector];
      final isDynamic =
          nativeType?.toLowerCase().contains('dynamic') ??
          entry?.type == ExerciseTypeFilter.dynamic_;
      final uiElements =
          entry?.uiElements ??
          (isDynamic
              ? const [SMKitUIElement.timer, SMKitUIElement.repsCounter]
              : const [
                  SMKitUIElement.timer,
                  SMKitUIElement.gaugeOfMotion,
                  SMKitUIElement.holdingPosition,
                ]);

      await widget.settings.applyTo(widget.plugin);
      await widget.plugin.startCustomizedWorkout(
        workout: SMKitWorkout(
          id: 'guidance-$detector',
          name: 'Guidance Mode',
          exercises: [
            SMKitExercise(
              prettyName: _displayNameForDetector(detector),
              totalSeconds: isDynamic ? 30 : 10,
              videoInstruction:
                  entry?.videoInstruction ?? '${detector}InstructionVideo',
              detector: detector,
              uiElements: uiElements,
              guidanceMode: true,
              enableGuidanceModeSuggestion:
                  widget.settings.guidanceModeSuggestion,
              enableSmallBodyPartFocus:
                  widget.settings.enableSmallBodyPartFocus,
              internalInsightsKey: detector,
            ),
          ],
        ),
        showSummary: widget.showSummary,
        modifications: widget.settings.modifications,
        onHandle: widget.onHandle,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to start guidance mode: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _startingDetector = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guidance Mode')),
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
            const SizedBox(height: 16),
            const Text(
              'Supported Guidance Exercises',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_filteredDetectors.isEmpty)
              const Text('No supported movements found.')
            else
              ..._filteredDetectors.map(
                (detector) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.assistant_outlined),
                  title: Text(_displayNameForDetector(detector)),
                  subtitle: Text(detector),
                  trailing: _startingDetector == detector
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  enabled: _startingDetector == null,
                  onTap: _startingDetector == null
                      ? () => _startGuidance(detector)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _displayNameForDetector(String detector) {
  return detector
      .replaceAll('QL', 'Q L')
      .replaceAll('IT', 'I T')
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match[1]} ${match[2]}',
      );
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';

import 'adaptive_rom_store.dart';
import 'demo_event_log.dart';

/// Recovered sessions the demo consumed this run. The SDK hands each one out
/// once, so the demo keeps them here.
final List<SMKitRecoveredSessionSummary> recoveredSessions = [];

/// SDK calls that do not start a workout: media, asset preparation, recovery,
/// adaptive ROM history, customer assets and (iOS) video input.
class SdkToolsScreen extends StatefulWidget {
  final SmkitUiFlutterPlugin plugin;

  const SdkToolsScreen({super.key, required this.plugin});

  @override
  State<SdkToolsScreen> createState() => _SdkToolsScreenState();
}

class _SdkToolsScreenState extends State<SdkToolsScreen> {
  SmkitUiFlutterPlugin get plugin => widget.plugin;

  final _detectorController = TextEditingController(text: 'SquatRegular');
  final _predownloadController = TextEditingController(
    text: 'SquatRegular, HighKnees, RhomboidStretch',
  );
  final _assetController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _fpsController = TextEditingController();

  bool _predownloadMobilityFlow = false;
  String? _busy;
  String? _videoPath;
  Uint8List? _thumbnail;
  String? _mediaMessage;
  String? _predownloadMessage;
  String? _romMessage;
  String? _assetMessage;
  String? _videoMessage;

  @override
  void initState() {
    super.initState();
    AdaptiveRomStore.instance.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _detectorController.dispose();
    _predownloadController.dispose();
    _assetController.dispose();
    _videoUrlController.dispose();
    _fpsController.dispose();
    super.dispose();
  }

  Future<void> _run(String name, Future<void> Function() body) async {
    setState(() => _busy = name);
    try {
      await body();
    } catch (error) {
      DemoEventLog.instance.add('$name failed', error.toString());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$name failed: $error')));
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  List<String> _split(String text) => text
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  Future<void> _loadVideo() => _run('loadInstructionVideo', () async {
    final path = await plugin.loadInstructionVideo(
      _detectorController.text.trim(),
    );
    setState(() {
      _videoPath = path;
      _mediaMessage = path == null
          ? 'No instruction video for this detector.'
          : null;
    });
  });

  Future<void> _loadThumbnail() =>
      _run('loadInstructionVideoThumbnail', () async {
        final uri = await plugin.loadInstructionVideoThumbnail(
          _detectorController.text.trim(),
        );
        Uint8List? bytes;
        if (uri != null) {
          final comma = uri.indexOf(',');
          bytes = base64Decode(comma >= 0 ? uri.substring(comma + 1) : uri);
        }
        setState(() {
          _thumbnail = bytes;
          _mediaMessage = bytes == null
              ? 'No thumbnail for this detector.'
              : null;
        });
      });

  Future<void> _predownload() => _run('predownloadWorkoutAssets', () async {
    final detectors = _split(_predownloadController.text);
    if (detectors.isEmpty) return;
    setState(() => _predownloadMessage = 'Downloading…');
    final ready = await plugin.predownloadWorkoutAssets(
      detectors,
      mobilityFlow: _predownloadMobilityFlow,
    );
    setState(() => _predownloadMessage = ready ? 'Assets ready' : 'Not ready');
  });

  Future<void> _consumeRecovered() => _run(
    'consumeRecoveredSessionSummaries',
    () async {
      final sessions = await plugin.consumeRecoveredSessionSummaries();
      recoveredSessions.addAll(sessions);
      for (final session in sessions) {
        DemoEventLog.instance.addRecoveredSession(session);
      }
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${sessions.length} new recovered session(s)')),
      );
    },
  );

  Future<void> _mergeRom() => _run('mergeAdaptiveRomPilotCache', () async {
    final snapshots = AdaptiveRomStore.instance.snapshots;
    if (snapshots.isEmpty) {
      setState(
        () => _romMessage =
            'Nothing saved yet. Finish a workout with adaptive ROM first.',
      );
      return;
    }
    final accepted = await plugin.mergeAdaptiveRomPilotCache(snapshots);
    setState(
      () => _romMessage =
          'SDK accepted $accepted of ${snapshots.length} snapshot(s).',
    );
  });

  Future<void> _clearSavedRom() => _run('Clear saved ROM history', () async {
    await AdaptiveRomStore.instance.clear();
    setState(() => _romMessage = 'Saved snapshots cleared.');
  });

  Future<void> _assetPath({required bool request}) => _run(
    request ? 'requestCustomerAssetPath' : 'getCustomerAssetPath',
    () async {
      final identifier = _assetController.text.trim();
      if (identifier.isEmpty) return;
      final path = request
          ? await plugin.requestCustomerAssetPath(identifier: identifier)
          : await plugin.getCustomerAssetPath(identifier: identifier);
      setState(() => _assetMessage = path ?? 'Not available');
    },
  );

  Future<void> _setVideo() => _run('setVideo', () async {
    final url = _videoUrlController.text.trim();
    if (url.isEmpty) return;
    await plugin.setVideo(
      url,
      limitFps: double.tryParse(_fpsController.text.trim()),
    );
    setState(
      () => _videoMessage = 'The next session reads frames from this video.',
    );
  });

  @override
  Widget build(BuildContext context) {
    final rom = AdaptiveRomStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('SDK Tools')),
      body: AbsorbPointer(
        absorbing: _busy != null,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_busy != null) const LinearProgressIndicator(),
            _section('Instruction media'),
            TextField(
              controller: _detectorController,
              decoration: const InputDecoration(labelText: 'Detector'),
            ),
            _buttons([
              OutlinedButton(
                onPressed: _loadVideo,
                child: const Text('Load video'),
              ),
              OutlinedButton(
                onPressed: _loadThumbnail,
                child: const Text('Load thumbnail'),
              ),
            ]),
            if (_mediaMessage != null) Text(_mediaMessage!),
            if (_videoPath != null) SelectableText('Video: $_videoPath'),
            if (_thumbnail != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.memory(
                  _thumbnail!,
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),

            _section('Pre-download workout assets'),
            TextField(
              controller: _predownloadController,
              decoration: const InputDecoration(
                labelText: 'Detectors (comma-separated)',
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Include Mobility Flow assets'),
              value: _predownloadMobilityFlow,
              onChanged: (value) =>
                  setState(() => _predownloadMobilityFlow = value),
            ),
            _buttons([
              OutlinedButton(
                onPressed: _predownload,
                child: const Text('Pre-download'),
              ),
            ]),
            if (_predownloadMessage != null) Text(_predownloadMessage!),

            _section('Recovered sessions'),
            const Text(
              'Sessions the SDK saved after a fault or after the app was killed '
              'mid-workout. The demo checks after configuring; each one is '
              'returned only once.',
            ),
            _buttons([
              OutlinedButton(
                onPressed: _consumeRecovered,
                child: const Text('Check now'),
              ),
            ]),
            if (recoveredSessions.isEmpty)
              const Text('None this run.')
            else
              ...recoveredSessions.map(
                (session) => ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text('Fault ${session.faultCode}'),
                  subtitle: Text(
                    '${session.recoveredAt.toLocal()}'
                    '${session.recoveredAfterRelaunch ? ' · after relaunch' : ''}',
                  ),
                  children: [
                    SelectableText(
                      const JsonEncoder.withIndent('  ').convert({
                        'sessionResult': session.sessionResult,
                        // iOS only; always null on Android.
                        if (session.workoutSummary != null)
                          'workoutSummary': session.workoutSummary,
                      }),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            _section('Adaptive ROM history'),
            Text(
              '${rom.count} exercise snapshot(s) saved from finished workouts. '
              'Restore them between workouts so the SDK keeps each '
              "user's range-of-motion targets.",
            ),
            _buttons([
              OutlinedButton(
                onPressed: _mergeRom,
                child: const Text('Restore into SDK'),
              ),
              TextButton(
                onPressed: _clearSavedRom,
                child: const Text('Clear saved'),
              ),
            ]),
            if (_romMessage != null) Text(_romMessage!),

            _section('Customer assets'),
            TextField(
              controller: _assetController,
              decoration: const InputDecoration(
                labelText: 'Customer asset identifier',
              ),
            ),
            _buttons([
              OutlinedButton(
                onPressed: () => _assetPath(request: false),
                child: const Text('Local path only'),
              ),
              OutlinedButton(
                onPressed: () => _assetPath(request: true),
                child: Text(Platform.isIOS ? 'Request (downloads)' : 'Request'),
              ),
            ]),
            if (_assetMessage != null) SelectableText(_assetMessage!),

            if (Platform.isIOS) ...[
              _section('Video input (iOS)'),
              const Text(
                'Run the next session on a recorded video instead of the '
                'camera, for testing.',
              ),
              TextField(
                controller: _videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Video URL (file:// or https://)',
                ),
              ),
              TextField(
                controller: _fpsController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Frame-rate limit (optional)',
                ),
              ),
              _buttons([
                OutlinedButton(
                  onPressed: _setVideo,
                  child: const Text('Use video'),
                ),
              ]),
              if (_videoMessage != null) Text(_videoMessage!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buttons(List<Widget> children) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Wrap(spacing: 8, runSpacing: 8, children: children),
  );
}

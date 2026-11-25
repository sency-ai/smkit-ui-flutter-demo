import 'package:flutter/material.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';

import 'demo_event_log.dart';
import 'demo_settings.dart';

/// Hosted alongside the demo; the main demo workout uses it as an intro.
const highKneesSoundUrl =
    'https://github.com/sency-ai/smkit-ui-flutter-demo/raw/main/HighKneesSound.mp3';

/// One-tap workouts that show exercise options the workout builder does not.
class FeatureExample {
  final String title;
  final String description;
  final SMKitWorkout Function() build;

  const FeatureExample({
    required this.title,
    required this.description,
    required this.build,
  });

  static final List<FeatureExample> all = [
    FeatureExample(
      title: 'Mobility Flow',
      description:
          'A 10-second rhomboid stretch hold, then 3 butterfly reps. '
          'Per-block results arrive in mobilityFlowSummary.',
      build: () => SMKitWorkout(
        id: 'mobility-flow',
        name: 'Mobility Flow',
        exercises: [
          SMKitExercise.mobilityFlow(
            const SMKitMobilityFlowConfig([
              SMKitMobilityFlowBlock.hold(
                'RhomboidStretch',
                repetitions: 1,
                secondsPerRep: 10,
              ),
              SMKitMobilityFlowBlock.reps('ButterflyPose', targetReps: 3),
            ]),
          ),
        ],
      ),
    ),
    FeatureExample(
      title: 'Mobility Flow without the 5-second cue',
      description:
          'Two 15-second rhomboid stretch holds with '
          'fiveSecondsLeftCueEnabled off, so no "5 seconds left" voice plays.',
      build: () => SMKitWorkout(
        id: 'mobility-flow-quiet',
        name: 'Mobility Flow, no cue',
        exercises: [
          SMKitExercise.mobilityFlow(
            const SMKitMobilityFlowConfig([
              SMKitMobilityFlowBlock.hold(
                'RhomboidStretch',
                repetitions: 2,
                secondsPerRep: 15,
              ),
            ], fiveSecondsLeftCueEnabled: false),
          ),
        ],
      ),
    ),
    FeatureExample(
      title: 'Mobility reps',
      description:
          'Butterfly pose counted as 6 reps instead of a timed hold, '
          'using mobilityRepConfig.',
      build: () => SMKitWorkout(
        id: 'mobility-reps',
        name: 'Mobility reps',
        exercises: [
          SMKitExercise(
            detector: 'ButterflyPose',
            prettyName: 'Butterfly Pose',
            totalSeconds: 60,
            uiElements: [SMKitUIElement.repsCounter, SMKitUIElement.timer],
            mobilityRepConfig: const SMKitMobilityRepConfig(targetReps: 6),
          ),
        ],
      ),
    ),
    FeatureExample(
      title: 'Combination (Combo04)',
      description:
          'Each round is 2 squats then 1 standing hip abduction, '
          'always on the left side.',
      build: () => SMKitWorkout(
        id: 'combo04',
        name: 'Combination',
        exercises: [
          SMKitExercise(
            detector: 'Combo04',
            prettyName: 'Squat + Hip Abduction',
            totalSeconds: 60,
            targetReps: 4,
            exerciseIntro: 'ComboSequenceIntro',
            uiElements: [SMKitUIElement.repsCounter, SMKitUIElement.timer],
            combinationOptions: const SMKitCombinationOptions(
              firstReps: 2,
              secondReps: 1,
              fixedSide: SMKitCombinationSide.left,
            ),
          ),
        ],
      ),
    ),
    FeatureExample(
      title: 'Quick motion',
      description:
          'High knees with the quick-motion indicator, checked every '
          '0.25 s over a 0.75 s window.',
      build: () => SMKitWorkout(
        id: 'quick-motion',
        name: 'Quick motion',
        exercises: [
          SMKitExercise(
            detector: 'HighKnees',
            prettyName: 'High Knees',
            totalSeconds: 30,
            videoInstruction: 'HighKnees',
            uiElements: [SMKitUIElement.quickMotion, SMKitUIElement.timer],
            quickMotionParams: const SMKitQuickMotionParams(
              validityWindow: 0.75,
              checkInterval: 0.25,
            ),
          ),
        ],
      ),
    ),
    FeatureExample(
      title: 'Stretch set with alternating positions',
      description:
          'Seated lumbar camel-cat as 2 sets of 5-second holds with 3 s rest. '
          'The SDK alternates camel and cat from the detector; '
          'positionDetectors names both positions in the results.',
      build: () => SMKitWorkout(
        id: 'stretch-set-positions',
        name: 'Camel-cat stretch set',
        exercises: [
          SMKitExercise(
            detector: 'LumbarCamelCatSeated',
            prettyName: 'Seated Camel-Cat',
            totalSeconds: 60,
            uiElements: [SMKitUIElement.timer, SMKitUIElement.holdingPosition],
            stretchSetConfig: const SMKitStretchSetConfig(
              repetitions: 2,
              secondsPerStretch: 5,
              restSecondsBetweenStretches: 3,
              positionDetectors: ['LumbarCamelSeated', 'LumbarCatSeated'],
            ),
          ),
        ],
      ),
    ),
    FeatureExample(
      title: 'Section title with a custom sound',
      description:
          'High knees shown under a "Cardio" block. sectionTitleSoundKey '
          'plays a custom title sound (an asset key, URL or file path) '
          'before the exercise intro.',
      build: () => SMKitWorkout(
        id: 'section-title-sound',
        name: 'Section title sound',
        exercises: [
          SMKitExercise(
            detector: 'HighKnees',
            prettyName: 'High Knees',
            totalSeconds: 30,
            videoInstruction: 'HighKnees',
            uiElements: [SMKitUIElement.repsCounter, SMKitUIElement.timer],
            displayContext: const SMKitExerciseDisplayContext(
              sectionTitle: 'Cardio',
              group: SMKitExerciseDisplayGroup(
                id: 'cardio',
                kind: SMKitExerciseDisplayGroupKind.block,
                number: 1,
                title: 'Cardio',
              ),
              sectionTitleSoundKey: highKneesSoundUrl,
              playsTitleSound: true,
            ),
          ),
        ],
      ),
    ),
    FeatureExample(
      title: 'Instruction-rep timing and pace',
      description:
          'Squats whose instruction video is split into rep segments, with '
          'pace coaching on and position-exit vocals off. Results report '
          'paceLimitDetectedCount and paceLimitSpokenCount.',
      build: () => SMKitWorkout(
        id: 'instruction-reps',
        name: 'Instruction reps',
        exercises: [
          SMKitExercise(
            detector: 'SquatRegular',
            prettyName: 'Squats',
            totalSeconds: 45,
            targetReps: 10,
            videoInstruction: 'SquatRegular',
            uiElements: [SMKitUIElement.repsCounter, SMKitUIElement.timer],
            paceLimitEnabled: true,
            positionExitVocalsEnabled: false,
            instructionRepTiming: const SMKitInstructionRepTiming(
              videoName: 'SquatRegularInstructionVideo',
              segments: [
                SMKitInstructionRepSegment(0, 2.5),
                SMKitInstructionRepSegment(2.5, 5),
              ],
            ),
          ),
        ],
      ),
    ),
  ];
}

class FeatureExamplesScreen extends StatefulWidget {
  final SmkitUiFlutterPlugin plugin;
  final DemoSettings settings;
  final void Function(SMKitStatus) onHandle;

  const FeatureExamplesScreen({
    super.key,
    required this.plugin,
    required this.settings,
    required this.onHandle,
  });

  @override
  State<FeatureExamplesScreen> createState() => _FeatureExamplesScreenState();
}

class _FeatureExamplesScreenState extends State<FeatureExamplesScreen> {
  final Map<String, String> _prepareStatus = {};
  String? _busy;

  Future<void> _prepare(FeatureExample example) async {
    setState(() {
      _busy = example.title;
      _prepareStatus[example.title] = 'Preparing…';
    });
    try {
      // prepareWorkout includes continuation exercises and mode-specific media.
      final ready = await widget.plugin.prepareWorkout(example.build());
      _prepareStatus[example.title] = ready ? 'Assets ready' : 'Not ready';
      DemoEventLog.instance.add(
        'prepareWorkout(${example.title})',
        'returned $ready',
      );
    } catch (error) {
      _prepareStatus[example.title] = 'Failed: $error';
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _start(FeatureExample example) async {
    try {
      await widget.settings.applyTo(widget.plugin);
      await widget.plugin.startCustomizedWorkout(
        workout: example.build(),
        modifications: widget.settings.modifications,
        onHandle: widget.onHandle,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start ${example.title}: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feature Examples')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: FeatureExample.all.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final example = FeatureExample.all[index];
          final status = _prepareStatus[example.title];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    example.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(example.description),
                  if (status != null) ...[
                    const SizedBox(height: 8),
                    Text(status, style: Theme.of(context).textTheme.bodySmall),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: _busy == null
                            ? () => _prepare(example)
                            : null,
                        child: const Text('Prepare assets'),
                      ),
                      ElevatedButton(
                        onPressed: () => _start(example),
                        child: const Text('Start'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

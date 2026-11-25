import 'package:flutter_test/flutter_test.dart';
import 'package:smkit_ui_flutter_demo_app/FeatureExamplesScreen.dart';

Map<String, dynamic> _exercise(String title) {
  final example = FeatureExample.all.firstWhere((e) => e.title == title);
  final json = example.build().toJson();
  return (json['exercises'] as List).single as Map<String, dynamic>;
}

void main() {
  test('every example builds a one-exercise workout with an id', () {
    for (final example in FeatureExample.all) {
      final json = example.build().toJson();
      expect(json['id'], isNotEmpty, reason: example.title);
      expect(json['exercises'], hasLength(1), reason: example.title);
    }
  });

  test('mobility flow sends a hold block and a rep block', () {
    final exercise = _exercise('Mobility Flow');
    expect(exercise['detector'], 'MobilityFlow');
    final blocks = exercise['mobilityFlowConfig']['blocks'] as List;
    expect(blocks[0], containsPair('secondsPerRep', 10));
    expect(blocks[1]['mobilityRepConfig'], {'targetReps': 3});
  });

  test(
    'combination, quick motion and instruction timing reach the payload',
    () {
      expect(_exercise('Combination (Combo04)')['combinationOptions'], {
        'firstReps': 2,
        'secondReps': 1,
        'fixedSide': 'left',
      });
      expect(_exercise('Quick motion')['quickMotionParams'], isNotNull);
      final timed = _exercise('Instruction-rep timing and pace');
      expect(timed['paceLimitEnabled'], isTrue);
      expect(timed['positionExitVocalsEnabled'], isFalse);
      expect(timed['instructionRepTiming']['segments'], hasLength(2));
      expect(_exercise('Mobility reps')['mobilityRepConfig'], {
        'targetReps': 6,
      });
    },
  );

  test(
    'mobility flow cue, stretch positions and section sound reach the payload',
    () {
      final quiet = _exercise('Mobility Flow without the 5-second cue');
      expect(quiet['mobilityFlowConfig']['fiveSecondsLeftCueEnabled'], isFalse);
      final stretch = _exercise('Stretch set with alternating positions');
      expect(stretch['stretchSetConfig']['positionDetectors'], [
        'LumbarCamelSeated',
        'LumbarCatSeated',
      ]);
      expect(stretch['stretchSetConfig']['repetitions'], greaterThan(1));
      final titled = _exercise('Section title with a custom sound');
      expect(
        titled['displayContext']['sectionTitleSoundKey'],
        highKneesSoundUrl,
      );
      expect(titled['displayContext']['group']['kind'], 'block');
    },
  );
}

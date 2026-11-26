import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:smkit_ui_flutter_demo_app/demo_presets.dart';

void main() {
  test('showcase workout runs the six exercises in order', () {
    final exercises =
        DemoPresets.showcaseWorkout().toJson()['exercises'] as List;
    expect(exercises.map((e) => e['detector']), [
      'ArnoldShoulderPress',
      'JeffersonCurl',
      'Combo01',
      'TherapySquat',
      'PushupRegular',
      'StandingBowArrowThoracicMobilityRight',
    ]);
  });

  test('every showcase exercise has the demo options on', () {
    final exercises =
        DemoPresets.showcaseWorkout().toJson()['exercises'] as List;
    for (final e in exercises.cast<Map<String, dynamic>>()) {
      expect(e['adaptiveRomFeedbackEnabled'], isTrue, reason: e['detector']);
      expect(e['enableGuidanceModeSuggestion'], isTrue, reason: e['detector']);
      expect(e['playRepMilestoneVoice'], isTrue, reason: e['detector']);
      expect(e['repMilestoneInterval'], 5, reason: e['detector']);
      expect(e['playPreExerciseCountdown'], isTrue, reason: e['detector']);
    }
    expect(exercises[1]['guidanceMode'], isTrue);
    expect(exercises[2]['exerciseIntro'], 'ComboSequenceIntro');
    expect(exercises[4]['playSoundOnEachRep'], isTrue);
    expect(exercises[5]['mobilityRepConfig'], {'targetReps': 5});
  });

  test('mobility flow preset holds rhomboid, then thoracic left and right', () {
    final exercise =
        (DemoPresets.mobilityFlow().toJson()['exercises'] as List).single;
    expect(exercise['detector'], 'MobilityFlow');
    final blocks = exercise['mobilityFlowConfig']['blocks'] as List;
    expect(blocks.map((b) => b['detector']), [
      'RhomboidStretch',
      'SeatedThoracicSideBendingLeft',
      'SeatedThoracicSideBendingRight',
    ]);
    for (final b in blocks) {
      expect(b['repetitions'], 1);
      expect(b['secondsPerRep'], 10);
    }
  });

  test('rounds: side bend warm-up, then 2 rounds with 20/30/40 s rests', () {
    expect(DemoPresets.classicSetTargets(16), [13, 12]);
    expect(DemoPresets.classicSetTargets(14), [11, 11]);

    final json = DemoPresets.rounds(random: Random(1)).toJson();
    final exercises = (json['exercises'] as List).cast<Map<String, dynamic>>();
    expect(
      exercises.map(
        (e) => [
          e['detector'],
          e['totalSeconds'],
          e['targetReps'],
          (e['displayContext'] as Map?)?['sectionTitle'],
        ],
      ),
      [
        ['StandingSideBendRight', 20, null, 'Warm Up'],
        ['StandingSideBendLeft', 20, null, null],
        ['SquatRegular', 60, 13, 'Round 1'],
        ['Rest', 20, null, null],
        ['PushupRegular', 60, 11, null],
        ['Rest', 30, null, null],
        ['SquatRegular', 60, 12, 'Round 2'],
        ['Rest', 40, null, null],
        ['PushupRegular', 60, 11, null],
      ],
    );
    for (final e in exercises.where((e) => e['displayContext'] != null)) {
      expect(e['displayContext']['playsTitleSound'], isTrue);
      expect(e['displayContext'].containsKey('sectionTitleSoundKey'), isFalse);
    }
    for (final e in exercises.where((e) => e['detector'] != 'Rest')) {
      expect(e['playRepMilestoneVoice'], isTrue, reason: e['detector']);
      expect(e['repMilestoneInterval'], 5, reason: e['detector']);
    }
    for (final e in exercises.where((e) => e['detector'] == 'Rest')) {
      expect(DemoPresets.restIntros, contains(e['exerciseIntro']));
      expect(e['scoringParams']['type'], 'time');
    }
    for (final e in exercises.where((e) => e['targetReps'] != null)) {
      expect(e['scoringParams']['targetReps'], e['targetReps']);
      expect(e['targetRepsTimerDisplayMode'], 'timeProgress');
      expect(e['playTargetRepsCompletionVoice'], isTrue);
    }
  });

  test('rounds pick each rest intro at random', () {
    final seen = <String>{};
    for (var seed = 0; seed < 20; seed++) {
      final exercises =
          DemoPresets.rounds(random: Random(seed)).toJson()['exercises']
              as List;
      seen.addAll(
        exercises
            .where((e) => e['detector'] == 'Rest')
            .map((e) => e['exerciseIntro'] as String),
      );
    }
    expect(seen, DemoPresets.restIntros.toSet());
  });
}

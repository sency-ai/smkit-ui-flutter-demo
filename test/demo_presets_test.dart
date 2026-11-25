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
}

import 'package:flutter_test/flutter_test.dart';
import 'package:smkit_ui_flutter_demo_app/exercise_catalog.dart';

void main() {
  test('dynamic exercises are reps-based with the reps defaults', () {
    final entry = ExerciseCatalog.byDetector['HighKnees']!;

    expect(entry.assessmentModes, [AssessmentScoringMode.reps]);
    expect(entry.defaultDuration, ExerciseCatalog.defaultRepsDuration);
    expect(entry.defaultTargetReps, ExerciseCatalog.defaultTargetReps);
  });

  test('time-only exercises default to time scoring', () {
    final entry = ExerciseCatalog.byDetector['PlankHighStatic']!;

    expect(entry.assessmentModes, [AssessmentScoringMode.time]);
    expect(entry.defaultDuration, ExerciseCatalog.defaultStaticDuration);
    expect(entry.defaultTargetTime, ExerciseCatalog.defaultTargetTime);
  });

  test('ROM-enabled exercises include both platform-specific target values',
      () {
    final entry = ExerciseCatalog.byDetector['HipFlexionLeft']!;

    expect(
      entry.assessmentModes,
      [AssessmentScoringMode.rom, AssessmentScoringMode.time],
    );
    expect(entry.romTarget?.androidValue, 'HipFlexionMobilityRaiseLeg');
    expect(entry.romTarget?.iosValue, 'HipFlexionRaiseLeg');
  });
}

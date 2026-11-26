import 'dart:math';

import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';

import 'exercise_catalog.dart';

/// Ready-made workouts started straight from the home screen, for live demos.
class DemoPresets {
  DemoPresets._();

  /// One 10-second hold each: rhomboid stretch, then seated thoracic side
  /// bending to the left and to the right.
  static SMKitWorkout mobilityFlow() => SMKitWorkout(
    id: 'demo-mobility-flow',
    name: 'Mobility Flow',
    exercises: [
      SMKitExercise.mobilityFlow(
        const SMKitMobilityFlowConfig([
          SMKitMobilityFlowBlock.hold(
            'RhomboidStretch',
            repetitions: 1,
            secondsPerRep: 10,
          ),
          SMKitMobilityFlowBlock.hold(
            'SeatedThoracicSideBendingLeft',
            repetitions: 1,
            secondsPerRep: 10,
          ),
          SMKitMobilityFlowBlock.hold(
            'SeatedThoracicSideBendingRight',
            repetitions: 1,
            secondsPerRep: 10,
          ),
        ]),
      ),
    ],
  );

  /// Arnold shoulder press, Jefferson curl in guidance mode, Combo01,
  /// therapy squats, push-ups and 5 standing bow-and-arrow mobility reps.
  /// Every exercise has adaptive ROM feedback, the guidance-mode suggestion,
  /// a rep-count voice every 5 reps and the pre-exercise countdown; push-ups
  /// also play a sound on each rep.
  static SMKitWorkout showcaseWorkout() => SMKitWorkout(
    id: 'demo-showcase',
    name: 'Example workout',
    exercises: [
      _exercise(
        'ArnoldShoulderPress',
        'Arnold Shoulder Press',
        seconds: 40,
        uiElements: const [SMKitUIElement.timer, SMKitUIElement.repsCounter],
      ),
      _exercise(
        'JeffersonCurl',
        'Jefferson Curl',
        seconds: 45,
        guidanceMode: true,
      ),
      // Combo01: a squat, then standing bicycle crunches on each side,
      // with the SDK's default reps per movement.
      _exercise(
        'Combo01',
        'Combo01',
        seconds: 60,
        targetReps: 4,
        uiElements: const [SMKitUIElement.repsCounter, SMKitUIElement.timer],
        video: null,
        exerciseIntro: 'ComboSequenceIntro',
      ),
      // SMKitUI runs the side-view setup, raised-hands check and virtual wall
      // itself; these are its default UI elements for this detector.
      _exercise(
        'TherapySquat',
        'Therapy Squat',
        seconds: 45,
        uiElements: const [
          SMKitUIElement.timer,
          SMKitUIElement.repsCounter,
          SMKitUIElement.gaugeOfMotion,
        ],
      ),
      _exercise(
        'PushupRegular',
        'Push-ups',
        seconds: 40,
        playSoundOnEachRep: true,
      ),
      // A mobility movement counted as reps instead of a timed hold.
      _exercise(
        'StandingBowArrowThoracicMobilityRight',
        'Standing Bow and Arrow Right',
        seconds: 60,
        uiElements: const [SMKitUIElement.repsCounter, SMKitUIElement.timer],
        mobilityRepConfig: const SMKitMobilityRepConfig(targetReps: 5),
      ),
    ],
  );

  /// Jinni's classic-set work length, in seconds.
  static const roundSetSeconds = 60;

  /// Jinni's default stretch hold, used for each side bend in the warm-up.
  static const warmupHoldSeconds = 20;

  /// Every exercise in the rounds session speaks the rep count every 5 reps.
  static const repMilestoneInterval = 5;

  /// The rests after each work set, in order. None follows the last set.
  static const roundRestSeconds = [20, 30, 40];

  /// The two rest intros in the voice pack: "Rest." and "Rest. Take a moment
  /// to breathe and recover." Rests otherwise open with the same "Rest."
  /// every time; the SDK picks a random praise after the intro either way.
  static const restIntros = ['Restintro', 'RestGuidanceintro'];

  /// Jinni's classic-set targets from a medium-level reps-per-60 s rate:
  /// 80% for the first set and 75% for the second, rounded, never below 6.
  static List<int> classicSetTargets(double repsPer60) => [0.80, 0.75]
      .map((fraction) => (repsPer60 * fraction).round().clamp(6, 1 << 30))
      .toList();

  static const _roundExercises = [
    (detector: 'SquatRegular', name: 'Squats', repsPer60: 16.0),
    (detector: 'PushupRegular', name: 'Push-ups', repsPer60: 14.0),
  ];

  /// A warm-up of standing side bends, right then left, followed by two
  /// rounds of squats and push-ups. Each section starts with a title the SDK
  /// shows and speaks: Warm Up, Round 1 and Round 2. Rests of 20, 30 and
  /// 40 s follow the work sets, except the last, so the workout ends on it.
  /// Pass [random] to make the rest intros repeatable in tests.
  static SMKitWorkout rounds({Random? random}) {
    final pick = random ?? Random();
    final exercises = <SMKitExercise>[
      _warmupHold(
        'StandingSideBendRight',
        'Standing Side Bend Right',
        sectionTitle: 'Warm Up',
      ),
      _warmupHold('StandingSideBendLeft', 'Standing Side Bend Left'),
    ];
    final targets = [
      for (final exercise in _roundExercises)
        classicSetTargets(exercise.repsPer60),
    ];
    var rests = 0;
    for (var round = 0; round < 2; round++) {
      for (final (index, exercise) in _roundExercises.indexed) {
        exercises.add(
          _roundSet(
            exercise.detector,
            exercise.name,
            targets[index][round],
            sectionTitle: index == 0 ? 'Round ${round + 1}' : null,
          ),
        );
        if (rests < roundRestSeconds.length) {
          exercises.add(
            _rest(
              roundRestSeconds[rests++],
              intro: restIntros[pick.nextInt(restIntros.length)],
            ),
          );
        }
      }
    }
    return SMKitWorkout(
      id: 'demo-rounds',
      name: 'Rounds',
      workoutIntro: 'workoutIntro',
      workoutClosure: 'workoutClosure',
      exercises: exercises,
    );
  }

  static SMKitExerciseDisplayContext? _title(String? sectionTitle) =>
      sectionTitle == null
      ? null
      : SMKitExerciseDisplayContext(
          sectionTitle: sectionTitle,
          playsTitleSound: true,
        );

  /// A timed side bend, built like Jinni's warm-up stretches.
  static SMKitExercise _warmupHold(
    String detector,
    String name, {
    String? sectionTitle,
  }) {
    final entry = ExerciseCatalog.byDetector[detector];
    return SMKitExercise(
      detector: detector,
      prettyName: name,
      totalSeconds: warmupHoldSeconds,
      videoInstruction: entry?.videoInstruction ?? detector,
      uiElements:
          entry?.uiElements ??
          const [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion],
      scoringParams: ScoringParams(
        type: ScoringType.time,
        scoreFactor: 0.8,
        targetTime: warmupHoldSeconds,
      ),
      playPreExerciseCountdown: true,
      playRepMilestoneVoice: true,
      repMilestoneInterval: repMilestoneInterval,
      displayContext: _title(sectionTitle),
    );
  }

  /// One timed set with a target, the way Jinni sets it: the timer stays
  /// time-based and the SDK speaks when the target is reached.
  static SMKitExercise _roundSet(
    String detector,
    String name,
    int targetReps, {
    String? sectionTitle,
  }) => SMKitExercise(
    detector: detector,
    prettyName: name,
    totalSeconds: roundSetSeconds,
    videoInstruction:
        ExerciseCatalog.byDetector[detector]?.videoInstruction ?? detector,
    uiElements: const [SMKitUIElement.timer, SMKitUIElement.repsCounter],
    scoringParams: ScoringParams(
      type: ScoringType.reps,
      scoreFactor: 0.8,
      targetReps: targetReps,
    ),
    targetReps: targetReps,
    targetRepsTimerDisplayMode: 'timeProgress',
    showTargetProgress: false,
    playTargetRepsCompletionVoice: true,
    playPreExerciseCountdown: true,
    playRepMilestoneVoice: true,
    repMilestoneInterval: repMilestoneInterval,
    displayContext: _title(sectionTitle),
  );

  /// A rest station, built like Jinni's rest template, with a chosen intro.
  static SMKitExercise _rest(int seconds, {required String intro}) =>
      SMKitExercise(
        detector: 'Rest',
        prettyName: 'Rest',
        totalSeconds: seconds,
        videoInstruction: null,
        exerciseIntro: intro,
        uiElements: const [SMKitUIElement.timer],
        scoringParams: ScoringParams(type: ScoringType.time, scoreFactor: 0),
      );

  static const _useCatalogVideo = '';

  static SMKitExercise _exercise(
    String detector,
    String name, {
    required int seconds,
    int? targetReps,
    bool guidanceMode = false,
    bool playSoundOnEachRep = false,
    List<SMKitUIElement>? uiElements,
    String? video = _useCatalogVideo,
    String? exerciseIntro,
    SMKitCombinationOptions? combinationOptions,
    SMKitMobilityRepConfig? mobilityRepConfig,
  }) {
    final entry = ExerciseCatalog.byDetector[detector];
    return SMKitExercise(
      detector: detector,
      prettyName: name,
      totalSeconds: seconds,
      targetReps: targetReps,
      videoInstruction: video == _useCatalogVideo
          ? (entry?.videoInstruction ?? detector)
          : video,
      exerciseIntro: exerciseIntro,
      uiElements:
          uiElements ??
          entry?.uiElements ??
          const [SMKitUIElement.repsCounter, SMKitUIElement.timer],
      guidanceMode: guidanceMode,
      enableGuidanceModeSuggestion: true,
      adaptiveRomFeedbackEnabled: true,
      playRepMilestoneVoice: true,
      repMilestoneInterval: 5,
      playPreExerciseCountdown: true,
      playSoundOnEachRep: playSoundOnEachRep,
      combinationOptions: combinationOptions,
      mobilityRepConfig: mobilityRepConfig,
    );
  }
}

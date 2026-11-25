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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';

import 'live_controls.dart';

enum DemoInstructionVideoMode { defaultMode, mediumCycle }

enum DemoEndExercisePreference { timer, targetBased }

enum DemoCounterPreference { defaultBased, perfectOnly }

class DemoSettings {
  bool configureHighlightsOnNextLaunch = false;

  // Read by configure, so they apply on the next launch or Reconfigure SDK.
  /// Android only; iOS accepts it and ignores it.
  SmKitPoseModelChoice poseModelChoice = SmKitPoseModelChoice.adaptiveChoice;

  /// iOS only: Android rejects non-default values.
  SMKitModelDownloadPolicy modelDownloadPolicy =
      SMKitModelDownloadPolicy.waitForRemoteModelsThenFallback;

  /// iOS only: drives configure's includesObjectDetectionFeedbacks and
  /// SMKitConfig.enableObjectDetectionFeedbacks together.
  bool objectDetectionFeedbacks = false;
  bool showPhoneCalibration = true;
  bool enableWorkoutContinuation = false;
  bool showDebugBoundingBox = false;

  SMKitColorTheme colorTheme = SMKitColorTheme.green;
  bool skeletonHidden = false;
  SkeletonPreset skeletonPreset = SkeletonPreset.defaultPreset;
  SkeletonConnectionStyle skeletonConnectionStyle =
      SkeletonConnectionStyle.solid;
  SkeletonJointShape skeletonJointShape = SkeletonJointShape.circle;
  double skeletonDotsOpacity = 1;
  double skeletonConnectionsOpacity = 1;
  SkeletonColorOption? skeletonDotsInnerColor;
  SkeletonColorOption? skeletonDotsOuterColor;
  SkeletonColorOption? skeletonConnectionsInnerColor;
  SkeletonColorOption? skeletonConnectionsOuterColor;
  double skeletonDotsGlow = 0;
  double skeletonConnectionsGlow = 0;
  double skeletonLineWidthScale = 1;
  double skeletonOutlineScale = 1;
  double skeletonSoftness = 0;
  double skeletonAnimationDuration = 0;

  bool allowAudioMixing = true;
  bool showExternalAudioControl = true;
  bool playPhoneCalibrationAudio = false;
  bool playBodyCalibrationAudio = false;
  String buttonTutorialCompletionAudioPath = '';
  SMKitLanguage sessionLanguage = SMKitLanguage.english;
  SMKitLanguage phoneCalibrationLanguage = SMKitLanguage.english;

  bool accuratePoseEstimation = true;
  bool enableIntelligenceRest = false;
  bool enableWatchCompanion = false;
  bool enableHeartRateRest = false;
  int heartRateRestThreshold = 160;
  bool startTimerOnFirstActivity = true;
  bool enablePhoneMovementCountPrevention = false;
  bool enableVariationMismatchFeedback = false;
  bool enableButtonTutorial = false;
  int workoutContinuationTimerDuration = 10;
  DemoEndExercisePreference endExercisePreference =
      DemoEndExercisePreference.timer;
  DemoCounterPreference counterPreference = DemoCounterPreference.defaultBased;

  DemoInstructionVideoMode instructionVideoMode =
      DemoInstructionVideoMode.defaultMode;
  int instructionMediumCycles = 2;

  bool useDefaultGuidanceMode = false;
  bool guidanceModeSuggestion = false;
  bool enableSmallBodyPartFocus = false;
  bool guidanceDebugLogging = false;
  bool exerciseSummaryTimingMetrics = false;
  bool includeAssessmentInsights = false;
  SMKitFeedbackFrequency feedbackFrequency = SMKitFeedbackFrequency.normal;
  SMKitVoice voiceFeedbackVoice = SMKitVoice.male1;
  bool automaticallyPreloadModels = true;
  bool enableDiagnostics = false;
  bool exportAssessmentInsights = false;
  bool excludePushupKneesFeedback = true;
  bool exerciseProgressDisplay = false;
  bool playTargetRepsCompletionVoice = false;
  bool intentVoiceFeedbackEnabled = false;
  String androidConfigString = '';

  // Mobility flow and holds.
  SMKitVoice mobilityFlowVoice = SMKitVoice.female1;
  MobilityFlowHoldIndicatorStyle mobilityFlowHoldIndicatorStyle =
      MobilityFlowHoldIndicatorStyle.classic;
  bool holdPositionSoundEnabled = false;
  bool positionExitVocalsEnabled = true;

  // iOS only: Android rejects setConfig when these keys are present.
  bool enablePerExerciseBodyCalibration = false;
  bool showAllSkeletonKeypoints = false;
  bool showRowingPhoneCalibration = false;
  bool enableBodyCalibrationObjectDetection = false;

  /// iOS only: comma-separated object classes body calibration must see.
  String bodyCalibrationRequiredObjectClasses = '';

  /// iOS only: comma-separated feedback names the SDK should not detect.
  String excludedFeedbacks = '';

  LiveControlAction liveControlAction = LiveControlAction.none;
  int liveControlDelaySeconds = 8;

  List<SMKitPauseType> allowedPauseTypes = [
    SMKitPauseType.quit,
    SMKitPauseType.skip,
    SMKitPauseType.startOver,
    SMKitPauseType.resume,
  ];

  static const colorThemeOptions = SMKitColorTheme.values;
  static const skeletonPresetOptions = SkeletonPreset.values;
  static const skeletonConnectionOptions = SkeletonConnectionStyle.values;
  static const skeletonJointOptions = SkeletonJointShape.values;
  static const skeletonColorOptions = SkeletonColorOption.values;
  static const feedbackFrequencyOptions = SMKitFeedbackFrequency.values;
  static const voiceOptions = SMKitVoice.values;

  Map<String, dynamic> get modifications => {
    'primaryColor': colorTheme.hexColor,
    'phoneCalibration': {'enabled': showPhoneCalibration},
    'showProgressBar': true,
    'showCounters': true,
  };

  SkeletonConfig get skeletonConfig => SkeletonConfig(
    hidden: skeletonHidden,
    preset: skeletonPreset,
    connectionStyle: skeletonConnectionStyle,
    jointShape: skeletonJointShape,
    dotsOpacity: skeletonDotsOpacity,
    connectionsOpacity: skeletonConnectionsOpacity,
    dotsInnerColor: skeletonDotsInnerColor,
    dotsOuterColor: skeletonDotsOuterColor,
    connectionsInnerColor: skeletonConnectionsInnerColor,
    connectionsOuterColor: skeletonConnectionsOuterColor,
    dotsGlow: skeletonDotsGlow,
    connectionsGlow: skeletonConnectionsGlow,
    lineWidthScale: skeletonLineWidthScale,
    outlineScale: skeletonOutlineScale,
    softness: skeletonSoftness,
    animationDuration: skeletonAnimationDuration,
  );

  SMKitConfig get smkitConfig => SMKitConfig(
    enableIntelligenceRest: enableIntelligenceRest,
    enableHeartRateRest: enableHeartRateRest,
    heartRateRestThreshold: heartRateRestThreshold,
    allowAudioMixing: allowAudioMixing,
    showExternalAudioControl: showExternalAudioControl,
    playPhoneCalibrationAudio: playPhoneCalibrationAudio,
    playBodyCalibrationAudio: playBodyCalibrationAudio,
    enableButtonTutorial: enableButtonTutorial,
    buttonTutorialCompletionAudioPath:
        buttonTutorialCompletionAudioPath.trim().isEmpty
        ? null
        : buttonTutorialCompletionAudioPath.trim(),
    enableWatchCompanion: enableWatchCompanion,
    accuratePoseEstimation: accuratePoseEstimation,
    enablePhoneMovementCountPrevention: enablePhoneMovementCountPrevention,
    enableVariationMismatchFeedback: enableVariationMismatchFeedback,
    startTimerOnFirstActivity: startTimerOnFirstActivity,
    workoutContinuationTimerDuration: workoutContinuationTimerDuration,
    skeletonConfig: skeletonConfig,
    colorTheme: colorTheme,
    pauseTypes: allowedPauseTypes,
    instructionVideoConfig: InstructionVideoConfig(
      displayMode: instructionVideoMode == DemoInstructionVideoMode.mediumCycle
          ? InstructionVideoDisplayMode.mediumCycle
          : InstructionVideoDisplayMode.defaultMode,
      mediumSizeCycles: instructionMediumCycles,
    ),
    useDefaultGuidanceMode: useDefaultGuidanceMode,
    guidanceModeSuggestion: guidanceModeSuggestion,
    feedbackFrequency: feedbackFrequency,
    voiceFeedbackVoice: voiceFeedbackVoice,
    automaticallyPreloadModels: automaticallyPreloadModels,
    enableDiagnostics: enableDiagnostics,
    enableSmallBodyPartFocus: enableSmallBodyPartFocus,
    guidanceDebugLogging: guidanceDebugLogging,
    androidConfigString: androidConfigString.trim().isEmpty
        ? null
        : androidConfigString,
    exerciseSummaryTimingMetrics: exerciseSummaryTimingMetrics,
    includeAssessmentInsights: includeAssessmentInsights,
    showDebugBoundingBox: showDebugBoundingBox,
    mobilityFlowVoice: mobilityFlowVoice,
    mobilityFlowHoldIndicatorStyle: mobilityFlowHoldIndicatorStyle,
    holdPositionSoundEnabled: holdPositionSoundEnabled,
    positionExitVocalsEnabled: positionExitVocalsEnabled,
    enablePerExerciseBodyCalibration: Platform.isIOS
        ? enablePerExerciseBodyCalibration
        : null,
    showAllSkeletonKeypoints: Platform.isIOS ? showAllSkeletonKeypoints : null,
    showRowingPhoneCalibration: Platform.isIOS
        ? showRowingPhoneCalibration
        : null,
    enableBodyCalibrationObjectDetection: Platform.isIOS
        ? enableBodyCalibrationObjectDetection
        : null,
    bodyCalibrationRequiredObjectClasses: Platform.isIOS
        ? _commaList(bodyCalibrationRequiredObjectClasses)
        : null,
    enableObjectDetectionFeedbacks: Platform.isIOS
        ? objectDetectionFeedbacks
        : null,
  );

  static List<String> _commaList(String value) => value
      .split(',')
      .map((name) => name.trim())
      .where((name) => name.isNotEmpty)
      .toList();

  List<String> get excludedFeedbackList => _commaList(excludedFeedbacks);

  Future<void> applyTo(SmkitUiFlutterPlugin plugin) async {
    await plugin.setConfig(config: smkitConfig);
    await plugin.setFeedbacksUiToExclude(
      feedbacks: excludePushupKneesFeedback
          ? const ['PushupKneesOnFloor']
          : const [],
    );
    if (Platform.isIOS) {
      await plugin.setExcludedFeedbacks(feedbacks: excludedFeedbackList);
    }
    await plugin.setSessionLanguage(language: sessionLanguage);
    await plugin.setPhoneCalibrationLanguage(
      language: phoneCalibrationLanguage,
    );
    await plugin.setEndExercisePreferences(
      endExercisePrefernces:
          endExercisePreference == DemoEndExercisePreference.targetBased
          ? SMKitEndExercisePreferences.targetBased
          : SMKitEndExercisePreferences.defaultBased,
    );
    await plugin.setCounterPreferences(
      counterPreferences: counterPreference == DemoCounterPreference.perfectOnly
          ? SMKitCounterPreferences.perfectOnly
          : SMKitCounterPreferences.all,
    );
  }
}

extension DemoDisplayNames on Object {
  String get displayName {
    final self = this;
    if (self is LiveControlAction) return self.label;
    final name = switch (this) {
      SMKitColorTheme value => value.name,
      SkeletonPreset value => value.name,
      SkeletonConnectionStyle value => value.name,
      SkeletonJointShape value => value.name,
      SkeletonColorOption value => value.name,
      SMKitLanguage value => value.name,
      DemoInstructionVideoMode value =>
        value == DemoInstructionVideoMode.mediumCycle
            ? 'medium cycle'
            : 'default',
      DemoEndExercisePreference value =>
        value == DemoEndExercisePreference.targetBased
            ? 'target based'
            : 'timer',
      DemoCounterPreference value =>
        value == DemoCounterPreference.perfectOnly ? 'perfect only' : 'default',
      SMKitPauseType value => value.name,
      SMKitFeedbackFrequency value => value.name,
      SMKitVoice value => value == SMKitVoice.male1 ? 'Male 1' : 'Female 1',
      MobilityFlowHoldIndicatorStyle value => value.name,
      SmKitPoseModelChoice value => value.name,
      SMKitModelDownloadPolicy value => value.name,
      SMKitRowingFeedbackLevel value => value.name,
      _ => toString(),
    };
    return name
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (m) => '${m[1]} ${m[2]}',
        )
        .split(RegExp(r'[_\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}

extension DemoColorTheme on SMKitColorTheme {
  String get hexColor => switch (this) {
    SMKitColorTheme.blue => '#2196F3',
    SMKitColorTheme.green => '#4CAF50',
    SMKitColorTheme.purple => '#9C27B0',
    SMKitColorTheme.orange => '#FF9800',
    SMKitColorTheme.silver => '#C0C0C0',
    SMKitColorTheme.gold => '#FFD700',
    SMKitColorTheme.pink => '#FF69B4',
  };

  Color get materialColor =>
      Color(int.parse(hexColor.substring(1), radix: 16) | 0xFF000000);
}

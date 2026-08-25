import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';

import 'demo_settings.dart';

class UISettingsScreen extends StatefulWidget {
  final SmkitUiFlutterPlugin plugin;
  final DemoSettings settings;

  const UISettingsScreen({
    super.key,
    required this.plugin,
    required this.settings,
  });

  @override
  State<UISettingsScreen> createState() => _UISettingsScreenState();
}

class _UISettingsScreenState extends State<UISettingsScreen> {
  DemoSettings get settings => widget.settings;

  void _changed(VoidCallback update, {bool apply = true}) {
    setState(update);
    if (apply) {
      unawaited(settings.applyTo(widget.plugin));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Settings'),
        actions: [
          TextButton(
            onPressed: () {
              unawaited(settings.applyTo(widget.plugin));
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('Demo'),
            _switchTile(
              'Show phone calibration',
              settings.showPhoneCalibration,
              (value) => _changed(() => settings.showPhoneCalibration = value),
            ),
            _switchTile(
              'Enable workout continuation',
              settings.enableWorkoutContinuation,
              (value) =>
                  _changed(() => settings.enableWorkoutContinuation = value),
            ),
            _switchTile(
              'Configure highlights on next launch',
              settings.configureHighlightsOnNextLaunch,
              (value) => _changed(
                () => settings.configureHighlightsOnNextLaunch = value,
                apply: false,
              ),
            ),
            _switchTile(
              'Debug bounding box',
              settings.showDebugBoundingBox,
              (value) => _changed(() => settings.showDebugBoundingBox = value),
            ),
            _section('Appearance'),
            _dropdownTile<SMKitColorTheme>(
              'Color theme',
              settings.colorTheme,
              DemoSettings.colorThemeOptions,
              (value) => _changed(() => settings.colorTheme = value),
            ),
            _switchTile(
              'Hide skeleton',
              settings.skeletonHidden,
              (value) => _changed(() => settings.skeletonHidden = value),
            ),
            _dropdownTile<SkeletonPreset>(
              'Skeleton preset',
              settings.skeletonPreset,
              DemoSettings.skeletonPresetOptions,
              (value) => _changed(() => settings.skeletonPreset = value),
            ),
            _dropdownTile<SkeletonConnectionStyle>(
              'Connection style',
              settings.skeletonConnectionStyle,
              DemoSettings.skeletonConnectionOptions,
              (value) =>
                  _changed(() => settings.skeletonConnectionStyle = value),
            ),
            _dropdownTile<SkeletonJointShape>(
              'Joint shape',
              settings.skeletonJointShape,
              DemoSettings.skeletonJointOptions,
              (value) => _changed(() => settings.skeletonJointShape = value),
            ),
            _sliderTile(
              'Dots opacity',
              settings.skeletonDotsOpacity,
              0,
              1,
              (value) => _changed(() => settings.skeletonDotsOpacity = value),
            ),
            _sliderTile(
              'Connections opacity',
              settings.skeletonConnectionsOpacity,
              0,
              1,
              (value) =>
                  _changed(() => settings.skeletonConnectionsOpacity = value),
            ),
            _optionalColorTile(
              'Dots inner color',
              settings.skeletonDotsInnerColor,
              (value) =>
                  _changed(() => settings.skeletonDotsInnerColor = value),
            ),
            _optionalColorTile(
              'Dots outer color',
              settings.skeletonDotsOuterColor,
              (value) =>
                  _changed(() => settings.skeletonDotsOuterColor = value),
            ),
            _optionalColorTile(
              'Connections inner color',
              settings.skeletonConnectionsInnerColor,
              (value) => _changed(
                () => settings.skeletonConnectionsInnerColor = value,
              ),
            ),
            _optionalColorTile(
              'Connections outer color',
              settings.skeletonConnectionsOuterColor,
              (value) => _changed(
                () => settings.skeletonConnectionsOuterColor = value,
              ),
            ),
            _sliderTile(
              'Dots glow',
              settings.skeletonDotsGlow,
              0,
              1,
              (value) => _changed(() => settings.skeletonDotsGlow = value),
            ),
            _sliderTile(
              'Connections glow',
              settings.skeletonConnectionsGlow,
              0,
              1,
              (value) =>
                  _changed(() => settings.skeletonConnectionsGlow = value),
            ),
            _sliderTile(
              'Line width scale',
              settings.skeletonLineWidthScale,
              0.5,
              2,
              (value) =>
                  _changed(() => settings.skeletonLineWidthScale = value),
            ),
            _sliderTile(
              'Outline scale',
              settings.skeletonOutlineScale,
              0.5,
              2,
              (value) => _changed(() => settings.skeletonOutlineScale = value),
            ),
            _sliderTile(
              'Softness',
              settings.skeletonSoftness,
              0,
              1,
              (value) => _changed(() => settings.skeletonSoftness = value),
            ),
            _sliderTile(
              'Animation duration',
              settings.skeletonAnimationDuration,
              0,
              0.05,
              (value) =>
                  _changed(() => settings.skeletonAnimationDuration = value),
              precision: 3,
            ),
            _section('Audio and Calibration'),
            _switchTile(
              'Allow audio mixing',
              settings.allowAudioMixing,
              (value) => _changed(() => settings.allowAudioMixing = value),
            ),
            _switchTile(
              'Show external audio control',
              settings.showExternalAudioControl,
              (value) =>
                  _changed(() => settings.showExternalAudioControl = value),
            ),
            _switchTile(
              'Phone calibration audio',
              settings.playPhoneCalibrationAudio,
              (value) =>
                  _changed(() => settings.playPhoneCalibrationAudio = value),
            ),
            _switchTile(
              'Body calibration audio',
              settings.playBodyCalibrationAudio,
              (value) =>
                  _changed(() => settings.playBodyCalibrationAudio = value),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Button tutorial completion audio path',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text: settings.buttonTutorialCompletionAudioPath,
              ),
              onSubmitted: (value) => _changed(
                () => settings.buttonTutorialCompletionAudioPath = value,
              ),
            ),
            _dropdownTile<SMKitLanguage>(
              'Session language',
              settings.sessionLanguage,
              SMKitLanguage.values,
              (value) => _changed(() => settings.sessionLanguage = value),
            ),
            _dropdownTile<SMKitLanguage>(
              'Phone calibration language',
              settings.phoneCalibrationLanguage,
              SMKitLanguage.values,
              (value) =>
                  _changed(() => settings.phoneCalibrationLanguage = value),
            ),
            _section('Session Behavior'),
            _switchTile(
              'Accurate pose estimation',
              settings.accuratePoseEstimation,
              (value) =>
                  _changed(() => settings.accuratePoseEstimation = value),
            ),
            _switchTile(
              'Intelligence rest',
              settings.enableIntelligenceRest,
              (value) =>
                  _changed(() => settings.enableIntelligenceRest = value),
            ),
            _switchTile(
              'Watch companion',
              settings.enableWatchCompanion,
              (value) => _changed(() => settings.enableWatchCompanion = value),
            ),
            _switchTile(
              'Heart-rate rest',
              settings.enableHeartRateRest,
              (value) => _changed(() => settings.enableHeartRateRest = value),
            ),
            _stepperTile(
              'Heart-rate rest threshold',
              settings.heartRateRestThreshold,
              80,
              220,
              5,
              'bpm',
              (value) =>
                  _changed(() => settings.heartRateRestThreshold = value),
            ),
            _switchTile(
              'Timer starts on first activity',
              settings.startTimerOnFirstActivity,
              (value) =>
                  _changed(() => settings.startTimerOnFirstActivity = value),
            ),
            _switchTile(
              'Prevent count while phone moves',
              settings.enablePhoneMovementCountPrevention,
              (value) => _changed(
                () => settings.enablePhoneMovementCountPrevention = value,
              ),
            ),
            _switchTile(
              'Variation mismatch feedback',
              settings.enableVariationMismatchFeedback,
              (value) => _changed(
                () => settings.enableVariationMismatchFeedback = value,
              ),
            ),
            _switchTile(
              'Button hover tutorial',
              settings.enableButtonTutorial,
              (value) => _changed(() => settings.enableButtonTutorial = value),
            ),
            _switchTile(
              'Export exercise timing metrics (reconfigure)',
              settings.exerciseSummaryTimingMetrics,
              (value) =>
                  _changed(() => settings.exerciseSummaryTimingMetrics = value),
            ),
            _switchTile(
              'Download assessment insights (reconfigure)',
              settings.includeAssessmentInsights,
              (value) =>
                  _changed(() => settings.includeAssessmentInsights = value),
            ),
            _switchTile(
              'Export assessment insights',
              settings.exportAssessmentInsights,
              (value) =>
                  _changed(() => settings.exportAssessmentInsights = value),
            ),
            _stepperTile(
              'Continuation timer',
              settings.workoutContinuationTimerDuration,
              1,
              60,
              1,
              's',
              (value) => _changed(
                () => settings.workoutContinuationTimerDuration = value,
              ),
            ),
            _dropdownTile<DemoEndExercisePreference>(
              'End exercise',
              settings.endExercisePreference,
              DemoEndExercisePreference.values,
              (value) => _changed(() => settings.endExercisePreference = value),
            ),
            _dropdownTile<DemoCounterPreference>(
              'Counter preference',
              settings.counterPreference,
              DemoCounterPreference.values,
              (value) => _changed(() => settings.counterPreference = value),
            ),
            _section('Instruction Video'),
            _dropdownTile<DemoInstructionVideoMode>(
              'Display mode',
              settings.instructionVideoMode,
              DemoInstructionVideoMode.values,
              (value) => _changed(() => settings.instructionVideoMode = value),
            ),
            _stepperTile(
              'Medium cycles',
              settings.instructionMediumCycles,
              1,
              5,
              1,
              '',
              (value) =>
                  _changed(() => settings.instructionMediumCycles = value),
            ),
            _section('Android Guidance'),
            _switchTile(
              'Use default guidance mode',
              settings.useDefaultGuidanceMode,
              (value) =>
                  _changed(() => settings.useDefaultGuidanceMode = value),
            ),
            _switchTile(
              'Guidance suggestions',
              settings.guidanceModeSuggestion,
              (value) =>
                  _changed(() => settings.guidanceModeSuggestion = value),
            ),
            _switchTile(
              'Instruction-video body-part focus',
              settings.enableSmallBodyPartFocus,
              (value) =>
                  _changed(() => settings.enableSmallBodyPartFocus = value),
            ),
            _switchTile(
              'Guidance debug logging',
              settings.guidanceDebugLogging,
              (value) => _changed(() => settings.guidanceDebugLogging = value),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Android config string',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text: settings.androidConfigString,
              ),
              onSubmitted: (value) =>
                  _changed(() => settings.androidConfigString = value),
            ),
            _switchTile(
              'Hide pushup knees-on-floor feedback',
              settings.excludePushupKneesFeedback,
              (value) =>
                  _changed(() => settings.excludePushupKneesFeedback = value),
            ),
            _switchTile(
              'Section and circuit progress display',
              settings.exerciseProgressDisplay,
              (value) =>
                  _changed(() => settings.exerciseProgressDisplay = value),
            ),
            _switchTile(
              'Default target-reps completion voice',
              settings.playTargetRepsCompletionVoice,
              (value) => _changed(
                () => settings.playTargetRepsCompletionVoice = value,
              ),
            ),
            _switchTile(
              'Default exercise intent voice feedback',
              settings.intentVoiceFeedbackEnabled,
              (value) =>
                  _changed(() => settings.intentVoiceFeedbackEnabled = value),
            ),
            _section('Pause Buttons'),
            ...SMKitPauseType.values.map(
              (type) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(type.displayName),
                value: settings.allowedPauseTypes.contains(type),
                onChanged: (checked) {
                  _changed(() {
                    if (checked == true) {
                      if (!settings.allowedPauseTypes.contains(type)) {
                        settings.allowedPauseTypes.add(type);
                      }
                    } else {
                      settings.allowedPauseTypes.remove(type);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _dropdownTile<T>(
    String title,
    T value,
    List<T> values,
    ValueChanged<T> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: DropdownButton<T>(
        value: value,
        items: values
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text((item as Object).displayName),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }

  Widget _optionalColorTile(
    String title,
    SkeletonColorOption? value,
    ValueChanged<SkeletonColorOption?> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: DropdownButton<SkeletonColorOption?>(
        value: value,
        items: [
          const DropdownMenuItem<SkeletonColorOption?>(
            value: null,
            child: Text('Preset'),
          ),
          ...DemoSettings.skeletonColorOptions.map(
            (item) => DropdownMenuItem<SkeletonColorOption?>(
              value: item,
              child: Text(item.displayName),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _sliderTile(
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    int precision = 2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title)),
            Text(value.toStringAsFixed(precision)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _stepperTile(
    String title,
    int value,
    int min,
    int max,
    int step,
    String suffix,
    ValueChanged<int> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value <= min
                ? null
                : () => onChanged((value - step).clamp(min, max)),
          ),
          SizedBox(
            width: 72,
            child: Text(
              suffix.isEmpty ? '$value' : '$value $suffix',
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: value >= max
                ? null
                : () => onChanged((value + step).clamp(min, max)),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter_smkit_ui/models/sm_workout.dart';

enum ExerciseTypeFilter { all, dynamic_, static_, mobility, bodyAssessment }

enum AssessmentScoringMode { reps, time, rom }

class ExerciseRomTarget {
  final String androidValue;
  final String iosValue;

  const ExerciseRomTarget({
    required this.androidValue,
    required this.iosValue,
  });

  String forCurrentPlatform() => Platform.isIOS ? iosValue : androidValue;
}

class ExerciseCatalogEntry {
  final String detector;
  final ExerciseTypeFilter type;
  final List<SMKitUIElement> uiElements;
  final List<AssessmentScoringMode> assessmentModes;
  final int defaultDuration;
  final int defaultTargetReps;
  final int defaultTargetTime;
  final ExerciseRomTarget? romTarget;

  const ExerciseCatalogEntry({
    required this.detector,
    required this.type,
    required this.uiElements,
    required this.assessmentModes,
    required this.defaultDuration,
    required this.defaultTargetReps,
    required this.defaultTargetTime,
    required this.romTarget,
  });

  bool get supportsReps => assessmentModes.contains(AssessmentScoringMode.reps);

  bool get supportsTime => assessmentModes.contains(AssessmentScoringMode.time);

  bool get supportsRom => assessmentModes.contains(AssessmentScoringMode.rom);

  AssessmentScoringMode get defaultAssessmentMode => assessmentModes.first;

  String get videoInstruction => '${detector}InstructionVideo';

  String? get currentPlatformRomTarget => romTarget?.forCurrentPlatform();
}

class _ExerciseUiData {
  final ExerciseTypeFilter type;
  final List<SMKitUIElement> uiElements;

  const _ExerciseUiData(this.type, this.uiElements);
}

String exerciseFilterLabel(ExerciseTypeFilter filter) => switch (filter) {
      ExerciseTypeFilter.all => 'All',
      ExerciseTypeFilter.dynamic_ => 'Dynamic',
      ExerciseTypeFilter.static_ => 'Static',
      ExerciseTypeFilter.mobility => 'Mobility',
      ExerciseTypeFilter.bodyAssessment => 'Mobility',
    };

String assessmentScoringModeLabel(AssessmentScoringMode mode) => switch (mode) {
      AssessmentScoringMode.reps => 'Reps',
      AssessmentScoringMode.time => 'Time',
      AssessmentScoringMode.rom => 'ROM',
    };

class ExerciseCatalog {
  static const int defaultRepsDuration = 30;
  static const int defaultStaticDuration = 10;
  static const int defaultTargetReps = 5;
  static const int defaultTargetTime = 10;

  static const Map<String, _ExerciseUiData> _exerciseUiData = {
    'AirJumpRope': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'AlternateWindmillToeTouch': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'BackSuperman': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'BackSupermanHold': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'BirdDog': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'Burpees': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'ButtKicks': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'CalfRaises': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'ClamshellsLeft': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'ClamshellsRight': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'Crunches': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'Froggers': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'GlutesBridge': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'HandGrip': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'HighKnees': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'JumpingJacks': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'Jumps': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'LateralHandRaise': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'LateralHandRaiseLeft': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'LateralHandRaiseRight': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'LateralRaises': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'LungeFront': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'LungeFrontAlternate': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'LungeFrontLeft': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'LungeFrontRight': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'LungeJumps': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'LungeRegularStatic': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'LungeSide': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'LungeSideLeft': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'LungeSideRight': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'PlankCommando': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'PlankHighShoulderTaps': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'PlankHighToeTaps': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'PlankJacksHigh': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'PlankLowHipTwist': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'PlankWalkouts': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'PushupKnees': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'PushupRegular': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'PushupWide': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'QuadThoraticRotation': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'QuadThoraticRotationLeft': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'QuadThoraticRotationRight': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'ReverseSitToTableTop': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'SeatedShadowBoxing': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'ShouldersPress': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'SideLunge': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'SideStepJacks': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'SingleHandOverheadHealDigs': _ExerciseUiData(
      ExerciseTypeFilter.dynamic_,
      [
        SMKitUIElement.timer,
        SMKitUIElement.repsCounter,
      ],
    ),
    'SitToStand': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'SitupPenguin': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'SitupRussianTwist': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'SkaterHops': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'SkiJumps': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'Skydivers': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'SkydiversHold': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'SquatAndKick': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'SquatAndRotationJab': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'SquatAndStep': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'SquatNarrow': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'SquatRegular': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'SquatRegularOverhead': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'SquatSumo': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'StandingAlternateToeTouch': _ExerciseUiData(
      ExerciseTypeFilter.dynamic_,
      [
        SMKitUIElement.timer,
        SMKitUIElement.repsCounter,
      ],
    ),
    'StandingBicycleCrunches': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'StandingObliqueCrunches': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'ToesRaises': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
      SMKitUIElement.repsCounter,
    ]),
    'FastMarchRun': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
    ]),
    'PogoJumps': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
    ]),
    'PowerWalkInPlace': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
    ]),
    'QuickFeet': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
    ]),
    'ShoulderCircles': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
    ]),
    'SquatPulsing': _ExerciseUiData(ExerciseTypeFilter.dynamic_, [
      SMKitUIElement.timer,
    ]),
    'AnkleMobilityLeft': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'AnkleMobilityRight': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'HamstringMobility': _ExerciseUiData(ExerciseTypeFilter.bodyAssessment, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'HipExternalRotationLeft': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'HipExternalRotationRight': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'HipFlexionLeft': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'HipFlexionRight': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'HipInternalRotationLeft': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'HipInternalRotationRight': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'InnerThighMobility': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'JeffersonCurl': _ExerciseUiData(ExerciseTypeFilter.bodyAssessment, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'LungeSideStaticLeft': _ExerciseUiData(
      ExerciseTypeFilter.bodyAssessment,
      [
        SMKitUIElement.timer,
        SMKitUIElement.gaugeOfMotion,
      ],
    ),
    'LungeSideStaticRight': _ExerciseUiData(
      ExerciseTypeFilter.bodyAssessment,
      [
        SMKitUIElement.timer,
        SMKitUIElement.gaugeOfMotion,
      ],
    ),
    'OverheadMobility': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'StandingHamstringMobility': _ExerciseUiData(
      ExerciseTypeFilter.bodyAssessment,
      [
        SMKitUIElement.timer,
        SMKitUIElement.gaugeOfMotion,
      ],
    ),
    'StandingKneeRaiseLeft': _ExerciseUiData(
      ExerciseTypeFilter.bodyAssessment,
      [
        SMKitUIElement.timer,
        SMKitUIElement.gaugeOfMotion,
      ],
    ),
    'StandingKneeRaiseRight': _ExerciseUiData(
      ExerciseTypeFilter.bodyAssessment,
      [
        SMKitUIElement.timer,
        SMKitUIElement.gaugeOfMotion,
      ],
    ),
    'StandingSideBendLeft': _ExerciseUiData(
      ExerciseTypeFilter.bodyAssessment,
      [
        SMKitUIElement.timer,
        SMKitUIElement.gaugeOfMotion,
      ],
    ),
    'StandingSideBendRight': _ExerciseUiData(
      ExerciseTypeFilter.bodyAssessment,
      [
        SMKitUIElement.timer,
        SMKitUIElement.gaugeOfMotion,
      ],
    ),
    'CalfStretchLungePositionLeft': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'CalfStretchLungePositionRight': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'DownwardDogStretch': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'GlutesStretchOnTheFloorLeft': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'GlutesStretchOnTheFloorRight': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'GroinAndAdductor': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'HappyBaby': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
    ]),
    'HipExternalRotationFigureFourStretchLeft': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'HipExternalRotationFigureFourStretchRight': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'HipFlexorLungeStretchLeft': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'HipFlexorLungeStretchRight': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'HipFlexorStretchLeft': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'HipFlexorStretchRight': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'InternalRotationSideStretchLeft': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'InternalRotationSideStretchRight': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'KneelingQuadStretchLeft': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'KneelingQuadStretchRight': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'LatStretchLeft': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
    ]),
    'LatStretchRight': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
    ]),
    'LumbarRotationsSeatedLeft': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'LumbarRotationsSeatedRight': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'PlankHighStatic': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
    ]),
    'PlankLowStatic': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
    ]),
    'PrayerStretch': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
    ]),
    'RhomboidStretch': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
    ]),
    'PlankSideHighStatic': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'PlankSideHighStaticLeft': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'PlankSideHighStaticRight': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'PlankSideLowStatic': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'PlankSideLowStaticLeft': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'PlankSideLowStaticRight': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'SquatRegularOverheadStatic': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'SquatRegularStatic': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'SquatSumoStatic': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'SeatedBowArrowThoracicMobilityLeft': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'SeatedBowArrowThoracicMobilityRight': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'SeatedHipRotationsLeft': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'SeatedHipRotationsRight': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'SeatedThoracicSideBendingLeft': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'SeatedThoracicSideBendingRight': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'SideLungeHoldLeft': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'SideLungeHoldRight': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'SingleLegHamstringStretchLeft': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'SingleLegHamstringStretchRight': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'SingleLegStanceLeft': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
    ]),
    'SingleLegStanceRight': _ExerciseUiData(ExerciseTypeFilter.mobility, [
      SMKitUIElement.timer,
    ]),
    'SitupRussianTwistStatic': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
    ]),
    'StandingForwardFold': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
    ]),
    'WideInnerThighStretch': _ExerciseUiData(
      ExerciseTypeFilter.mobility,
      [SMKitUIElement.timer],
    ),
    'TuckHold': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'GlutesBridgeHold': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'HollowHold': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
    'ReverseTableTopHold': _ExerciseUiData(ExerciseTypeFilter.static_, [
      SMKitUIElement.timer,
      SMKitUIElement.gaugeOfMotion,
    ]),
  };

  static const Map<String, ExerciseRomTarget> _romTargets = {
    'AnkleMobilityLeft': ExerciseRomTarget(
      androidValue: 'AnklesMobilityBendLeg',
      iosValue: 'AnklesMobilityBendLeg',
    ),
    'AnkleMobilityRight': ExerciseRomTarget(
      androidValue: 'AnklesMobilityBendLeg',
      iosValue: 'AnklesMobilityBendLeg',
    ),
    'GlutesBridgeHold': ExerciseRomTarget(
      androidValue: 'GlutesBrHipExtension',
      iosValue: 'GlutesBridgeHipExtension',
    ),
    'HipExternalRotationLeft': ExerciseRomTarget(
      androidValue: 'HipExternalRotationGlutesMobilityArmsToTheSide',
      iosValue: 'HipExternalRotationArmsToTheSide',
    ),
    'HipExternalRotationRight': ExerciseRomTarget(
      androidValue: 'HipExternalRotationGlutesMobilityArmsToTheSide',
      iosValue: 'HipExternalRotationArmsToTheSide',
    ),
    'HipFlexionLeft': ExerciseRomTarget(
      androidValue: 'HipFlexionMobilityRaiseLeg',
      iosValue: 'HipFlexionRaiseLeg',
    ),
    'HipFlexionRight': ExerciseRomTarget(
      androidValue: 'HipFlexionMobilityRaiseLeg',
      iosValue: 'HipFlexionRaiseLeg',
    ),
    'HipInternalRotationLeft': ExerciseRomTarget(
      androidValue: 'HipInternalRotationMobilityRotationScore',
      iosValue: 'HipInternalRotationRotationScore',
    ),
    'HipInternalRotationRight': ExerciseRomTarget(
      androidValue: 'HipInternalRotationMobilityRotationScore',
      iosValue: 'HipInternalRotationRotationScore',
    ),
    'HollowHold': ExerciseRomTarget(
      androidValue: 'HollowHoldLegsLow',
      iosValue: 'HollowHoldLegsLow',
    ),
    'InnerThighMobility': ExerciseRomTarget(
      androidValue: 'InnerThighMobilityKneeAngle',
      iosValue: 'InnerThighMobilityKneeAngle',
    ),
    'JeffersonCurl': ExerciseRomTarget(
      androidValue: 'JeffersonCurlHandsReach',
      iosValue: 'JeffersonCurlHandsReach',
    ),
    'LungeSideStaticLeft': ExerciseRomTarget(
      androidValue: 'SideLungeBendLeg',
      iosValue: 'LungeSideBendLeg',
    ),
    'LungeSideStaticRight': ExerciseRomTarget(
      androidValue: 'SideLungeBendLeg',
      iosValue: 'LungeSideBendLeg',
    ),
    'OverheadMobility': ExerciseRomTarget(
      androidValue: 'OverheadMobilityRaiseHands',
      iosValue: 'OverheadMobilityRaiseHands',
    ),
    'PlankSideHighStatic': ExerciseRomTarget(
      androidValue: 'PlankSideSag',
      iosValue: 'PlankSideSag',
    ),
    'PlankSideHighStaticLeft': ExerciseRomTarget(
      androidValue: 'PlankSideSag',
      iosValue: 'PlankSideSag',
    ),
    'PlankSideHighStaticRight': ExerciseRomTarget(
      androidValue: 'PlankSideSag',
      iosValue: 'PlankSideSag',
    ),
    'PlankSideLowStatic': ExerciseRomTarget(
      androidValue: 'PlankSideSag',
      iosValue: 'PlankSideSag',
    ),
    'PlankSideLowStaticLeft': ExerciseRomTarget(
      androidValue: 'PlankSideSag',
      iosValue: 'PlankSideSag',
    ),
    'PlankSideLowStaticRight': ExerciseRomTarget(
      androidValue: 'PlankSideSag',
      iosValue: 'PlankSideSag',
    ),
    'ReverseTableTopHold': ExerciseRomTarget(
      androidValue: 'ReverseSitToTableTopHipsRaise',
      iosValue: 'ReverseSitToTableTopHipsRaise',
    ),
    'RhomboidStretch': ExerciseRomTarget(
      androidValue: 'RhomboidStretchUpperBodyNotBent',
      iosValue: 'RhomboidStretchUpperBodyNotBent',
    ),
    'SeatedBowArrowThoracicMobilityLeft': ExerciseRomTarget(
      androidValue: 'SeatedThoracicMobilityRotation',
      iosValue: 'SeatedThoracicMobilityRotation',
    ),
    'SeatedBowArrowThoracicMobilityRight': ExerciseRomTarget(
      androidValue: 'SeatedThoracicMobilityRotation',
      iosValue: 'SeatedThoracicMobilityRotation',
    ),
    'SeatedThoracicSideBendingLeft': ExerciseRomTarget(
      androidValue: 'SeatedThoracicSideBendingLateralFlex',
      iosValue: 'SeatedThoracicSideBendingLateralFlex',
    ),
    'SeatedThoracicSideBendingRight': ExerciseRomTarget(
      androidValue: 'SeatedThoracicSideBendingLateralFlex',
      iosValue: 'SeatedThoracicSideBendingLateralFlex',
    ),
    'SideLungeHoldLeft': ExerciseRomTarget(
      androidValue: 'SideLungeBendLeg',
      iosValue: 'LungeSideBendLeg',
    ),
    'SideLungeHoldRight': ExerciseRomTarget(
      androidValue: 'SideLungeBendLeg',
      iosValue: 'LungeSideBendLeg',
    ),
    'StandingKneeRaiseLeft': ExerciseRomTarget(
      androidValue: 'StandingKneeRaiseElevation',
      iosValue: 'StandingKneeRaiseElevation',
    ),
    'StandingKneeRaiseRight': ExerciseRomTarget(
      androidValue: 'StandingKneeRaiseElevation',
      iosValue: 'StandingKneeRaiseElevation',
    ),
    'StandingSideBendLeft': ExerciseRomTarget(
      androidValue: 'SideBendLateralTorsoFlex',
      iosValue: 'StandingSideBendLateralTorsoFlex',
    ),
    'StandingSideBendRight': ExerciseRomTarget(
      androidValue: 'SideBendLateralTorsoFlex',
      iosValue: 'StandingSideBendLateralTorsoFlex',
    ),
    'TuckHold': ExerciseRomTarget(
      androidValue: 'TuckHoldRaise',
      iosValue: 'TuckHoldRaise',
    ),
  };

  static final List<ExerciseCatalogEntry> allExercises = [
    for (final entry in _exerciseUiData.entries)
      _buildCatalogEntry(
        detector: entry.key,
        type: entry.value.type,
        uiElements: entry.value.uiElements,
        romTarget: _romTargets[entry.key],
      ),
  ]..sort((a, b) => a.detector.compareTo(b.detector));

  static final Map<String, ExerciseCatalogEntry> byDetector = {
    for (final exercise in allExercises) exercise.detector: exercise,
  };

  static List<ExerciseCatalogEntry> filteredExercises(
    ExerciseTypeFilter filter,
  ) {
    if (filter == ExerciseTypeFilter.all) {
      return allExercises;
    }
    if (filter == ExerciseTypeFilter.mobility) {
      return allExercises
          .where((exercise) =>
              exercise.type == ExerciseTypeFilter.mobility ||
              exercise.type == ExerciseTypeFilter.bodyAssessment)
          .toList();
    }
    return allExercises.where((exercise) => exercise.type == filter).toList();
  }

  static ExerciseCatalogEntry _buildCatalogEntry({
    required String detector,
    required ExerciseTypeFilter type,
    required List<SMKitUIElement> uiElements,
    required ExerciseRomTarget? romTarget,
  }) {
    final isDynamic = type == ExerciseTypeFilter.dynamic_;
    return ExerciseCatalogEntry(
      detector: detector,
      type: type,
      uiElements: uiElements,
      assessmentModes: isDynamic
          ? const [AssessmentScoringMode.reps]
          : romTarget == null
              ? const [AssessmentScoringMode.time]
              : const [AssessmentScoringMode.rom, AssessmentScoringMode.time],
      defaultDuration: isDynamic ? defaultRepsDuration : defaultStaticDuration,
      defaultTargetReps: defaultTargetReps,
      defaultTargetTime: defaultTargetTime,
      romTarget: romTarget,
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';
import 'package:flutter_smkit_ui/models/sm_workout.dart';
import 'package:flutter_smkit_ui/models/smkit_ui_config.dart';
import 'package:flutter_smkit_ui/models/smkit_ui_handlers.dart';
import 'package:path_provider/path_provider.dart';

enum _ExerciseTypeFilter { all, dynamic_, static_, mobility, bodyAssessment }

class _ExerciseData {
  final _ExerciseTypeFilter type;
  final List<SMKitUIElement> uiElements;
  const _ExerciseData(this.type, this.uiElements);
}

class _WorkoutExercise {
  final String name;
  _WorkoutExercise({required this.name});
}

class WorkoutBuilderScreen extends StatefulWidget {
  final SmkitUiFlutterPlugin plugin;
  final Map<String, dynamic> modifications;
  final bool enableIntelligenceRest;
  final void Function(SMKitStatus) onHandle;

  const WorkoutBuilderScreen({
    super.key,
    required this.plugin,
    required this.modifications,
    this.enableIntelligenceRest = false,
    required this.onHandle,
  });

  @override
  State<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends State<WorkoutBuilderScreen> {
  // Single source of truth derived from ExerciseUIDefaults.swift.
  // Type rules from the original Swift UIElement sets:
  //   repsCounter / quickMotion → dynamic
  //   gaugeOfMotion + countdownTimer (no repsCounter) → mobility
  //   holdingPosition / countdownTimer-only / bare hold → static
  // Flutter's SMKitUIElement only has: timer, repsCounter, gaugeOfMotion.
  static const Map<String, _ExerciseData> _exerciseData = {
    // ── Dynamic (repsCounter) ──────────────────────────────────────────────
    'AirJumpRope':               _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'AlternateWindmillToeTouch': _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'BackSuperman':              _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'BackSupermanHold':          _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'BirdDog':                   _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'Burpees':                   _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'ButtKicks':                 _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'CalfRaises':                _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'ClamshellsLeft':            _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'ClamshellsRight':           _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'Crunches':                  _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'Froggers':                  _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'GlutesBridge':              _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'HandGrip':                  _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'HighKnees':                 _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'JumpingJacks':              _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'Jumps':                     _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'LateralHandRaise':          _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'LateralHandRaiseLeft':      _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'LateralHandRaiseRight':     _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'LateralRaises':             _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'LungeFront':                _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'LungeFrontAlternate':       _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'LungeFrontLeft':            _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'LungeFrontRight':           _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'LungeJumps':                _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'LungeRegularStatic':        _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'LungeSide':                 _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'LungeSideLeft':             _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'LungeSideRight':            _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'PlankCommando':             _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'PlankHighShoulderTaps':     _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'PlankHighToeTaps':          _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'PlankJacksHigh':            _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'PlankLowHipTwist':          _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'PlankWalkouts':             _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'PushupKnees':               _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'PushupRegular':             _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'PushupWide':                _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'QuadThoraticRotation':      _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'QuadThoraticRotationLeft':  _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'QuadThoraticRotationRight': _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'ReverseSitToTableTop':      _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'SeatedShadowBoxing':        _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'ShouldersPress':            _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'SideLunge':                 _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'SideStepJacks':             _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'SingleHandOverheadHealDigs':_ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'SitToStand':                _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'SitupPenguin':              _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'SitupRussianTwist':         _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'SkaterHops':                _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'SkiJumps':                  _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'Skydivers':                 _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'SkydiversHold':             _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'SquatAndKick':              _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'SquatAndRotationJab':       _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'SquatAndStep':              _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'SquatNarrow':               _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'SquatRegular':              _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'SquatRegularOverhead':      _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'SquatSumo':                 _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter, SMKitUIElement.gaugeOfMotion]),
    'StandingAlternateToeTouch': _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'StandingBicycleCrunches':   _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'StandingObliqueCrunches':   _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    'ToesRaises':                _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer, SMKitUIElement.repsCounter]),
    // ── Dynamic (quickMotion) ────────────────────────────────────
    'FastMarchRun':              _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer]),
    'PogoJumps':                 _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer]),
    'PowerWalkInPlace':          _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer]),
    'QuickFeet':                 _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer]),
    'ShoulderCircles':           _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer]),
    'SquatPulsing':              _ExerciseData(_ExerciseTypeFilter.dynamic_, [SMKitUIElement.timer]),
    // ── Mobility (gaugeOfMotion + countdownTimer, no repsCounter in Swift) ─
    'AnkleMobilityLeft':         _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'AnkleMobilityRight':        _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'HamstringMobility':         _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'HipExternalRotationLeft':   _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'HipExternalRotationRight':  _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'HipFlexionLeft':            _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'HipFlexionRight':           _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'HipInternalRotationLeft':   _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'HipInternalRotationRight':  _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'InnerThighMobility':        _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'JeffersonCurl':             _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'LungeSideStaticLeft':       _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'LungeSideStaticRight':      _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'OverheadMobility':          _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'StandingHamstringMobility': _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'StandingKneeRaiseLeft':     _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'StandingKneeRaiseRight':    _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'StandingSideBendLeft':      _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'StandingSideBendRight':     _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    // ── Static + holdingPosition) ────────────────────────────────
    'CalfStretchLungePositionLeft':              _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'CalfStretchLungePositionRight':             _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'DownwardDogStretch':                        _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'GlutesStretchOnTheFloorLeft':               _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'GlutesStretchOnTheFloorRight':              _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'GroinAndAdductor':                          _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'HappyBaby':                                 _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'HipExternalRotationFigureFourStretchLeft':  _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'HipExternalRotationFigureFourStretchRight': _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'HipFlexorLungeStretchLeft':                 _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'HipFlexorLungeStretchRight':                _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'HipFlexorStretchLeft':                      _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'HipFlexorStretchRight':                     _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'InternalRotationSideStretchLeft':           _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'InternalRotationSideStretchRight':          _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'KneelingQuadStretchLeft':                   _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'KneelingQuadStretchRight':                  _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'LatStretchLeft':                            _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'LatStretchRight':                           _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'LumbarRotationsSeatedLeft':                 _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'LumbarRotationsSeatedRight':                _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'PlankHighStatic':                           _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer]),
    'PlankLowStatic':                            _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer]),
    'PrayerStretch':                             _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'RhomboidStretch':                           _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'PlankSideHighStatic':       _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'PlankSideHighStaticLeft':   _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'PlankSideHighStaticRight':  _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'PlankSideLowStatic':        _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'PlankSideLowStaticLeft':    _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'PlankSideLowStaticRight':   _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'SquatRegularOverheadStatic':                _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'SquatRegularStatic':                        _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'SquatSumoStatic':                           _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'SeatedBowArrowThoracicMobilityLeft':        _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'SeatedBowArrowThoracicMobilityRight':       _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'SeatedHipRotationsLeft':                    _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'SeatedHipRotationsRight':                   _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'SeatedThoracicSideBendingLeft':             _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'SeatedThoracicSideBendingRight':            _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'SideLungeHoldLeft':                         _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'SideLungeHoldRight':                        _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'SingleLegHamstringStretchLeft':             _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'SingleLegHamstringStretchRight':            _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'SingleLegStanceLeft':                       _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'SingleLegStanceRight':                      _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'SitupRussianTwistStatic':                   _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer]),
    'StandingForwardFold':                       _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer]),
    'WideInnerThighStretch':                     _ExerciseData(_ExerciseTypeFilter.mobility, [SMKitUIElement.timer]),
    'TuckHold':                                  _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'GlutesBridgeHold':     _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'HollowHold':           _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
    'ReverseTableTopHold':  _ExerciseData(_ExerciseTypeFilter.static_, [SMKitUIElement.timer, SMKitUIElement.gaugeOfMotion]),
  };

  static final List<String> _allExercises =
      (_exerciseData.keys.toList()..sort());

  _ExerciseTypeFilter _selectedFilter = _ExerciseTypeFilter.all;
  String? _selectedExercise;
  final List<_WorkoutExercise> _selectedExercises = [];
  int _rowingLevelIndex = 0;

  List<String> get _filteredExercises {
    if (_selectedFilter == _ExerciseTypeFilter.all) return _allExercises;
    return _allExercises
        .where((e) => _exerciseData[e]?.type == _selectedFilter)
        .toList();
  }

  bool get _hasRowing => _selectedExercises.any((e) => e.name == 'Rowing');

  String _filterLabel(_ExerciseTypeFilter f) => switch (f) {
        _ExerciseTypeFilter.all => 'All',
        _ExerciseTypeFilter.dynamic_ => 'Dynamic',
        _ExerciseTypeFilter.static_ => 'Static',
        _ExerciseTypeFilter.mobility => 'Mobility',
        _ExerciseTypeFilter.bodyAssessment => 'Body Assessment',
      };

  void _chooseExercise() {
    final exercises = _filteredExercises;
    int tempIndex = 0;
    if (_selectedExercise != null) {
      final idx = exercises.indexOf(_selectedExercise!);
      if (idx >= 0) tempIndex = idx;
    }
    final scrollController =
        FixedExtentScrollController(initialItem: tempIndex);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_selectedFilter == _ExerciseTypeFilter.all
            ? 'Choose Exercise'
            : 'Choose Exercise (${_filterLabel(_selectedFilter)})'),
        content: SizedBox(
          width: double.maxFinite,
          height: 160,
          child: ListWheelScrollView.useDelegate(
            controller: scrollController,
            itemExtent: 40,
            diameterRatio: 1.5,
            onSelectedItemChanged: (i) => tempIndex = i,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: exercises.length,
              builder: (_, i) => Center(
                child: Text(exercises[i], style: const TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _selectedExercise = exercises[tempIndex]);
              Navigator.pop(context);
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  void _addExercise() {
    if (_selectedExercise == null) return;
    setState(() {
      _selectedExercises.add(_WorkoutExercise(name: _selectedExercise!));
    });
  }

  void _clearExercises() => setState(() => _selectedExercises.clear());

  Future<void> _startWorkout() async {
    if (_selectedExercises.isEmpty) return;

    await widget.plugin.setConfig(
      config: SMKitConfig(enableIntelligenceRest: widget.enableIntelligenceRest),
    );

    final exercises = _selectedExercises.map((e) {
      final ui = _exerciseData[e.name]?.uiElements ?? [SMKitUIElement.timer];
      return SMKitExercise(
        prettyName: e.name,
        totalSeconds: 60,
        videoInstruction: '${e.name}InstructionVideo',
        detector: e.name,
        uiElements: ui,
      );
    }).toList();

    String? introURL;
    try {
      final byteData = await rootBundle.load('customWorkoutIntro.mp3');
      final file = File(
          '${(await getTemporaryDirectory()).path}/customWorkoutIntro.mp3');
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      introURL = file.path;
    } catch (_) {}

    widget.plugin.startCustomizedWorkout(
      workout: SMKitWorkout(
        id: '',
        name: 'TEST WORKOUT',
        workoutIntro: introURL,
        soundTrack: null,
        exercises: exercises,
        workoutClosure: null,
      ),
      modifications: widget.modifications,
      onHandle: widget.onHandle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercisesText = _selectedExercises.isEmpty
        ? 'Workout Exercises: None'
        : 'Workout Exercises (${_selectedExercises.length}):\n'
            '${_selectedExercises.asMap().entries.map((e) => '${e.key + 1}. ${e.value.name}').join('\n')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Builder')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _ExerciseTypeFilter.values.map((f) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: ChoiceChip(
                        label: Text(_filterLabel(f)),
                        selected: _selectedFilter == f,
                        onSelected: (_) => setState(() {
                          _selectedFilter = f;
                          if (_selectedExercise != null &&
                              !_filteredExercises.contains(_selectedExercise)) {
                            _selectedExercise = null;
                          }
                        }),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedExercise != null
                        ? Colors.blue
                        : Colors.blueGrey,
                  ),
                  onPressed: _chooseExercise,
                  child: Text(_selectedExercise ?? 'Choose exercise',
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 300,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedExercise != null
                        ? Colors.green
                        : Colors.green.withValues(alpha: 0.5),
                  ),
                  onPressed: _selectedExercise != null ? _addExercise : null,
                  child: const Text('+ Add Exercise to Workout',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 15),
              Text(exercisesText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              SizedBox(
                width: 150,
                height: 35,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.8)),
                  onPressed: _clearExercises,
                  child: const Text('Clear All',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              if (_hasRowing) ...[
                const SizedBox(height: 15),
                const Text('Rowing feedback level:',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Expert')),
                    ButtonSegment(value: 1, label: Text('Advanced')),
                    ButtonSegment(value: 2, label: Text('Beginner')),
                  ],
                  selected: {_rowingLevelIndex},
                  onSelectionChanged: (s) =>
                      setState(() => _rowingLevelIndex = s.first),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedExercises.isNotEmpty
                        ? Colors.blue
                        : Colors.grey.withValues(alpha: 0.5),
                  ),
                  onPressed:
                      _selectedExercises.isNotEmpty ? _startWorkout : null,
                  child: const Text('START WORKOUT',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

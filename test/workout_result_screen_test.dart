import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';
import 'package:smkit_ui_flutter_demo_app/WorkoutResultScreen.dart';

void main() {
  testWidgets('shows native insight and hold timing fields', (tester) async {
    final result = SMCustomWorkoutData.fromJson({
      'sessionId': 'session-1',
      'exercises': [
        {
          'summaryTitle': 'Wall sit',
          'position_rep_config': {'targetReps': 3, 'secondsPerRep': 5},
          'internal_insights': {
            'entries': [
              {'insight': 'Steady hold', 'impact': 'positive'},
            ],
          },
          'max_consecutive_hold_seconds': 6.0,
        },
      ],
    });

    await tester.pumpWidget(
      MaterialApp(home: WorkoutResultScreen(workoutResult: result)),
    );

    expect(find.text('Session: session-1'), findsOneWidget);
    expect(find.textContaining('Wall sit'), findsOneWidget);
    expect(find.textContaining('Longest hold: 6.0s'), findsOneWidget);
    expect(find.textContaining('Steady hold'), findsOneWidget);
  });
}

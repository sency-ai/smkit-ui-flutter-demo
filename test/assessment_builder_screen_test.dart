import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';
import 'package:smkit_ui_flutter_demo_app/AssessmentBuilderScreen.dart';

void main() {
  Future<void> pumpBuilder(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AssessmentBuilderScreen(
          plugin: SmkitUiFlutterPlugin(),
          modifications: const {},
          enableIntelligenceRest: false,
          showSummary: false,
          onHandle: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> addExercise(WidgetTester tester, String detector) async {
    final addButton = find.byKey(ValueKey('add-$detector'));
    await tester.scrollUntilVisible(
      addButton,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('selected-1')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dynamic exercises default to reps with 30 seconds and 5 reps',
      (tester) async {
    await pumpBuilder(tester);

    await tester.tap(find.byKey(const ValueKey('filter-dynamic_')));
    await tester.pumpAndSettle();
    await addExercise(tester, 'HighKnees');

    expect(find.byKey(const ValueKey('mode-1')), findsNothing);
    expect(find.byKey(const ValueKey('reps-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('time-1')), findsNothing);
    expect(find.text('Duration: 30 sec'), findsOneWidget);
    expect(find.text('Target reps: 5 reps'), findsOneWidget);
  });

  testWidgets('time-only exercises default to 10-second duration and target',
      (tester) async {
    await pumpBuilder(tester);

    await tester.tap(find.byKey(const ValueKey('filter-static_')));
    await tester.pumpAndSettle();
    await addExercise(tester, 'PlankHighStatic');

    expect(find.byKey(const ValueKey('mode-1')), findsNothing);
    expect(find.byKey(const ValueKey('time-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('reps-1')), findsNothing);
    expect(find.text('Duration: 10 sec'), findsOneWidget);
    expect(find.text('Target time: 10 sec'), findsOneWidget);
  });

  testWidgets('ROM exercises default to ROM mode with the mapped target',
      (tester) async {
    await pumpBuilder(tester);

    await tester.tap(find.byKey(const ValueKey('filter-mobility')));
    await tester.pumpAndSettle();
    await addExercise(tester, 'HipFlexionLeft');

    expect(find.byKey(const ValueKey('mode-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('reps-1')), findsNothing);
    expect(find.byKey(const ValueKey('time-1')), findsNothing);
    expect(find.text('Duration: 10 sec'), findsOneWidget);
    expect(find.text('HipFlexionMobilityRaiseLeg'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/application/ai_scheduler_view_data.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/presentation/ai_scheduler_page.dart';

void main() {
  testWidgets('shows empty state and invokes proposal generation', (tester) async {
    var generated = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiSchedulerPage(
            onGenerate: () => generated = true,
          ),
        ),
      ),
    );

    expect(find.text('ยังไม่มีข้อเสนอตารางเวร'), findsOneWidget);
    expect(find.text('Generate proposal'), findsNWidgets(2));

    await tester.tap(find.text('Generate proposal').last);

    expect(generated, isTrue);
  });

  testWidgets('shows canonical proposal view data and actions', (tester) async {
    var approved = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiSchedulerPage(
            proposal: const AiSchedulerViewData(
              score: 95,
              conflictCount: 0,
              fairnessLabel: 'Excellent',
              explanations: ['Balanced proposal'],
              requiresApproval: true,
              isComplete: true,
            ),
            onApprove: () => approved = true,
          ),
        ),
      ),
    );

    expect(find.text('95'), findsOneWidget);
    expect(find.text('Excellent'), findsOneWidget);
    expect(find.text('Balanced proposal'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Compare'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);

    await tester.tap(find.text('Approve'));

    expect(approved, isTrue);
  });

  testWidgets('disables approval when the proposal does not require it', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AiSchedulerPage(
            proposal: AiSchedulerViewData(
              score: 100,
              conflictCount: 0,
              fairnessLabel: 'Excellent',
              explanations: [],
              requiresApproval: false,
              isComplete: true,
            ),
          ),
        ),
      ),
    );

    final approveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Approve'),
    );

    expect(approveButton.onPressed, isNull);
  });
}

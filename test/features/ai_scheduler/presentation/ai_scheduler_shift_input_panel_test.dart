import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/domain/entities/shift_template.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/presentation/ai_scheduler_shift_input_controller.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/presentation/ai_scheduler_shift_input_panel.dart';

void main() {
  const morning = ShiftTemplate(
    id: 'morning',
    code: 'M',
    name: 'Morning',
    startTime: Duration(hours: 8),
    endTime: Duration(hours: 16),
    colorValue: 0xFF039BE5,
    workingHours: 8,
  );

  testWidgets('renders deterministic explicit inputs and removes them', (
    tester,
  ) async {
    final controller = AiSchedulerShiftInputController();
    controller.add(
      date: DateTime(2026, 8, 4),
      shift: morning,
      departmentId: 'RAD',
      location: 'CT',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiSchedulerShiftInputPanel(
            controller: controller,
            templates: const [morning],
          ),
        ),
      ),
    );

    expect(find.text('1 explicit slot(s)'), findsOneWidget);
    expect(find.text('2026-08-04 · Morning'), findsOneWidget);
    expect(find.text('RAD · CT'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove requested shift'));
    await tester.pump();

    expect(controller.inputs, isEmpty);
    expect(find.text('0 explicit slot(s)'), findsOneWidget);
  });

  testWidgets('disables adding when no active template is available', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiSchedulerShiftInputPanel(
            controller: AiSchedulerShiftInputController(),
            templates: const [],
          ),
        ),
      ),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(
      find.textContaining('No active shift templates are available'),
      findsOneWidget,
    );
  });
}

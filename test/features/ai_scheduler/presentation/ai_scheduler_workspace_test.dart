import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/application/ai_scheduler_controller.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/presentation/ai_scheduler_workspace.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  final request = SchedulerRequest(employeeIds: const ['e1'], slots: const []);

  testWidgets('generates a proposal through the application controller', (
    tester,
  ) async {
    final controller = AiSchedulerController(
      assistant: _FakeAssistant(_proposal()),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiSchedulerWorkspace(
            controller: controller,
            requestFactory: () => request,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Generate proposal').first);
    await tester.pump();

    expect(find.text('95'), findsOneWidget);
    expect(find.text('Balanced proposal'), findsOneWidget);
  });

  testWidgets('shows a generation failure without creating a proposal', (
    tester,
  ) async {
    final controller = AiSchedulerController(
      assistant: const _ThrowingAssistant(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiSchedulerWorkspace(
            controller: controller,
            requestFactory: () => request,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Generate proposal').first);
    await tester.pump();

    expect(find.textContaining('Unable to generate proposal'), findsOneWidget);
    expect(controller.proposal, isNull);
  });
}

AiScheduleProposal _proposal() {
  return AiScheduleProposal(
    schedule: const SchedulerResult(
      assignments: [],
      unassignedSlotIds: [],
      evaluation: RosterEvaluationReport(
        validation: RosterValidationResult(),
        fairness: RosterFairnessReport(
          score: 92,
          employeeSummaries: [],
          assignmentSpread: 0,
          nightSpread: 0,
          weekendSpread: 0,
        ),
        overallScore: 95,
      ),
    ),
    details: const [
      AiScheduleExplanation(
        code: 'balanced',
        kind: AiScheduleExplanationKind.fairness,
        message: 'Balanced proposal',
      ),
    ],
  );
}

final class _FakeAssistant implements AiSchedulerAssistant {
  const _FakeAssistant(this.proposal);

  final AiScheduleProposal proposal;

  @override
  AiScheduleProposal propose(SchedulerRequest request) => proposal;
}

final class _ThrowingAssistant implements AiSchedulerAssistant {
  const _ThrowingAssistant();

  @override
  AiScheduleProposal propose(SchedulerRequest request) {
    throw StateError('generation failed');
  }
}

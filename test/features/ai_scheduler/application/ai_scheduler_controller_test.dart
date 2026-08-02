import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/application/ai_scheduler_controller.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  final request = SchedulerRequest(employeeIds: const ['e1'], slots: const []);

  test('generates and maps a canonical proposal', () {
    final controller = AiSchedulerController(
      assistant: _FakeAssistant(_proposal()),
    );
    final statuses = <AiSchedulerStatus>[];
    controller.addListener(() => statuses.add(controller.status));

    controller.generate(request);

    expect(statuses, [AiSchedulerStatus.generating, AiSchedulerStatus.ready]);
    expect(controller.proposal?.score, 95);
    expect(controller.error, isNull);
    expect(controller.loading, isFalse);
  });

  test('exposes failures without retaining a stale proposal', () {
    final controller = AiSchedulerController(
      assistant: _ThrowingAssistant(StateError('generation failed')),
    );

    controller.generate(request);

    expect(controller.status, AiSchedulerStatus.failure);
    expect(controller.proposal, isNull);
    expect(controller.error, isA<StateError>());
  });

  test('reject clears the current proposal and returns to idle', () {
    final controller = AiSchedulerController(
      assistant: _FakeAssistant(_proposal()),
    );

    controller.generate(request);
    controller.reject();

    expect(controller.status, AiSchedulerStatus.idle);
    expect(controller.proposal, isNull);
    expect(controller.error, isNull);
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
  const _ThrowingAssistant(this.error);

  final Object error;

  @override
  AiScheduleProposal propose(SchedulerRequest request) => throw error;
}

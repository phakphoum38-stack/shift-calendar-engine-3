import 'package:test/test.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  SchedulerRequest request() {
    return SchedulerRequest(
      employeeIds: const ['e1', 'e2'],
      slots: [
        SchedulerShiftSlot(
          id: 'slot-1',
          shiftCode: 'M',
          startsAt: DateTime.utc(2026, 8, 1, 8),
          endsAt: DateTime.utc(2026, 8, 1, 16),
        ),
      ],
    );
  }

  test('selects a deterministic proposal and requires approval', () {
    final optimizer = DeterministicAiScheduleOptimizer(
      assistants: const [DeterministicAiScheduler()],
    );
    final coordinator = AiSchedulerCoordinator(optimizer: optimizer);

    final decision = coordinator.decide(request());

    expect(decision.evaluatedProposalCount, 1);
    expect(decision.isComplete, isTrue);
    expect(decision.requiresApproval, isTrue);
    expect(decision.canPublish, isFalse);
    expect(decision.explanations, isNotEmpty);
  });

  test('approval returns a publishable immutable decision', () {
    final optimizer = DeterministicAiScheduleOptimizer(
      assistants: const [DeterministicAiScheduler()],
    );
    final coordinator = AiSchedulerCoordinator(optimizer: optimizer);

    final decision = coordinator.decide(request());
    final approved = decision.approve();

    expect(decision.requiresApproval, isTrue);
    expect(approved.requiresApproval, isFalse);
    expect(approved.canPublish, isTrue);
    expect(approved.selectedProposal.schedule.assignments, hasLength(1));
  });
}

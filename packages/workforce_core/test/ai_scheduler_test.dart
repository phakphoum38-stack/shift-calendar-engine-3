import 'package:test/test.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  group('DeterministicAiScheduler', () {
    test('returns an explainable proposal that requires approval', () {
      final proposal = const DeterministicAiScheduler().propose(_request());

      expect(proposal.isComplete, isTrue);
      expect(proposal.requiresApproval, isTrue);
      expect(proposal.schedule.assignments, hasLength(1));
      expect(
        proposal.explanations,
        contains(
          'Human approval is required before this proposal is published or saved.',
        ),
      );
      expect(
        proposal.details.any(
          (item) =>
              item.kind == AiScheduleExplanationKind.assignment &&
              item.employeeId == 'e1' &&
              item.slotId == 'slot-1',
        ),
        isTrue,
      );
      expect(
        proposal.details.any(
          (item) => item.kind == AiScheduleExplanationKind.fairness,
        ),
        isTrue,
      );
    });
  });

  group('DeterministicAiScheduleOptimizer', () {
    test('simulates candidates and keeps approval required', () {
      final optimizer = DeterministicAiScheduleOptimizer(
        assistants: const [
          DeterministicAiScheduler(),
          DeterministicAiScheduler(),
        ],
      );

      final simulation = optimizer.simulate(_request());

      expect(simulation.proposals, hasLength(2));
      expect(simulation.bestProposal.isComplete, isTrue);
      expect(simulation.bestProposal.requiresApproval, isTrue);
    });

    test('rejects an empty assistant collection', () {
      expect(
        () => DeterministicAiScheduleOptimizer(assistants: const []),
        throwsArgumentError,
      );
    });
  });
}

SchedulerRequest _request() {
  return SchedulerRequest(
    employeeIds: const ['e1'],
    slots: [
      SchedulerShiftSlot(
        id: 'slot-1',
        shiftCode: 'M',
        startsAt: DateTime.utc(2026, 8, 5, 8),
        endsAt: DateTime.utc(2026, 8, 5, 16),
      ),
    ],
  );
}

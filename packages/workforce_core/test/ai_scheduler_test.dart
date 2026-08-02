import 'package:test/test.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  group('DeterministicAiScheduler', () {
    test('returns an explainable proposal that requires approval', () {
      final proposal = const DeterministicAiScheduler().propose(
        SchedulerRequest(
          employeeIds: const ['e1'],
          slots: [
            SchedulerShiftSlot(
              id: 'slot-1',
              shiftCode: 'M',
              startsAt: DateTime.utc(2026, 8, 5, 8),
              endsAt: DateTime.utc(2026, 8, 5, 16),
            ),
          ],
        ),
      );

      expect(proposal.isComplete, isTrue);
      expect(proposal.requiresApproval, isTrue);
      expect(proposal.schedule.assignments, hasLength(1));
      expect(
        proposal.explanations,
        contains('Human approval is required before this proposal is published or saved.'),
      );
    });
  });
}

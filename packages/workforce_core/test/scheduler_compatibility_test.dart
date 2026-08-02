// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

import 'package:test/test.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  group('scheduler compatibility layer', () {
    test('legacy API delegates to canonical scheduler', () {
      final existing = ShiftAssignment(
        id: 'existing-e1',
        employeeId: 'e1',
        shiftCode: 'M',
        startsAt: DateTime.utc(2026, 8, 3, 8),
        endsAt: DateTime.utc(2026, 8, 3, 16),
      );
      final slot = SchedulerShiftSlot(
        id: 'slot-1',
        shiftCode: 'M',
        startsAt: DateTime.utc(2026, 8, 3, 8),
        endsAt: DateTime.utc(2026, 8, 3, 16),
      );

      final result = const GreedyRosterScheduler().generate(
        RosterSchedulerRequest(
          employeeIds: const ['e1', 'e2'],
          shifts: [slot],
          existingAssignments: [existing],
        ),
      );

      expect(result.isComplete, isTrue);
      expect(result.assignments, hasLength(1));
      expect(result.assignments.single.id, 'slot-1::e2');
    });

    test('canonical API also respects existing assignments', () {
      final existing = ShiftAssignment(
        id: 'existing-e1',
        employeeId: 'e1',
        shiftCode: 'M',
        startsAt: DateTime.utc(2026, 8, 4, 8),
        endsAt: DateTime.utc(2026, 8, 4, 16),
      );

      final result = const GreedyScheduler().generate(
        SchedulerRequest(
          employeeIds: const ['e1', 'e2'],
          slots: [
            SchedulerShiftSlot(
              id: 'slot-2',
              shiftCode: 'M',
              startsAt: DateTime.utc(2026, 8, 4, 8),
              endsAt: DateTime.utc(2026, 8, 4, 16),
            ),
          ],
          existingAssignments: [existing],
        ),
      );

      expect(result.isComplete, isTrue);
      expect(result.assignments, hasLength(1));
      expect(result.assignments.single.employeeId, 'e2');
    });
  });
}

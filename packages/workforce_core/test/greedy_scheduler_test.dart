import 'package:test/test.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  SchedulerShiftSlot shift(String id, int day) {
    return SchedulerShiftSlot(
      id: id,
      shiftCode: 'M',
      startsAt: DateTime.utc(2026, 8, day, 8),
      endsAt: DateTime.utc(2026, 8, day, 16),
    );
  }

  test('assigns shifts deterministically and balances workload', () {
    final result = const GreedyRosterScheduler().generate(
      RosterSchedulerRequest(
        employeeIds: const ['e2', 'e1'],
        shifts: [shift('s1', 1), shift('s2', 2), shift('s3', 3)],
      ),
    );

    expect(result.isComplete, isTrue);
    expect(result.assignments, hasLength(3));
    expect(result.assignments.map((value) => value.employeeId), [
      'e1',
      'e2',
      'e1',
    ]);
    expect(result.evaluation.validation.isValid, isTrue);
    expect(result.evaluation.fairness.assignmentSpread, 1);
  });

  test('respects leave windows and selects another employee', () {
    final result = const GreedyRosterScheduler().generate(
      RosterSchedulerRequest(
        employeeIds: const ['e1', 'e2'],
        shifts: [shift('s1', 1)],
        timeWindows: [
          EmployeeTimeWindow(
            id: 'leave-1',
            employeeId: 'e1',
            type: EmployeeTimeWindowType.leave,
            startsAt: DateTime.utc(2026, 8, 1),
            endsAt: DateTime.utc(2026, 8, 2),
          ),
        ],
      ),
    );

    expect(result.isComplete, isTrue);
    expect(result.assignments.single.employeeId, 'e2');
  });

  test('reports a shift as unassigned when every candidate is unavailable', () {
    final result = const GreedyRosterScheduler().generate(
      RosterSchedulerRequest(
        employeeIds: const ['e1'],
        shifts: [shift('s1', 1)],
        timeWindows: [
          EmployeeTimeWindow(
            id: 'availability-1',
            employeeId: 'e1',
            type: EmployeeTimeWindowType.availability,
            startsAt: DateTime.utc(2026, 8, 1, 18),
            endsAt: DateTime.utc(2026, 8, 1, 23),
          ),
        ],
      ),
    );

    expect(result.isComplete, isFalse);
    expect(result.assignments, isEmpty);
    expect(result.unassignedShiftIds, ['s1']);
  });
}

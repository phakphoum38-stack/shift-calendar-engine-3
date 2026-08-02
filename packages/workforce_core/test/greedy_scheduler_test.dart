import 'package:test/test.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  SchedulerShiftSlot slot(String id, int day) {
    return SchedulerShiftSlot(
      id: id,
      shiftCode: 'M',
      startsAt: DateTime.utc(2026, 8, day, 8),
      endsAt: DateTime.utc(2026, 8, day, 16),
    );
  }

  test('distributes slots deterministically across employees', () {
    final result = const GreedyScheduler().generate(
      SchedulerRequest(
        employeeIds: const ['e2', 'e1'],
        slots: [slot('s1', 1), slot('s2', 2), slot('s3', 3)],
      ),
    );

    expect(result.isComplete, isTrue);
    expect(result.assignments, hasLength(3));
    expect(
      result.assignments.map((value) => value.employeeId),
      orderedEquals(['e1', 'e2', 'e1']),
    );
    expect(result.evaluation.validation.isValid, isTrue);
  });

  test('leaves a slot unassigned when every employee is unavailable', () {
    final result = const GreedyScheduler().generate(
      SchedulerRequest(
        employeeIds: const ['e1', 'e2'],
        slots: [slot('s1', 1)],
        timeWindows: [
          for (final employeeId in const ['e1', 'e2'])
            EmployeeTimeWindow(
              id: 'leave-$employeeId',
              employeeId: employeeId,
              kind: EmployeeTimeWindowKind.leave,
              startsAt: DateTime.utc(2026, 8, 1),
              endsAt: DateTime.utc(2026, 8, 2),
            ),
        ],
      ),
    );

    expect(result.isComplete, isFalse);
    expect(result.assignments, isEmpty);
    expect(result.unassignedSlotIds, ['s1']);
  });

  test('existing assignments influence load balancing', () {
    final result = const GreedyScheduler().generate(
      SchedulerRequest(
        employeeIds: const ['e1', 'e2'],
        slots: [slot('s2', 2)],
        existingAssignments: [
          ShiftAssignment(
            id: 'existing-e1',
            employeeId: 'e1',
            shiftCode: 'M',
            startsAt: DateTime.utc(2026, 8, 1, 8),
            endsAt: DateTime.utc(2026, 8, 1, 16),
          ),
        ],
      ),
    );

    expect(result.assignments.single.employeeId, 'e2');
    expect(result.evaluation.fairness.assignmentSpread, 0);
  });

  test('existing overlap prevents assigning the same employee', () {
    final result = const GreedyScheduler().generate(
      SchedulerRequest(
        employeeIds: const ['e1', 'e2'],
        slots: [slot('s1', 1)],
        existingAssignments: [
          ShiftAssignment(
            id: 'existing-e1',
            employeeId: 'e1',
            shiftCode: 'M',
            startsAt: DateTime.utc(2026, 8, 1, 8),
            endsAt: DateTime.utc(2026, 8, 1, 16),
          ),
        ],
      ),
    );

    expect(result.assignments.single.employeeId, 'e2');
    expect(result.evaluation.validation.isValid, isTrue);
  });

  test('request rejects duplicate employee ids', () {
    expect(
      () => SchedulerRequest(employeeIds: const ['e1', 'e1'], slots: const []),
      throwsArgumentError,
    );
  });

  test('request rejects existing assignments for unknown employees', () {
    expect(
      () => SchedulerRequest(
        employeeIds: const ['e1'],
        slots: const [],
        existingAssignments: [
          ShiftAssignment(
            id: 'a1',
            employeeId: 'e2',
            shiftCode: 'M',
            startsAt: DateTime.utc(2026, 8, 1, 8),
            endsAt: DateTime.utc(2026, 8, 1, 16),
          ),
        ],
      ),
      throwsArgumentError,
    );
  });
}

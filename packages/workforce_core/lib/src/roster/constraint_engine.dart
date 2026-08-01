import 'employee_availability.dart';
import 'roster_constraint.dart';
import 'roster_validation.dart';
import 'shift_assignment.dart';

final class RosterConstraintEngine {
  const RosterConstraintEngine({this.policy = const RosterConstraintPolicy()});

  final RosterConstraintPolicy policy;

  RosterValidationResult validate(
    List<ShiftAssignment> assignments, {
    List<EmployeeTimeWindow> timeWindows = const [],
  }) {
    final violations = <RosterViolation>[];
    final byEmployee = <String, List<ShiftAssignment>>{};
    final windowsByEmployee = <String, List<EmployeeTimeWindow>>{};

    for (final assignment in assignments) {
      byEmployee
          .putIfAbsent(assignment.employeeId, () => <ShiftAssignment>[])
          .add(assignment);
    }

    for (final window in timeWindows) {
      windowsByEmployee
          .putIfAbsent(window.employeeId, () => <EmployeeTimeWindow>[])
          .add(window);
    }

    for (final entry in byEmployee.entries) {
      final employeeAssignments = List<ShiftAssignment>.of(entry.value)
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
      final employeeWindows = windowsByEmployee[entry.key] ?? const [];

      _checkDuplicates(entry.key, employeeAssignments, violations);
      _checkOverlapsAndRest(entry.key, employeeAssignments, violations);
      _checkConsecutiveDays(entry.key, employeeAssignments, violations);
      _checkLeaveAndAvailability(
        entry.key,
        employeeAssignments,
        employeeWindows,
        violations,
      );
    }

    return RosterValidationResult(violations: List.unmodifiable(violations));
  }

  void _checkDuplicates(
    String employeeId,
    List<ShiftAssignment> assignments,
    List<RosterViolation> violations,
  ) {
    final seen = <String, ShiftAssignment>{};

    for (final assignment in assignments) {
      final key =
          '${assignment.startsAt.toIso8601String()}|'
          '${assignment.endsAt.toIso8601String()}|${assignment.shiftCode}';
      final existing = seen[key];

      if (existing != null) {
        violations.add(
          RosterViolation(
            code: RosterViolationCode.duplicateAssignment,
            severity: policy.duplicateAssignmentsAreErrors
                ? RosterViolationSeverity.error
                : RosterViolationSeverity.warning,
            message: 'Employee has duplicate assignments.',
            employeeId: employeeId,
            assignmentIds: [existing.id, assignment.id],
          ),
        );
      } else {
        seen[key] = assignment;
      }
    }
  }

  void _checkOverlapsAndRest(
    String employeeId,
    List<ShiftAssignment> assignments,
    List<RosterViolation> violations,
  ) {
    for (var index = 1; index < assignments.length; index++) {
      final previous = assignments[index - 1];
      final current = assignments[index];

      if (previous.overlaps(current)) {
        violations.add(
          RosterViolation(
            code: RosterViolationCode.overlappingAssignment,
            severity: RosterViolationSeverity.error,
            message: 'Employee has overlapping assignments.',
            employeeId: employeeId,
            assignmentIds: [previous.id, current.id],
          ),
        );
        continue;
      }

      final rest = current.startsAt.difference(previous.endsAt);
      if (rest < policy.minimumRest) {
        violations.add(
          RosterViolation(
            code: RosterViolationCode.insufficientRest,
            severity: RosterViolationSeverity.error,
            message: 'Employee does not have the minimum required rest.',
            employeeId: employeeId,
            assignmentIds: [previous.id, current.id],
          ),
        );
      }
    }
  }

  void _checkConsecutiveDays(
    String employeeId,
    List<ShiftAssignment> assignments,
    List<RosterViolation> violations,
  ) {
    final days =
        assignments
            .map(
              (assignment) => DateTime.utc(
                assignment.startsAt.year,
                assignment.startsAt.month,
                assignment.startsAt.day,
              ),
            )
            .toSet()
            .toList()
          ..sort();

    var consecutive = 1;
    for (var index = 1; index < days.length; index++) {
      final difference = days[index].difference(days[index - 1]).inDays;
      consecutive = difference == 1 ? consecutive + 1 : 1;

      if (consecutive > policy.maximumConsecutiveDays) {
        violations.add(
          RosterViolation(
            code: RosterViolationCode.maximumConsecutiveDays,
            severity: RosterViolationSeverity.warning,
            message: 'Employee exceeds the maximum consecutive work days.',
            employeeId: employeeId,
          ),
        );
        break;
      }
    }
  }

  void _checkLeaveAndAvailability(
    String employeeId,
    List<ShiftAssignment> assignments,
    List<EmployeeTimeWindow> windows,
    List<RosterViolation> violations,
  ) {
    final leaveWindows = windows
        .where((window) => window.kind == EmployeeTimeWindowKind.leave)
        .toList();
    final availabilityWindows = windows
        .where((window) => window.kind == EmployeeTimeWindowKind.availability)
        .toList();

    for (final assignment in assignments) {
      final conflictingLeave = leaveWindows.where(
        (window) => window.overlaps(assignment.startsAt, assignment.endsAt),
      );

      for (final leave in conflictingLeave) {
        violations.add(
          RosterViolation(
            code: RosterViolationCode.leaveConflict,
            severity: RosterViolationSeverity.error,
            message: 'Employee is assigned during approved leave.',
            employeeId: employeeId,
            assignmentIds: [assignment.id],
            relatedWindowIds: [leave.id],
          ),
        );
      }

      if (availabilityWindows.isNotEmpty &&
          !availabilityWindows.any(
            (window) => window.contains(assignment.startsAt, assignment.endsAt),
          )) {
        violations.add(
          RosterViolation(
            code: RosterViolationCode.outsideAvailability,
            severity: RosterViolationSeverity.error,
            message: 'Employee is assigned outside declared availability.',
            employeeId: employeeId,
            assignmentIds: [assignment.id],
          ),
        );
      }
    }
  }
}

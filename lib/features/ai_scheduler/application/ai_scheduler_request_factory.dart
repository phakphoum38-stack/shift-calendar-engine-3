import 'package:workforce_core/workforce_core.dart' as core;

import '../../../domain/entities/employee.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/entities/shift_template.dart';

final class AiSchedulerShiftInput {
  AiSchedulerShiftInput({
    required this.id,
    required DateTime date,
    required this.shift,
    this.departmentId = '',
    this.location = '',
  }) : date = DateTime(date.year, date.month, date.day);

  final String id;
  final DateTime date;
  final ShiftTemplate shift;
  final String departmentId;
  final String location;
}

/// Maps the app's canonical schedule data into workforce_core scheduler input.
///
/// This class performs boundary translation only. Scheduling decisions remain
/// inside workforce_core.
final class AiSchedulerRequestFactory {
  const AiSchedulerRequestFactory();

  core.SchedulerRequest build({
    required Iterable<Employee> employees,
    required Iterable<AiSchedulerShiftInput> requestedShifts,
    required Schedule schedule,
  }) {
    final employeeIds =
        employees
            .where((employee) => employee.active)
            .map((employee) => employee.id.trim())
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList(growable: false)
          ..sort();

    final slots = requestedShifts.map(_mapSlot).toList(growable: false)
      ..sort((left, right) => left.startsAt.compareTo(right.startsAt));

    final existingAssignments = <core.ShiftAssignment>[];
    for (final day in schedule.days) {
      for (final assignment in day.assignments) {
        final startsAt = _at(day.date, assignment.shift.startTime);
        final endDate = assignment.shift.overnight
            ? day.date.add(const Duration(days: 1))
            : day.date;
        final endsAt = _at(endDate, assignment.shift.endTime);

        existingAssignments.add(
          core.ShiftAssignment(
            id: assignment.id,
            employeeId: assignment.employee.id,
            shiftCode: assignment.shift.code,
            startsAt: startsAt,
            endsAt: endsAt,
            departmentId: assignment.employee.department.id,
            location: assignment.location ?? '',
          ),
        );
      }
    }
    existingAssignments.sort(
      (left, right) => left.startsAt.compareTo(right.startsAt),
    );

    return core.SchedulerRequest(
      employeeIds: employeeIds,
      slots: slots,
      existingAssignments: existingAssignments,
    );
  }

  core.SchedulerShiftSlot _mapSlot(AiSchedulerShiftInput input) {
    final startsAt = _at(input.date, input.shift.startTime);
    final endDate = input.shift.overnight
        ? input.date.add(const Duration(days: 1))
        : input.date;

    return core.SchedulerShiftSlot(
      id: input.id,
      shiftCode: input.shift.code,
      startsAt: startsAt,
      endsAt: _at(endDate, input.shift.endTime),
      departmentId: input.departmentId,
      location: input.location,
    );
  }

  DateTime _at(DateTime date, Duration time) {
    return DateTime(date.year, date.month, date.day).add(time);
  }
}

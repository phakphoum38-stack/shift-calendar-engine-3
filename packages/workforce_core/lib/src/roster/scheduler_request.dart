import 'employee_availability.dart';
import 'shift_assignment.dart';

final class SchedulerShiftSlot {
  SchedulerShiftSlot({
    required this.id,
    required this.shiftCode,
    required DateTime startsAt,
    required DateTime endsAt,
    this.departmentId = '',
    this.location = '',
  }) : startsAt = startsAt.toUtc(),
       endsAt = endsAt.toUtc() {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be empty');
    }
    if (shiftCode.trim().isEmpty) {
      throw ArgumentError.value(shiftCode, 'shiftCode', 'must not be empty');
    }
    if (!this.endsAt.isAfter(this.startsAt)) {
      throw ArgumentError('endsAt must be after startsAt');
    }
  }

  final String id;
  final String shiftCode;
  final DateTime startsAt;
  final DateTime endsAt;
  final String departmentId;
  final String location;

  ShiftAssignment assignTo(String employeeId) {
    return ShiftAssignment(
      id: 'auto:$id:$employeeId',
      employeeId: employeeId,
      shiftCode: shiftCode,
      startsAt: startsAt,
      endsAt: endsAt,
      departmentId: departmentId,
      location: location,
    );
  }
}

final class RosterSchedulerRequest {
  RosterSchedulerRequest({
    required Iterable<String> employeeIds,
    required Iterable<SchedulerShiftSlot> shifts,
    this.existingAssignments = const [],
    this.timeWindows = const [],
  }) : employeeIds = List.unmodifiable(
         employeeIds.map((value) => value.trim()).where((value) => value.isNotEmpty).toSet(),
       ),
       shifts = List.unmodifiable(shifts) {
    if (this.employeeIds.isEmpty) {
      throw ArgumentError('At least one employee is required.');
    }
  }

  final List<String> employeeIds;
  final List<SchedulerShiftSlot> shifts;
  final List<ShiftAssignment> existingAssignments;
  final List<EmployeeTimeWindow> timeWindows;
}

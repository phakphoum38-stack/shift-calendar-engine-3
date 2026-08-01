import '../roster/employee_availability.dart';

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
}

final class SchedulerRequest {
  SchedulerRequest({
    required Iterable<String> employeeIds,
    required Iterable<SchedulerShiftSlot> slots,
    this.timeWindows = const [],
  }) : employeeIds = List.unmodifiable(
         employeeIds.map((value) => value.trim()).where((value) => value.isNotEmpty),
       ),
       slots = List.unmodifiable(slots) {
    if (this.employeeIds.isEmpty) {
      throw ArgumentError('employeeIds must not be empty');
    }
    if (this.employeeIds.toSet().length != this.employeeIds.length) {
      throw ArgumentError('employeeIds must be unique');
    }
  }

  final List<String> employeeIds;
  final List<SchedulerShiftSlot> slots;
  final List<EmployeeTimeWindow> timeWindows;
}

import '../scheduler/scheduler_request.dart' as canonical;
import 'employee_availability.dart';
import 'shift_assignment.dart';

typedef SchedulerShiftSlot = canonical.SchedulerShiftSlot;

@Deprecated('Use SchedulerRequest from src/scheduler instead.')
final class RosterSchedulerRequest {
  RosterSchedulerRequest({
    required Iterable<String> employeeIds,
    required Iterable<SchedulerShiftSlot> shifts,
    this.existingAssignments = const [],
    this.timeWindows = const [],
  }) : employeeIds = List.unmodifiable(employeeIds),
       shifts = List.unmodifiable(shifts),
       existingAssignments = List.unmodifiable(existingAssignments),
       timeWindows = List.unmodifiable(timeWindows);

  final List<String> employeeIds;
  final List<SchedulerShiftSlot> shifts;
  final List<ShiftAssignment> existingAssignments;
  final List<EmployeeTimeWindow> timeWindows;

  canonical.SchedulerRequest toCanonical() {
    return canonical.SchedulerRequest(
      employeeIds: employeeIds,
      slots: shifts,
      existingAssignments: existingAssignments,
      timeWindows: timeWindows,
    );
  }
}

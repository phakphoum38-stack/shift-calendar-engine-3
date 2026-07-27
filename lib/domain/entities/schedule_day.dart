import 'shift_assignment.dart';

/// Immutable assignments and holiday metadata for one calendar date.
class ScheduleDay {
  ScheduleDay({
    required DateTime date,
    List<ShiftAssignment> assignments = const [],
    this.holidayName,
  }) : date = DateTime(date.year, date.month, date.day),
       assignments = List.unmodifiable(assignments);

  final DateTime date;
  final List<ShiftAssignment> assignments;
  final String? holidayName;

  ScheduleDay copyWith({
    DateTime? date,
    List<ShiftAssignment>? assignments,
    String? holidayName,
  }) {
    return ScheduleDay(
      date: date ?? this.date,
      assignments: assignments ?? this.assignments,
      holidayName: holidayName ?? this.holidayName,
    );
  }
}

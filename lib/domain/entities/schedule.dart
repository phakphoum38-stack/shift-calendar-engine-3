import 'schedule_month.dart';
import 'schedule_day.dart';
import 'shift_assignment.dart';

/// Canonical source of truth for all scheduling workflows.
class Schedule {
  Schedule({
    required this.id,
    required this.name,
    List<ScheduleMonth> months = const [],
  }) : months = List.unmodifiable(
         List<ScheduleMonth>.of(months)
           ..sort((a, b) => a.month.compareTo(b.month)),
       );

  final String id;
  final String name;
  final List<ScheduleMonth> months;

  ScheduleMonth? month(DateTime date) {
    for (final value in months) {
      if (value.month.year == date.year && value.month.month == date.month) {
        return value;
      }
    }
    return null;
  }

  Iterable<ScheduleDay> get days => months.expand((month) => month.days);

  Iterable<ShiftAssignment> get assignments =>
      days.expand((day) => day.assignments);

  Schedule replaceMonth(ScheduleMonth updatedMonth) {
    final exists = months.any(
      (month) =>
          month.month.year == updatedMonth.month.year &&
          month.month.month == updatedMonth.month.month,
    );
    return Schedule(
      id: id,
      name: name,
      months: [
        for (final month in months)
          if (month.month.year == updatedMonth.month.year &&
              month.month.month == updatedMonth.month.month)
            updatedMonth
          else
            month,
        if (!exists) updatedMonth,
      ],
    );
  }
}

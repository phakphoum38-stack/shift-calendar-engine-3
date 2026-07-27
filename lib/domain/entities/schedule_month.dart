import 'schedule_day.dart';

/// Chronologically ordered schedule days for one month.
class ScheduleMonth {
  ScheduleMonth({required DateTime month, List<ScheduleDay> days = const []})
    : month = DateTime(month.year, month.month),
      days = List.unmodifiable(
        List<ScheduleDay>.of(days)..sort((a, b) => a.date.compareTo(b.date)),
      );

  final DateTime month;
  final List<ScheduleDay> days;

  ScheduleDay? day(DateTime date) {
    for (final value in days) {
      if (value.date.year == date.year &&
          value.date.month == date.month &&
          value.date.day == date.day) {
        return value;
      }
    }
    return null;
  }
}

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

  ScheduleMonth replaceDay(ScheduleDay updatedDay) {
    final exists = days.any(
      (day) =>
          day.date.year == updatedDay.date.year &&
          day.date.month == updatedDay.date.month &&
          day.date.day == updatedDay.date.day,
    );
    return ScheduleMonth(
      month: month,
      days: [
        for (final day in days)
          if (day.date.year == updatedDay.date.year &&
              day.date.month == updatedDay.date.month &&
              day.date.day == updatedDay.date.day)
            updatedDay
          else
            day,
        if (!exists) updatedDay,
      ],
    );
  }
}

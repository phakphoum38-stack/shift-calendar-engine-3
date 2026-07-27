import 'package:flutter/foundation.dart';

import '../../../domain/entities/schedule.dart';
import '../../../domain/entities/schedule_month.dart';

/// Owns visible-month navigation for the canonical roster.
class RosterController extends ChangeNotifier {
  RosterController({required Schedule schedule, DateTime? initialMonth})
    : _schedule = schedule,
      _visibleMonth = DateTime(
        (initialMonth ?? schedule.months.firstOrNull?.month ?? DateTime.now())
            .year,
        (initialMonth ?? schedule.months.firstOrNull?.month ?? DateTime.now())
            .month,
      );

  Schedule _schedule;
  DateTime _visibleMonth;

  Schedule get schedule => _schedule;
  DateTime get visibleMonth => _visibleMonth;
  ScheduleMonth? get month => _schedule.month(_visibleMonth);

  void updateSchedule(Schedule schedule) {
    if (identical(schedule, _schedule)) return;
    _schedule = schedule;
    notifyListeners();
  }

  void previousMonth() {
    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    notifyListeners();
  }
}

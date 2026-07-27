import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/features/dashboard/application/dashboard_summary_service.dart';
import 'package:shift_calendar_engine/features/foundation/application/demo_schedule_factory.dart';

void main() {
  test('dashboard summary is derived without mutating schedule', () {
    final now = DateTime(2027, 4, 12, 10);
    final schedule = const DemoScheduleFactory().create(now);
    final before = schedule.assignments.toList();

    final summary = const DashboardSummaryService().build(schedule, now);

    expect(summary.todayAssignments, hasLength(1));
    expect(summary.tomorrowAssignments, isEmpty);
    expect(summary.monthlyAssignmentCount, 1);
    expect(summary.estimatedIncome, 600);
    expect(schedule.assignments, before);
  });
}

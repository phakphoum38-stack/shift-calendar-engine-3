import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/domain/entities/schedule.dart';
import 'package:shift_calendar_engine/domain/entities/schedule_day.dart';
import 'package:shift_calendar_engine/domain/entities/schedule_month.dart';
import 'package:shift_calendar_engine/domain/entities/shift_assignment.dart';
import 'package:shift_calendar_engine/features/reports/application/monthly_roster_report_mapper.dart';
import 'package:shift_calendar_engine/features/reports/domain/monthly_roster_report.dart';

import 'support/fixtures.dart';

void main() {
  const mapper = MonthlyRosterReportMapper();

  test('empty schedule produces a complete empty monthly model', () {
    final report = mapper.map(
      Schedule(id: 'empty', name: 'Empty'),
      MonthlyRosterReportOptions(
        month: DateTime(2027, 2),
        language: ReportLanguage.english,
      ),
    );

    expect(report.dates, hasLength(28));
    expect(report.rows, isEmpty);
    expect(report.legend, isEmpty);
    expect(report.statistics.employeeCount, 0);
    expect(report.statistics.assignmentCount, 0);
  });

  test('mapper preserves multiple assignments and orders values', () {
    final fixture = canonicalScheduleFixture();
    final first = fixture.assignments.first;
    final morning = first.shift.copyWith(id: 'morning', code: 'M');
    final expanded = Schedule(
      id: fixture.id,
      name: fixture.name,
      months: [
        ScheduleMonth(
          month: DateTime(2027, 4),
          days: [
            ScheduleDay(
              date: DateTime(2027, 4, 12),
              holidayName: 'Songkran',
              assignments: [
                first,
                ShiftAssignment(
                  id: 'assignment-2',
                  employee: first.employee,
                  shift: morning,
                  location: 'ER',
                  remark: 'ประชุม',
                ),
              ],
            ),
          ],
        ),
        ScheduleMonth(month: DateTime(2027, 5)),
      ],
    );
    final originalValues = scheduleValues(expanded);

    final report = mapper.map(
      expanded,
      MonthlyRosterReportOptions(
        month: DateTime(2027, 4),
        language: ReportLanguage.thai,
      ),
    );

    expect(report.rows, hasLength(1));
    expect(report.rows.single.cells[11].displayValue, 'M/N');
    expect(report.rows.single.cells[11].holidayName, 'Songkran');
    expect(report.rows.single.cells[11].locations, ['ER', 'CT']);
    expect(report.notes, containsAll(['Charge', 'ประชุม']));
    expect(report.legend.map((entry) => entry.code), ['M', 'N']);
    expect(report.statistics.assignmentCount, 2);
    expect(report.statistics.assignmentsByShift, {'M': 1, 'N': 1});
    expect(scheduleValues(expanded), originalValues);
  });

  test('department filter and month selection exclude unrelated data', () {
    final fixture = canonicalScheduleFixture();
    final report = mapper.map(
      fixture,
      MonthlyRosterReportOptions(
        month: DateTime(2027, 4),
        language: ReportLanguage.english,
        departmentId: 'other',
      ),
    );
    final absentMonth = mapper.map(
      fixture,
      MonthlyRosterReportOptions(
        month: DateTime(2027, 5),
        language: ReportLanguage.english,
      ),
    );

    expect(report.rows, isEmpty);
    expect(report.statistics.assignmentCount, 0);
    expect(absentMonth.rows, isEmpty);
    expect(absentMonth.dates, hasLength(31));
  });
}

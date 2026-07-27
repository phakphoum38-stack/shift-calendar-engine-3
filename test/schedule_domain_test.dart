import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/domain/entities/department.dart';
import 'package:shift_calendar_engine/domain/entities/employee.dart';
import 'package:shift_calendar_engine/domain/entities/schedule.dart';
import 'package:shift_calendar_engine/domain/entities/schedule_day.dart';
import 'package:shift_calendar_engine/domain/entities/schedule_month.dart';
import 'package:shift_calendar_engine/domain/entities/shift_assignment.dart';
import 'package:shift_calendar_engine/domain/entities/shift_template.dart';

void main() {
  test('canonical schedule orders months and exposes assignments', () {
    const department = Department(id: 'er', code: 'ER', name: 'Emergency');
    const employee = Employee(
      id: 'employee',
      employeeCode: 'E001',
      firstName: 'Anan',
      lastName: 'Sukjai',
      department: department,
      position: 'Nurse',
    );
    const shift = ShiftTemplate(
      id: 'night',
      code: 'N',
      name: 'Night',
      startTime: Duration(hours: 20),
      endTime: Duration(hours: 8),
      colorValue: 0xFF4527A0,
      workingHours: 12,
    );
    const assignment = ShiftAssignment(
      id: 'assignment',
      employee: employee,
      shift: shift,
    );
    final schedule = Schedule(
      id: 'schedule',
      name: 'Roster',
      months: [
        ScheduleMonth(month: DateTime(2027, 2)),
        ScheduleMonth(
          month: DateTime(2027, 1),
          days: [
            ScheduleDay(
              date: DateTime(2027, 1, 15),
              assignments: const [assignment],
            ),
          ],
        ),
      ],
    );

    expect(schedule.months.map((value) => value.month.month), [1, 2]);
    expect(schedule.assignments, [assignment]);
    expect(
      schedule.month(DateTime(2027, 1))!.day(DateTime(2027, 1, 15)),
      isNotNull,
    );
    expect(shift.overnight, isTrue);
  });
}

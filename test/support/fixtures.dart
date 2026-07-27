import 'package:shift_calendar_engine/domain/entities/department.dart';
import 'package:shift_calendar_engine/domain/entities/employee.dart';
import 'package:shift_calendar_engine/domain/entities/schedule.dart';
import 'package:shift_calendar_engine/domain/entities/schedule_day.dart';
import 'package:shift_calendar_engine/domain/entities/schedule_month.dart';
import 'package:shift_calendar_engine/domain/entities/shift_assignment.dart';
import 'package:shift_calendar_engine/domain/entities/shift_template.dart';

Schedule canonicalScheduleFixture() {
  const department = Department(
    id: 'radiology',
    code: 'RAD',
    name: 'Radiology',
  );
  const employee = Employee(
    id: 'employee-1',
    employeeCode: 'E001',
    firstName: 'สมชาย',
    lastName: 'ใจดี',
    nickname: 'ชาย',
    department: department,
    position: 'Technologist',
  );
  const shift = ShiftTemplate(
    id: 'night',
    code: 'N',
    name: 'Night',
    startTime: Duration(hours: 20),
    endTime: Duration(hours: 8),
    colorValue: 0xFF4527A0,
    workingHours: 12,
    rate: 900,
  );
  return Schedule(
    id: 'schedule-1',
    name: 'Canonical roster',
    months: [
      ScheduleMonth(
        month: DateTime(2027, 4),
        days: [
          ScheduleDay(
            date: DateTime(2027, 4, 12),
            assignments: const [
              ShiftAssignment(
                id: 'assignment-1',
                employee: employee,
                shift: shift,
                location: 'CT',
                remark: 'Charge',
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

List<Object?> scheduleValues(Schedule schedule) => [
  schedule.id,
  schedule.name,
  for (final month in schedule.months) ...[
    month.month,
    for (final day in month.days) ...[
      day.date,
      day.holidayName,
      for (final assignment in day.assignments) ...[
        assignment.id,
        assignment.employee.id,
        assignment.employee.employeeCode,
        assignment.employee.firstName,
        assignment.employee.lastName,
        assignment.employee.nickname,
        assignment.employee.department.id,
        assignment.employee.department.code,
        assignment.employee.department.name,
        assignment.employee.position,
        assignment.shift.id,
        assignment.shift.code,
        assignment.shift.name,
        assignment.shift.startTime,
        assignment.shift.endTime,
        assignment.shift.colorValue,
        assignment.shift.workingHours,
        assignment.shift.rate,
        assignment.location,
        assignment.remark,
        assignment.approved,
      ],
    ],
  ],
];

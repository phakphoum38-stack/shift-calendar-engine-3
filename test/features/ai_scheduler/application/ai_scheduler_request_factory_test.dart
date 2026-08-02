import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/domain/entities/department.dart';
import 'package:shift_calendar_engine/domain/entities/employee.dart';
import 'package:shift_calendar_engine/domain/entities/schedule.dart';
import 'package:shift_calendar_engine/domain/entities/schedule_day.dart';
import 'package:shift_calendar_engine/domain/entities/schedule_month.dart';
import 'package:shift_calendar_engine/domain/entities/shift_assignment.dart';
import 'package:shift_calendar_engine/domain/entities/shift_template.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/application/ai_scheduler_request_factory.dart';

void main() {
  const factory = AiSchedulerRequestFactory();
  const department = Department(id: 'dep-1', code: 'RAD', name: 'Radiology');
  const activeEmployee = Employee(
    id: 'e-2',
    employeeCode: '002',
    firstName: 'Active',
    lastName: 'Employee',
    department: department,
    position: 'Technologist',
  );
  const inactiveEmployee = Employee(
    id: 'e-1',
    employeeCode: '001',
    firstName: 'Inactive',
    lastName: 'Employee',
    department: department,
    position: 'Technologist',
    active: false,
  );
  const nightShift = ShiftTemplate(
    id: 'night',
    code: 'N',
    name: 'Night',
    startTime: Duration(hours: 20),
    endTime: Duration(hours: 8),
    colorValue: 0,
    workingHours: 12,
  );

  test('maps active employees, requested slots, and existing assignments', () {
    final schedule = Schedule(
      id: 'schedule',
      name: 'August',
      months: [
        ScheduleMonth(
          month: DateTime(2026, 8),
          days: [
            ScheduleDay(
              date: DateTime(2026, 8, 2),
              assignments: const [
                ShiftAssignment(
                  id: 'assignment-1',
                  employee: activeEmployee,
                  shift: nightShift,
                  location: 'CT',
                ),
              ],
            ),
          ],
        ),
      ],
    );

    final request = factory.build(
      employees: const [inactiveEmployee, activeEmployee, activeEmployee],
      requestedShifts: [
        AiSchedulerShiftInput(
          id: 'slot-1',
          date: DateTime(2026, 8, 3),
          shift: nightShift,
          departmentId: department.id,
          location: 'ER',
        ),
      ],
      schedule: schedule,
    );

    expect(request.employeeIds, ['e-2']);
    expect(request.slots.single.shiftCode, 'N');
    expect(request.slots.single.startsAt, DateTime.utc(2026, 8, 3, 20));
    expect(request.slots.single.endsAt, DateTime.utc(2026, 8, 4, 8));
    expect(request.existingAssignments.single.employeeId, 'e-2');
    expect(
      request.existingAssignments.single.startsAt,
      DateTime.utc(2026, 8, 2, 20),
    );
    expect(
      request.existingAssignments.single.endsAt,
      DateTime.utc(2026, 8, 3, 8),
    );
    expect(request.existingAssignments.single.location, 'CT');
  });
}

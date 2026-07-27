import '../../../domain/entities/department.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/entities/schedule_day.dart';
import '../../../domain/entities/schedule_month.dart';
import '../../../domain/entities/shift_assignment.dart';
import '../../../domain/entities/shift_template.dart';

/// Creates deterministic sample data only when Demo mode is explicitly active.
class DemoScheduleFactory {
  const DemoScheduleFactory();

  Schedule create(DateTime anchor) {
    const department = Department(
      id: 'demo-radiology',
      code: 'RAD',
      name: 'Radiology',
    );
    const employee = Employee(
      id: 'demo-employee',
      employeeCode: 'DEMO-001',
      firstName: 'Anan',
      lastName: 'Sukjai',
      nickname: 'Nan',
      department: department,
      position: 'Radiologic Technologist',
    );
    const morning = ShiftTemplate(
      id: 'demo-morning',
      code: 'M',
      name: 'Morning',
      startTime: Duration(hours: 8),
      endTime: Duration(hours: 16),
      colorValue: 0xFF039BE5,
      workingHours: 8,
      rate: 600,
    );
    final month = DateTime(anchor.year, anchor.month);
    final today = DateTime(anchor.year, anchor.month, anchor.day);
    return Schedule(
      id: 'demo',
      name: 'Demo roster',
      months: [
        ScheduleMonth(
          month: month,
          days: [
            ScheduleDay(
              date: today,
              assignments: const [
                ShiftAssignment(
                  id: 'demo-assignment',
                  employee: employee,
                  shift: morning,
                  location: 'CT',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

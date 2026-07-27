import '../../../domain/entities/employee.dart';
import '../../../domain/entities/schedule.dart';

/// Extracts a deterministic employee catalog from canonical assignments.
class EmployeeDirectoryService {
  const EmployeeDirectoryService();

  List<Employee> fromSchedule(Schedule schedule) {
    final byId = <String, Employee>{};
    for (final assignment in schedule.assignments) {
      byId[assignment.employee.id] = assignment.employee;
    }
    final result = byId.values.toList()
      ..sort((a, b) {
        final department = a.department.name.compareTo(b.department.name);
        if (department != 0) return department;
        final name = a.displayName.compareTo(b.displayName);
        return name != 0 ? name : a.id.compareTo(b.id);
      });
    return List.unmodifiable(result);
  }
}

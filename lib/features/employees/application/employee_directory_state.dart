import '../../../domain/entities/department.dart';
import '../../../domain/entities/employee.dart';

enum EmployeeStatusFilter { all, active, inactive }

enum EmployeeSort { nameAscending, nameDescending, employeeCode }

/// Immutable presentation state for the employee directory.
class EmployeeDirectoryState {
  const EmployeeDirectoryState({
    this.employees = const [],
    this.query = '',
    this.statusFilter = EmployeeStatusFilter.all,
    this.employeeSort = EmployeeSort.nameAscending,
    this.departmentId,
    this.loading = false,
    this.error,
  });

  final List<Employee> employees;
  final String query;
  final EmployeeStatusFilter statusFilter;
  final EmployeeSort employeeSort;
  final String? departmentId;
  final bool loading;
  final String? error;

  int get activeCount => employees.where((employee) => employee.active).length;

  List<Department> get departments {
    final values = <String, Department>{};
    for (final employee in employees) {
      final department = employee.department;
      if (department.id.isNotEmpty) values[department.id] = department;
    }
    final result = values.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return List.unmodifiable(result);
  }

  List<Employee> get visibleEmployees {
    final normalized = query.trim().toLowerCase();
    final result = employees.where((employee) {
      final matchesText =
          normalized.isEmpty ||
          employee.employeeCode.toLowerCase().contains(normalized) ||
          employee.displayName.toLowerCase().contains(normalized) ||
          employee.position.toLowerCase().contains(normalized);
      final matchesStatus = switch (statusFilter) {
        EmployeeStatusFilter.all => true,
        EmployeeStatusFilter.active => employee.active,
        EmployeeStatusFilter.inactive => !employee.active,
      };
      final matchesDepartment =
          departmentId == null || employee.department.id == departmentId;
      return matchesText && matchesStatus && matchesDepartment;
    }).toList();

    result.sort(
      (a, b) => switch (employeeSort) {
        EmployeeSort.nameAscending => a.displayName.toLowerCase().compareTo(
          b.displayName.toLowerCase(),
        ),
        EmployeeSort.nameDescending => b.displayName.toLowerCase().compareTo(
          a.displayName.toLowerCase(),
        ),
        EmployeeSort.employeeCode => a.employeeCode.toLowerCase().compareTo(
          b.employeeCode.toLowerCase(),
        ),
      },
    );
    return List.unmodifiable(result);
  }

  EmployeeDirectoryState copyWith({
    List<Employee>? employees,
    String? query,
    EmployeeStatusFilter? statusFilter,
    EmployeeSort? employeeSort,
    String? departmentId,
    bool clearDepartment = false,
    bool? loading,
    String? error,
    bool clearError = false,
  }) => EmployeeDirectoryState(
    employees: employees ?? this.employees,
    query: query ?? this.query,
    statusFilter: statusFilter ?? this.statusFilter,
    employeeSort: employeeSort ?? this.employeeSort,
    departmentId: clearDepartment ? null : departmentId ?? this.departmentId,
    loading: loading ?? this.loading,
    error: clearError ? null : error ?? this.error,
  );
}

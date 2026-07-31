import 'employee.dart';

final class EmployeeQuery {
  const EmployeeQuery({
    this.organizationId,
    this.departmentId,
    this.searchText,
    this.status,
    this.limit = 50,
    this.offset = 0,
  })  : assert(limit > 0),
        assert(offset >= 0);

  final String? organizationId;
  final String? departmentId;
  final String? searchText;
  final EmployeeStatus? status;
  final int limit;
  final int offset;
}

final class EmployeePage {
  const EmployeePage({required this.items, required this.total});

  final List<Employee> items;
  final int total;
}

abstract interface class EmployeeRepository {
  Future<Employee?> findById(String id);

  Future<EmployeePage> find(EmployeeQuery query);

  Future<Employee> save(Employee employee, {required int expectedVersion});

  Future<void> archive({
    required String id,
    required int expectedVersion,
    required DateTime archivedAt,
  });
}

import '../../core/result/result.dart';
import '../entities/employee.dart';

/// Read filters for the canonical employee directory.
class EmployeeQuery {
  const EmployeeQuery({
    this.text = '',
    this.organizationId = '',
    this.branchId = '',
    this.departmentId = '',
    this.teamId = '',
    this.activeOnly = true,
  });

  final String text;
  final String organizationId;
  final String branchId;
  final String departmentId;
  final String teamId;
  final bool activeOnly;
}

/// Persistence boundary for canonical employees.
abstract interface class EmployeeRepository {
  Future<Result<List<Employee>>> findAll({bool activeOnly = true});

  Future<Result<List<Employee>>> search(EmployeeQuery query);

  Future<Result<Employee?>> findById(String id);

  Future<Result<Employee>> save(Employee employee);

  Future<Result<void>> delete(String id);
}

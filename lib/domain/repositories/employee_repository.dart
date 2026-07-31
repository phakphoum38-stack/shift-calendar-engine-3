import '../../core/result/result.dart';
import '../entities/employee.dart';

/// Persistence boundary for canonical employees.
abstract interface class EmployeeRepository {
  Future<Result<List<Employee>>> findAll({bool activeOnly = true});

  Future<Result<Employee?>> findById(String id);

  Future<Result<Employee>> save(Employee employee);

  Future<Result<void>> delete(String id);
}

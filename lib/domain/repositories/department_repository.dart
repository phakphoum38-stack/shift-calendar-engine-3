import '../../core/result/result.dart';
import '../entities/department.dart';

/// Persistence boundary for departments.
abstract interface class DepartmentRepository {
  Future<Result<List<Department>>> findAll({
    String? organizationId,
    String? branchId,
    bool activeOnly = true,
  });

  Future<Result<Department?>> findById(String id);

  Future<Result<Department>> save(Department department);

  Future<Result<void>> delete(String id);
}

import '../../core/result/result.dart';
import '../entities/branch.dart';

/// Persistence boundary for organization branches or sites.
abstract interface class BranchRepository {
  Future<Result<List<Branch>>> findAll({
    String? organizationId,
    bool activeOnly = true,
  });

  Future<Result<Branch?>> findById(String id);

  Future<Result<Branch>> save(Branch branch);

  Future<Result<void>> delete(String id);
}

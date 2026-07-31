import '../../core/result/result.dart';
import '../entities/team.dart';

/// Persistence boundary for teams or operational units.
abstract interface class TeamRepository {
  Future<Result<List<Team>>> findAll({
    String? organizationId,
    String? branchId,
    String? departmentId,
    bool activeOnly = true,
  });

  Future<Result<Team?>> findById(String id);

  Future<Result<Team>> save(Team team);

  Future<Result<void>> delete(String id);
}

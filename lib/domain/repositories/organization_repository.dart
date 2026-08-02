import '../../core/result/result.dart';
import '../entities/organization.dart';

/// Persistence boundary for organizations.
abstract interface class OrganizationRepository {
  Future<Result<List<Organization>>> findAll({bool activeOnly = true});

  Future<Result<Organization?>> findById(String id);

  Future<Result<Organization>> save(Organization organization);

  Future<Result<void>> delete(String id);
}

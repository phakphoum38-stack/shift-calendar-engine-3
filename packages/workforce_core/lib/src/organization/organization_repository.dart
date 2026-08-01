import 'branch.dart';
import 'department.dart';
import 'organization.dart';
import 'team.dart';

final class OrganizationQuery {
  const OrganizationQuery({
    this.searchText,
    this.status,
    this.limit = 50,
    this.offset = 0,
  }) : assert(limit > 0),
       assert(offset >= 0);

  final String? searchText;
  final OrganizationStatus? status;
  final int limit;
  final int offset;
}

final class OrganizationPage {
  const OrganizationPage({required this.items, required this.total});

  final List<Organization> items;
  final int total;
}

abstract interface class OrganizationRepository {
  Future<Organization?> findById(String id);

  Future<OrganizationPage> find(OrganizationQuery query);

  Future<Organization> save(
    Organization organization, {
    required int expectedVersion,
  });

  Future<void> archive({
    required String id,
    required int expectedVersion,
    required DateTime archivedAt,
  });
}

abstract interface class BranchRepository {
  Future<List<Branch>> findByOrganization(String organizationId);

  Future<Branch?> findById(String id);

  Future<Branch> save(Branch branch, {required int expectedVersion});

  Future<void> delete(String id, {required int expectedVersion});
}

abstract interface class DepartmentRepository {
  Future<List<Department>> findByBranch(String branchId);

  Future<Department?> findById(String id);

  Future<Department> save(
    Department department, {
    required int expectedVersion,
  });

  Future<void> delete(String id, {required int expectedVersion});
}

abstract interface class TeamRepository {
  Future<List<Team>> findByDepartment(String departmentId);

  Future<Team?> findById(String id);

  Future<Team> save(Team team, {required int expectedVersion});

  Future<void> delete(String id, {required int expectedVersion});
}

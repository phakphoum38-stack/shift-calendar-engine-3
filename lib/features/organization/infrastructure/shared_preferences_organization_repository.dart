import 'package:workforce_core/workforce_core.dart';

import '../../../core/storage/atomic_string_store.dart';
import 'organization_hierarchy_codec.dart';

final class SharedPreferencesOrganizationRepository
    implements
        OrganizationRepository,
        BranchRepository,
        DepartmentRepository,
        TeamRepository {
  SharedPreferencesOrganizationRepository({
    AtomicStringStore? store,
    this.codec = const OrganizationHierarchyCodec(),
  }) : store = store ??
            AtomicStringStore(namespace: 'sce3.organization_hierarchy.v1');

  final AtomicStringStore store;
  final OrganizationHierarchyCodec codec;

  @override
  Future<Organization?> findById(String id) async {
    final snapshot = await _load();
    return snapshot.organizations
        .cast<Organization?>()
        .firstWhere((value) => value!.id == id, orElse: () => null);
  }

  @override
  Future<OrganizationPage> find(OrganizationQuery query) async {
    final snapshot = await _load();
    final text = query.searchText?.trim().toLowerCase() ?? '';
    final filtered = snapshot.organizations.where((value) {
      if (query.status != null && value.status != query.status) return false;
      if (text.isEmpty) return true;
      return value.code.toLowerCase().contains(text) ||
          value.name.toLowerCase().contains(text);
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final total = filtered.length;
    final start = query.offset.clamp(0, total);
    final end = (start + query.limit).clamp(start, total);
    return OrganizationPage(
      items: List.unmodifiable(filtered.sublist(start, end)),
      total: total,
    );
  }

  @override
  Future<Organization> save(
    Organization organization, {
    required int expectedVersion,
  }) async {
    final snapshot = await _load();
    final values = List<Organization>.of(snapshot.organizations);
    final index = values.indexWhere((value) => value.id == organization.id);
    _validateVersion(index == -1 ? null : values[index].version, expectedVersion);
    _validateUniqueCode(values, organization.id, organization.code);
    if (index == -1) {
      values.add(organization);
    } else {
      values[index] = organization;
    }
    await _save(snapshot, organizations: values);
    return organization;
  }

  @override
  Future<void> archive({
    required String id,
    required int expectedVersion,
    required DateTime archivedAt,
  }) async {
    final snapshot = await _load();
    final values = List<Organization>.of(snapshot.organizations);
    final index = values.indexWhere((value) => value.id == id);
    if (index == -1) throw StateError('Organization not found: $id');
    final current = values[index];
    _validateVersion(current.version, expectedVersion);
    values[index] = current.copyWith(
      status: OrganizationStatus.archived,
      version: current.version + 1,
      updatedAt: archivedAt,
      deletedAt: archivedAt,
    );
    await _save(snapshot, organizations: values);
  }

  @override
  Future<List<Branch>> findByOrganization(String organizationId) async {
    final snapshot = await _load();
    final values = snapshot.branches
        .where((value) => value.organizationId == organizationId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return List.unmodifiable(values);
  }

  @override
  Future<Branch> save(Branch branch, {required int expectedVersion}) async {
    final snapshot = await _load();
    final values = List<Branch>.of(snapshot.branches);
    final index = values.indexWhere((value) => value.id == branch.id);
    _validateVersion(index == -1 ? null : values[index].version, expectedVersion);
    final duplicate = values.any(
      (value) => value.id != branch.id &&
          value.organizationId == branch.organizationId &&
          value.code.toLowerCase() == branch.code.toLowerCase(),
    );
    if (duplicate) throw StateError('Branch code is already in use.');
    if (index == -1) {
      values.add(branch);
    } else {
      values[index] = branch;
    }
    await _save(snapshot, branches: values);
    return branch;
  }

  @override
  Future<List<Department>> findByBranch(String branchId) async {
    final snapshot = await _load();
    final values = snapshot.departments
        .where((value) => value.branchId == branchId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return List.unmodifiable(values);
  }

  @override
  Future<Department> save(
    Department department, {
    required int expectedVersion,
  }) async {
    final snapshot = await _load();
    final values = List<Department>.of(snapshot.departments);
    final index = values.indexWhere((value) => value.id == department.id);
    _validateVersion(index == -1 ? null : values[index].version, expectedVersion);
    final duplicate = values.any(
      (value) => value.id != department.id &&
          value.branchId == department.branchId &&
          value.code.toLowerCase() == department.code.toLowerCase(),
    );
    if (duplicate) throw StateError('Department code is already in use.');
    if (index == -1) {
      values.add(department);
    } else {
      values[index] = department;
    }
    await _save(snapshot, departments: values);
    return department;
  }

  @override
  Future<List<Team>> findByDepartment(String departmentId) async {
    final snapshot = await _load();
    final values = snapshot.teams
        .where((value) => value.departmentId == departmentId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return List.unmodifiable(values);
  }

  @override
  Future<Team> save(Team team, {required int expectedVersion}) async {
    final snapshot = await _load();
    final values = List<Team>.of(snapshot.teams);
    final index = values.indexWhere((value) => value.id == team.id);
    _validateVersion(index == -1 ? null : values[index].version, expectedVersion);
    final duplicate = values.any(
      (value) => value.id != team.id &&
          value.departmentId == team.departmentId &&
          value.code.toLowerCase() == team.code.toLowerCase(),
    );
    if (duplicate) throw StateError('Team code is already in use.');
    if (index == -1) {
      values.add(team);
    } else {
      values[index] = team;
    }
    await _save(snapshot, teams: values);
    return team;
  }

  @override
  Future<void> delete(String id, {required int expectedVersion}) async {
    final snapshot = await _load();
    if (snapshot.teams.any((value) => value.id == id)) {
      final values = List<Team>.of(snapshot.teams);
      final current = values.firstWhere((value) => value.id == id);
      _validateVersion(current.version, expectedVersion);
      values.removeWhere((value) => value.id == id);
      await _save(snapshot, teams: values);
      return;
    }
    if (snapshot.departments.any((value) => value.id == id)) {
      if (snapshot.teams.any((value) => value.departmentId == id)) {
        throw StateError('Department still contains teams.');
      }
      final values = List<Department>.of(snapshot.departments);
      final current = values.firstWhere((value) => value.id == id);
      _validateVersion(current.version, expectedVersion);
      values.removeWhere((value) => value.id == id);
      await _save(snapshot, departments: values);
      return;
    }
    if (snapshot.branches.any((value) => value.id == id)) {
      if (snapshot.departments.any((value) => value.branchId == id)) {
        throw StateError('Branch still contains departments.');
      }
      final values = List<Branch>.of(snapshot.branches);
      final current = values.firstWhere((value) => value.id == id);
      _validateVersion(current.version, expectedVersion);
      values.removeWhere((value) => value.id == id);
      await _save(snapshot, branches: values);
      return;
    }
    throw StateError('Organization hierarchy record not found: $id');
  }

  Future<OrganizationHierarchySnapshot> _load() async {
    final payload = await store.read();
    return payload == null
        ? const OrganizationHierarchySnapshot()
        : codec.decode(payload);
  }

  Future<void> _save(
    OrganizationHierarchySnapshot current, {
    List<Organization>? organizations,
    List<Branch>? branches,
    List<Department>? departments,
    List<Team>? teams,
  }) => store.write(
    codec.encode(
      OrganizationHierarchySnapshot(
        organizations: organizations ?? current.organizations,
        branches: branches ?? current.branches,
        departments: departments ?? current.departments,
        teams: teams ?? current.teams,
      ),
    ),
  );

  static void _validateVersion(int? actual, int expected) {
    if (actual == null) {
      if (expected != 0) {
        throw StateError('New records require expectedVersion 0.');
      }
      return;
    }
    if (actual != expected) {
      throw StateError('Version conflict: expected $expected, found $actual.');
    }
  }

  static void _validateUniqueCode(
    List<Organization> values,
    String id,
    String code,
  ) {
    final duplicate = values.any(
      (value) => value.id != id &&
          value.code.toLowerCase() == code.toLowerCase(),
    );
    if (duplicate) throw StateError('Organization code is already in use.');
  }
}

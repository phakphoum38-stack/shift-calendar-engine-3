import 'package:workforce_core/workforce_core.dart';

import 'organization_hierarchy_store.dart';

final class SharedPreferencesDepartmentRepository
    implements DepartmentRepository {
  SharedPreferencesDepartmentRepository({
    OrganizationHierarchyStore? hierarchyStore,
  }) : hierarchyStore = hierarchyStore ?? OrganizationHierarchyStore();

  final OrganizationHierarchyStore hierarchyStore;

  @override
  Future<List<Department>> findByBranch(String branchId) async {
    final snapshot = await hierarchyStore.load();

    final values =
        snapshot.departments
            .where(
              (department) =>
                  department.branchId == branchId &&
                  department.deletedAt == null,
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    return List.unmodifiable(values);
  }

  @override
  Future<Department?> findById(String id) async {
    final snapshot = await hierarchyStore.load();

    for (final department in snapshot.departments) {
      if (department.id == id) {
        return department;
      }
    }

    return null;
  }

  @override
  Future<Department> save(
    Department department, {
    required int expectedVersion,
  }) async {
    final snapshot = await hierarchyStore.load();

    final branchExists = snapshot.branches.any(
      (branch) =>
          branch.id == department.branchId &&
          branch.organizationId == department.organizationId &&
          branch.deletedAt == null,
    );

    if (!branchExists) {
      throw StateError('Branch not found.');
    }

    final values = List<Department>.of(snapshot.departments);

    final duplicateCode = values.any(
      (value) =>
          value.id != department.id &&
          value.branchId == department.branchId &&
          value.deletedAt == null &&
          value.code.toLowerCase() == department.code.toLowerCase(),
    );

    if (duplicateCode) {
      throw StateError('Department code is already in use.');
    }

    final index = values.indexWhere((value) => value.id == department.id);

    if (index == -1) {
      if (expectedVersion != 0) {
        throw StateError('Expected version must be 0 for a new department.');
      }

      values.add(department);
    } else {
      if (values[index].version != expectedVersion) {
        throw StateError('Department version conflict.');
      }

      values[index] = department;
    }

    await hierarchyStore.saveDepartments(snapshot, values);

    return department;
  }

  @override
  Future<void> delete(String id, {required int expectedVersion}) async {
    final snapshot = await hierarchyStore.load();

    final hasTeams = snapshot.teams.any(
      (team) => team.departmentId == id && team.deletedAt == null,
    );

    if (hasTeams) {
      throw StateError('Cannot delete a department that contains teams.');
    }

    final values = List<Department>.of(snapshot.departments);
    final index = values.indexWhere((value) => value.id == id);

    if (index == -1) {
      throw StateError('Department not found.');
    }

    if (values[index].version != expectedVersion) {
      throw StateError('Department version conflict.');
    }

    values.removeAt(index);

    await hierarchyStore.saveDepartments(snapshot, values);
  }
}

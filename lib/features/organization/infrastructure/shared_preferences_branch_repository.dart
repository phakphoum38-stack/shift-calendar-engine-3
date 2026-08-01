import 'package:workforce_core/workforce_core.dart';

import 'organization_hierarchy_store.dart';

final class SharedPreferencesBranchRepository implements BranchRepository {
  SharedPreferencesBranchRepository({
    OrganizationHierarchyStore? hierarchyStore,
  }) : hierarchyStore = hierarchyStore ?? OrganizationHierarchyStore();

  final OrganizationHierarchyStore hierarchyStore;

  @override
  Future<List<Branch>> findByOrganization(String organizationId) async {
    final snapshot = await hierarchyStore.load();

    final values =
        snapshot.branches
            .where(
              (branch) =>
                  branch.organizationId == organizationId &&
                  branch.deletedAt == null,
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    return List.unmodifiable(values);
  }

  @override
  Future<Branch?> findById(String id) async {
    final snapshot = await hierarchyStore.load();

    for (final branch in snapshot.branches) {
      if (branch.id == id) {
        return branch;
      }
    }

    return null;
  }

  @override
  Future<Branch> save(Branch branch, {required int expectedVersion}) async {
    final snapshot = await hierarchyStore.load();

    final organizationExists = snapshot.organizations.any(
      (organization) =>
          organization.id == branch.organizationId &&
          organization.deletedAt == null,
    );

    if (!organizationExists) {
      throw StateError('Organization not found.');
    }

    final values = List<Branch>.of(snapshot.branches);

    final duplicateCode = values.any(
      (value) =>
          value.id != branch.id &&
          value.organizationId == branch.organizationId &&
          value.deletedAt == null &&
          value.code.toLowerCase() == branch.code.toLowerCase(),
    );

    if (duplicateCode) {
      throw StateError('Branch code is already in use.');
    }

    final index = values.indexWhere((value) => value.id == branch.id);

    if (index == -1) {
      if (expectedVersion != 0) {
        throw StateError('Expected version must be 0 for a new branch.');
      }

      values.add(branch);
    } else {
      if (values[index].version != expectedVersion) {
        throw StateError('Branch version conflict.');
      }

      values[index] = branch;
    }

    await hierarchyStore.saveBranches(snapshot, values);

    return branch;
  }

  @override
  Future<void> delete(String id, {required int expectedVersion}) async {
    final snapshot = await hierarchyStore.load();

    final hasDepartments = snapshot.departments.any(
      (department) => department.branchId == id && department.deletedAt == null,
    );

    if (hasDepartments) {
      throw StateError('Cannot delete a branch that contains departments.');
    }

    final values = List<Branch>.of(snapshot.branches);
    final index = values.indexWhere((value) => value.id == id);

    if (index == -1) {
      throw StateError('Branch not found.');
    }

    if (values[index].version != expectedVersion) {
      throw StateError('Branch version conflict.');
    }

    values.removeAt(index);

    await hierarchyStore.saveBranches(snapshot, values);
  }
}

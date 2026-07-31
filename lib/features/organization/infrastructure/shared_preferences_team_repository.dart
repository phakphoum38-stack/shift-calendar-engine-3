import 'package:workforce_core/workforce_core.dart';

import 'organization_hierarchy_store.dart';

final class SharedPreferencesTeamRepository implements TeamRepository {
  SharedPreferencesTeamRepository({OrganizationHierarchyStore? hierarchyStore})
    : hierarchyStore = hierarchyStore ?? OrganizationHierarchyStore();

  final OrganizationHierarchyStore hierarchyStore;

  @override
  Future<List<Team>> findByDepartment(String departmentId) async {
    final snapshot = await hierarchyStore.load();

    final values =
        snapshot.teams
            .where(
              (team) =>
                  team.departmentId == departmentId && team.deletedAt == null,
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    return List.unmodifiable(values);
  }

  @override
  Future<Team?> findById(String id) async {
    final snapshot = await hierarchyStore.load();

    for (final team in snapshot.teams) {
      if (team.id == id) {
        return team;
      }
    }

    return null;
  }

  @override
  Future<Team> save(Team team, {required int expectedVersion}) async {
    final snapshot = await hierarchyStore.load();

    final departmentExists = snapshot.departments.any(
      (department) =>
          department.id == team.departmentId &&
          department.branchId == team.branchId &&
          department.organizationId == team.organizationId &&
          department.deletedAt == null,
    );

    if (!departmentExists) {
      throw StateError('Department not found.');
    }

    final values = List<Team>.of(snapshot.teams);

    final duplicateCode = values.any(
      (value) =>
          value.id != team.id &&
          value.departmentId == team.departmentId &&
          value.deletedAt == null &&
          value.code.toLowerCase() == team.code.toLowerCase(),
    );

    if (duplicateCode) {
      throw StateError('Team code is already in use.');
    }

    final index = values.indexWhere((value) => value.id == team.id);

    if (index == -1) {
      if (expectedVersion != 0) {
        throw StateError('Expected version must be 0 for a new team.');
      }

      values.add(team);
    } else {
      if (values[index].version != expectedVersion) {
        throw StateError('Team version conflict.');
      }

      values[index] = team;
    }

    await hierarchyStore.saveTeams(snapshot, values);

    return team;
  }

  @override
  Future<void> delete(String id, {required int expectedVersion}) async {
    final snapshot = await hierarchyStore.load();
    final values = List<Team>.of(snapshot.teams);
    final index = values.indexWhere((value) => value.id == id);

    if (index == -1) {
      throw StateError('Team not found.');
    }

    if (values[index].version != expectedVersion) {
      throw StateError('Team version conflict.');
    }

    values.removeAt(index);

    await hierarchyStore.saveTeams(snapshot, values);
  }
}

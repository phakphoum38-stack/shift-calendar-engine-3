import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/features/organization/application/organization_management_controller.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  final createdAt = DateTime.utc(2026, 1, 1);

  Organization organization(String id, String code, String name) => Organization(
        id: id,
        code: code,
        name: name,
        status: OrganizationStatus.active,
        version: 1,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

  Branch branch(String id, String organizationId, String code, String name) =>
      Branch(
        id: id,
        organizationId: organizationId,
        code: code,
        name: name,
        version: 1,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

  Department department(
    String id,
    String organizationId,
    String branchId,
    String code,
    String name,
  ) =>
      Department(
        id: id,
        organizationId: organizationId,
        branchId: branchId,
        code: code,
        name: name,
        version: 1,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

  Team team(
    String id,
    String organizationId,
    String branchId,
    String departmentId,
    String code,
    String name,
  ) =>
      Team(
        id: id,
        organizationId: organizationId,
        branchId: branchId,
        departmentId: departmentId,
        code: code,
        name: name,
        version: 1,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

  test('loads organizations and walks the hierarchy selection', () async {
    final org = organization('org-1', 'HOSP', 'Hospital');
    final site = branch('branch-1', org.id, 'MAIN', 'Main branch');
    final unit = department('department-1', org.id, site.id, 'RAD', 'Radiology');
    final group = team('team-1', org.id, site.id, unit.id, 'CT', 'CT Team');

    final controller = OrganizationManagementController(
      organizationRepository: _OrganizationRepository([org]),
      branchRepository: _BranchRepository([site]),
      departmentRepository: _DepartmentRepository([unit]),
      teamRepository: _TeamRepository([group]),
    );

    await controller.load();
    expect(controller.state.organizations, [org]);
    expect(controller.state.selectedOrganization, isNull);

    await controller.selectOrganization(org);
    expect(controller.state.selectedOrganization, org);
    expect(controller.state.branches, [site]);

    await controller.selectBranch(site);
    expect(controller.state.selectedBranch, site);
    expect(controller.state.departments, [unit]);

    await controller.selectDepartment(unit);
    expect(controller.state.selectedDepartment, unit);
    expect(controller.state.teams, [group]);

    controller.selectTeam(group);
    expect(controller.state.selectedTeam, group);
  });

  test('changing organization clears lower selections', () async {
    final first = organization('org-1', 'ONE', 'One');
    final second = organization('org-2', 'TWO', 'Two');
    final site = branch('branch-1', first.id, 'MAIN', 'Main');
    final unit = department('department-1', first.id, site.id, 'RAD', 'Radiology');
    final group = team('team-1', first.id, site.id, unit.id, 'CT', 'CT');

    final controller = OrganizationManagementController(
      organizationRepository: _OrganizationRepository([first, second]),
      branchRepository: _BranchRepository([site]),
      departmentRepository: _DepartmentRepository([unit]),
      teamRepository: _TeamRepository([group]),
    );

    await controller.load();
    await controller.selectOrganization(first);
    await controller.selectBranch(site);
    await controller.selectDepartment(unit);
    controller.selectTeam(group);

    await controller.selectOrganization(second);

    expect(controller.state.selectedOrganization, second);
    expect(controller.state.selectedBranch, isNull);
    expect(controller.state.selectedDepartment, isNull);
    expect(controller.state.selectedTeam, isNull);
    expect(controller.state.branches, isEmpty);
    expect(controller.state.departments, isEmpty);
    expect(controller.state.teams, isEmpty);
  });

  test('save organization refreshes and selects saved item', () async {
    final repository = _OrganizationRepository([]);
    final controller = OrganizationManagementController(
      organizationRepository: repository,
      branchRepository: _BranchRepository([]),
      departmentRepository: _DepartmentRepository([]),
      teamRepository: _TeamRepository([]),
    );
    final saved = organization('org-1', 'HOSP', 'Hospital');

    await controller.load();
    await controller.saveOrganization(saved, expectedVersion: 0);

    expect(repository.items, [saved]);
    expect(controller.state.organizations, [saved]);
    expect(controller.state.selectedOrganization, saved);
    expect(controller.state.errorMessage, isNull);
  });

  test('repository failures are exposed in state', () async {
    final controller = OrganizationManagementController(
      organizationRepository: _OrganizationRepository([], failFind: true),
      branchRepository: _BranchRepository([]),
      departmentRepository: _DepartmentRepository([]),
      teamRepository: _TeamRepository([]),
    );

    await controller.load();

    expect(controller.state.loading, isFalse);
    expect(controller.state.errorMessage, contains('find failed'));
  });
}

final class _OrganizationRepository implements OrganizationRepository {
  _OrganizationRepository(List<Organization> values, {this.failFind = false})
      : items = List.of(values);

  final List<Organization> items;
  final bool failFind;

  @override
  Future<Organization?> findById(String id) async =>
      items.cast<Organization?>().firstWhere(
            (value) => value?.id == id,
            orElse: () => null,
          );

  @override
  Future<OrganizationPage> find(OrganizationQuery query) async {
    if (failFind) {
      throw StateError('find failed');
    }
    return OrganizationPage(items: List.unmodifiable(items), total: items.length);
  }

  @override
  Future<Organization> save(
    Organization organization, {
    required int expectedVersion,
  }) async {
    final index = items.indexWhere((value) => value.id == organization.id);
    if (index == -1) {
      items.add(organization);
    } else {
      items[index] = organization;
    }
    return organization;
  }

  @override
  Future<void> archive({
    required String id,
    required int expectedVersion,
    required DateTime archivedAt,
  }) async {
    items.removeWhere((value) => value.id == id);
  }
}

final class _BranchRepository implements BranchRepository {
  _BranchRepository(List<Branch> values) : items = List.of(values);

  final List<Branch> items;

  @override
  Future<List<Branch>> findByOrganization(String organizationId) async =>
      List.unmodifiable(
        items.where((value) => value.organizationId == organizationId),
      );

  @override
  Future<Branch?> findById(String id) async => items.cast<Branch?>().firstWhere(
        (value) => value?.id == id,
        orElse: () => null,
      );

  @override
  Future<Branch> save(Branch branch, {required int expectedVersion}) async {
    final index = items.indexWhere((value) => value.id == branch.id);
    if (index == -1) {
      items.add(branch);
    } else {
      items[index] = branch;
    }
    return branch;
  }

  @override
  Future<void> delete(String id, {required int expectedVersion}) async {
    items.removeWhere((value) => value.id == id);
  }
}

final class _DepartmentRepository implements DepartmentRepository {
  _DepartmentRepository(List<Department> values) : items = List.of(values);

  final List<Department> items;

  @override
  Future<List<Department>> findByBranch(String branchId) async =>
      List.unmodifiable(items.where((value) => value.branchId == branchId));

  @override
  Future<Department?> findById(String id) async =>
      items.cast<Department?>().firstWhere(
            (value) => value?.id == id,
            orElse: () => null,
          );

  @override
  Future<Department> save(
    Department department, {
    required int expectedVersion,
  }) async {
    final index = items.indexWhere((value) => value.id == department.id);
    if (index == -1) {
      items.add(department);
    } else {
      items[index] = department;
    }
    return department;
  }

  @override
  Future<void> delete(String id, {required int expectedVersion}) async {
    items.removeWhere((value) => value.id == id);
  }
}

final class _TeamRepository implements TeamRepository {
  _TeamRepository(List<Team> values) : items = List.of(values);

  final List<Team> items;

  @override
  Future<List<Team>> findByDepartment(String departmentId) async =>
      List.unmodifiable(
        items.where((value) => value.departmentId == departmentId),
      );

  @override
  Future<Team?> findById(String id) async => items.cast<Team?>().firstWhere(
        (value) => value?.id == id,
        orElse: () => null,
      );

  @override
  Future<Team> save(Team team, {required int expectedVersion}) async {
    final index = items.indexWhere((value) => value.id == team.id);
    if (index == -1) {
      items.add(team);
    } else {
      items[index] = team;
    }
    return team;
  }

  @override
  Future<void> delete(String id, {required int expectedVersion}) async {
    items.removeWhere((value) => value.id == id);
  }
}

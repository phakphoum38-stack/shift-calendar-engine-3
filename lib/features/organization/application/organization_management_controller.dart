import 'package:flutter/foundation.dart';
import 'package:workforce_core/workforce_core.dart';

import 'organization_management_state.dart';

final class OrganizationManagementController extends ChangeNotifier {
  OrganizationManagementController({
    required this.organizationRepository,
    required this.branchRepository,
    required this.departmentRepository,
    required this.teamRepository,
  });

  final OrganizationRepository organizationRepository;
  final BranchRepository branchRepository;
  final DepartmentRepository departmentRepository;
  final TeamRepository teamRepository;

  OrganizationManagementState _state = const OrganizationManagementState();

  OrganizationManagementState get state => _state;

  Future<void> load() async {
    await _run(() async {
      final page = await organizationRepository.find(
        const OrganizationQuery(limit: 500),
      );
      _state = _state.copyWith(
        organizations: page.items,
        branches: const [],
        departments: const [],
        teams: const [],
        clearOrganization: true,
        clearBranch: true,
        clearDepartment: true,
        clearTeam: true,
      );
    });
  }

  Future<void> refresh() async {
    final organization = _state.selectedOrganization;
    final branch = _state.selectedBranch;
    final department = _state.selectedDepartment;

    await load();

    if (organization != null) {
      await selectOrganization(
        _state.organizations.cast<Organization?>().firstWhere(
          (value) => value?.id == organization.id,
          orElse: () => null,
        ),
      );
    }
    if (branch != null) {
      await selectBranch(
        _state.branches.cast<Branch?>().firstWhere(
          (value) => value?.id == branch.id,
          orElse: () => null,
        ),
      );
    }
    if (department != null) {
      await selectDepartment(
        _state.departments.cast<Department?>().firstWhere(
          (value) => value?.id == department.id,
          orElse: () => null,
        ),
      );
    }
  }

  Future<void> selectOrganization(Organization? organization) async {
    if (organization == null) {
      _state = _state.copyWith(
        branches: const [],
        departments: const [],
        teams: const [],
        clearOrganization: true,
        clearBranch: true,
        clearDepartment: true,
        clearTeam: true,
      );
      notifyListeners();
      return;
    }

    await _run(() async {
      final branches = await branchRepository.findByOrganization(
        organization.id,
      );
      _state = _state.copyWith(
        selectedOrganization: organization,
        branches: branches,
        departments: const [],
        teams: const [],
        clearBranch: true,
        clearDepartment: true,
        clearTeam: true,
      );
    });
  }

  Future<void> selectBranch(Branch? branch) async {
    if (branch == null) {
      _state = _state.copyWith(
        departments: const [],
        teams: const [],
        clearBranch: true,
        clearDepartment: true,
        clearTeam: true,
      );
      notifyListeners();
      return;
    }

    await _run(() async {
      final departments = await departmentRepository.findByBranch(branch.id);
      _state = _state.copyWith(
        selectedBranch: branch,
        departments: departments,
        teams: const [],
        clearDepartment: true,
        clearTeam: true,
      );
    });
  }

  Future<void> selectDepartment(Department? department) async {
    if (department == null) {
      _state = _state.copyWith(
        teams: const [],
        clearDepartment: true,
        clearTeam: true,
      );
      notifyListeners();
      return;
    }

    await _run(() async {
      final teams = await teamRepository.findByDepartment(department.id);
      _state = _state.copyWith(
        selectedDepartment: department,
        teams: teams,
        clearTeam: true,
      );
    });
  }

  void selectTeam(Team? team) {
    _state = team == null
        ? _state.copyWith(clearTeam: true)
        : _state.copyWith(selectedTeam: team);
    notifyListeners();
  }

  Future<void> saveOrganization(
    Organization organization, {
    required int expectedVersion,
  }) async {
    await _run(() async {
      await organizationRepository.save(
        organization,
        expectedVersion: expectedVersion,
      );
      await _reloadOrganizations(selectedId: organization.id);
    });
  }

  Future<void> archiveOrganization({
    required String id,
    required int expectedVersion,
    required DateTime archivedAt,
  }) async {
    await _run(() async {
      await organizationRepository.archive(
        id: id,
        expectedVersion: expectedVersion,
        archivedAt: archivedAt,
      );
      await _reloadOrganizations();
    });
  }

  Future<void> saveBranch(Branch branch, {required int expectedVersion}) async {
    await _run(() async {
      await branchRepository.save(branch, expectedVersion: expectedVersion);
      await _reloadBranches(selectedId: branch.id);
    });
  }

  Future<void> deleteBranch(String id, {required int expectedVersion}) async {
    await _run(() async {
      await branchRepository.delete(id, expectedVersion: expectedVersion);
      await _reloadBranches();
    });
  }

  Future<void> saveDepartment(
    Department department, {
    required int expectedVersion,
  }) async {
    await _run(() async {
      await departmentRepository.save(
        department,
        expectedVersion: expectedVersion,
      );
      await _reloadDepartments(selectedId: department.id);
    });
  }

  Future<void> deleteDepartment(
    String id, {
    required int expectedVersion,
  }) async {
    await _run(() async {
      await departmentRepository.delete(id, expectedVersion: expectedVersion);
      await _reloadDepartments();
    });
  }

  Future<void> saveTeam(Team team, {required int expectedVersion}) async {
    await _run(() async {
      await teamRepository.save(team, expectedVersion: expectedVersion);
      await _reloadTeams(selectedId: team.id);
    });
  }

  Future<void> deleteTeam(String id, {required int expectedVersion}) async {
    await _run(() async {
      await teamRepository.delete(id, expectedVersion: expectedVersion);
      await _reloadTeams();
    });
  }

  Future<void> _reloadOrganizations({String? selectedId}) async {
    final page = await organizationRepository.find(
      const OrganizationQuery(limit: 500),
    );
    Organization? selected;
    if (selectedId != null) {
      selected = page.items.cast<Organization?>().firstWhere(
        (value) => value?.id == selectedId,
        orElse: () => null,
      );
    }
    _state = _state.copyWith(
      organizations: page.items,
      selectedOrganization: selected,
      clearOrganization: selected == null,
      branches: selected == null ? const [] : _state.branches,
      departments: selected == null ? const [] : _state.departments,
      teams: selected == null ? const [] : _state.teams,
      clearBranch: selected == null,
      clearDepartment: selected == null,
      clearTeam: selected == null,
    );
  }

  Future<void> _reloadBranches({String? selectedId}) async {
    final organization = _state.selectedOrganization;
    if (organization == null) return;
    final branches = await branchRepository.findByOrganization(organization.id);
    Branch? selected;
    if (selectedId != null) {
      selected = branches.cast<Branch?>().firstWhere(
        (value) => value?.id == selectedId,
        orElse: () => null,
      );
    }
    _state = _state.copyWith(
      branches: branches,
      selectedBranch: selected,
      clearBranch: selected == null,
      departments: selected == null ? const [] : _state.departments,
      teams: selected == null ? const [] : _state.teams,
      clearDepartment: selected == null,
      clearTeam: selected == null,
    );
  }

  Future<void> _reloadDepartments({String? selectedId}) async {
    final branch = _state.selectedBranch;
    if (branch == null) return;
    final departments = await departmentRepository.findByBranch(branch.id);
    Department? selected;
    if (selectedId != null) {
      selected = departments.cast<Department?>().firstWhere(
        (value) => value?.id == selectedId,
        orElse: () => null,
      );
    }
    _state = _state.copyWith(
      departments: departments,
      selectedDepartment: selected,
      clearDepartment: selected == null,
      teams: selected == null ? const [] : _state.teams,
      clearTeam: selected == null,
    );
  }

  Future<void> _reloadTeams({String? selectedId}) async {
    final department = _state.selectedDepartment;
    if (department == null) return;
    final teams = await teamRepository.findByDepartment(department.id);
    Team? selected;
    if (selectedId != null) {
      selected = teams.cast<Team?>().firstWhere(
        (value) => value?.id == selectedId,
        orElse: () => null,
      );
    }
    _state = _state.copyWith(
      teams: teams,
      selectedTeam: selected,
      clearTeam: selected == null,
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    _state = _state.copyWith(loading: true, clearError: true);
    notifyListeners();

    try {
      await action();
      _state = _state.copyWith(loading: false, clearError: true);
    } on Object catch (error) {
      _state = _state.copyWith(loading: false, errorMessage: error.toString());
    }

    notifyListeners();
  }
}

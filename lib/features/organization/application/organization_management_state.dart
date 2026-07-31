import 'package:workforce_core/workforce_core.dart';

final class OrganizationManagementState {
  const OrganizationManagementState({
    this.loading = false,
    this.errorMessage,
    this.organizations = const [],
    this.branches = const [],
    this.departments = const [],
    this.teams = const [],
    this.selectedOrganization,
    this.selectedBranch,
    this.selectedDepartment,
    this.selectedTeam,
  });

  final bool loading;
  final String? errorMessage;
  final List<Organization> organizations;
  final List<Branch> branches;
  final List<Department> departments;
  final List<Team> teams;
  final Organization? selectedOrganization;
  final Branch? selectedBranch;
  final Department? selectedDepartment;
  final Team? selectedTeam;

  OrganizationManagementState copyWith({
    bool? loading,
    String? errorMessage,
    List<Organization>? organizations,
    List<Branch>? branches,
    List<Department>? departments,
    List<Team>? teams,
    Organization? selectedOrganization,
    Branch? selectedBranch,
    Department? selectedDepartment,
    Team? selectedTeam,
    bool clearError = false,
    bool clearOrganization = false,
    bool clearBranch = false,
    bool clearDepartment = false,
    bool clearTeam = false,
  }) {
    return OrganizationManagementState(
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      organizations: organizations ?? this.organizations,
      branches: branches ?? this.branches,
      departments: departments ?? this.departments,
      teams: teams ?? this.teams,
      selectedOrganization: clearOrganization
          ? null
          : selectedOrganization ?? this.selectedOrganization,
      selectedBranch: clearBranch
          ? null
          : selectedBranch ?? this.selectedBranch,
      selectedDepartment: clearDepartment
          ? null
          : selectedDepartment ?? this.selectedDepartment,
      selectedTeam: clearTeam ? null : selectedTeam ?? this.selectedTeam,
    );
  }
}

import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/repositories/branch_repository.dart';
import '../../../domain/repositories/department_repository.dart';
import '../../../domain/repositories/organization_repository.dart';
import '../../../domain/repositories/team_repository.dart';
import 'organization_storage_migrator.dart';
import 'shared_preferences_json_collection.dart';
import 'shared_preferences_organization_repositories.dart';

/// Production-ready local repository group sharing one preferences instance.
final class OrganizationRepositoryBundle {
  const OrganizationRepositoryBundle({
    required this.organizations,
    required this.branches,
    required this.departments,
    required this.teams,
  });

  final OrganizationRepository organizations;
  final BranchRepository branches;
  final DepartmentRepository departments;
  final TeamRepository teams;

  static Future<OrganizationRepositoryBundle> createLocal({
    OrganizationStorageMigrator migrator = const OrganizationStorageMigrator(),
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await migrator.migrate(preferences);

    final organizationStore = SharedPreferencesJsonCollection(
      preferences: preferences,
      key: 'sce.enterprise.organizations.v1',
    );
    final branchStore = SharedPreferencesJsonCollection(
      preferences: preferences,
      key: 'sce.enterprise.branches.v1',
    );
    final departmentStore = SharedPreferencesJsonCollection(
      preferences: preferences,
      key: 'sce.enterprise.departments.v1',
    );
    final teamStore = SharedPreferencesJsonCollection(
      preferences: preferences,
      key: 'sce.enterprise.teams.v1',
    );

    return OrganizationRepositoryBundle(
      organizations:
          SharedPreferencesOrganizationRepository(organizationStore),
      branches: SharedPreferencesBranchRepository(branchStore),
      departments: SharedPreferencesDepartmentRepository(departmentStore),
      teams: SharedPreferencesTeamRepository(
        teamStore: teamStore,
        departmentStore: departmentStore,
      ),
    );
  }
}

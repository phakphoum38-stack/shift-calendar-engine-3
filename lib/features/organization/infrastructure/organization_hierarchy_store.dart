import 'package:workforce_core/workforce_core.dart';

import '../../../core/storage/atomic_string_store.dart';
import 'organization_hierarchy_codec.dart';

final class OrganizationHierarchyStore {
  OrganizationHierarchyStore({
    AtomicStringStore? store,
    this.codec = const OrganizationHierarchyCodec(),
  }) : store =
           store ??
           AtomicStringStore(namespace: 'sce3.organization_hierarchy.v1');

  final AtomicStringStore store;
  final OrganizationHierarchyCodec codec;

  Future<OrganizationHierarchySnapshot> load() async {
    final payload = await store.read();

    if (payload == null) {
      return const OrganizationHierarchySnapshot();
    }

    return codec.decode(payload);
  }

  Future<void> save(OrganizationHierarchySnapshot snapshot) async {
    await store.write(codec.encode(snapshot));
  }

  Future<void> saveOrganizations(
    OrganizationHierarchySnapshot current,
    List<Organization> organizations,
  ) {
    return save(
      OrganizationHierarchySnapshot(
        organizations: List.unmodifiable(organizations),
        branches: current.branches,
        departments: current.departments,
        teams: current.teams,
      ),
    );
  }

  Future<void> saveBranches(
    OrganizationHierarchySnapshot current,
    List<Branch> branches,
  ) {
    return save(
      OrganizationHierarchySnapshot(
        organizations: current.organizations,
        branches: List.unmodifiable(branches),
        departments: current.departments,
        teams: current.teams,
      ),
    );
  }

  Future<void> saveDepartments(
    OrganizationHierarchySnapshot current,
    List<Department> departments,
  ) {
    return save(
      OrganizationHierarchySnapshot(
        organizations: current.organizations,
        branches: current.branches,
        departments: List.unmodifiable(departments),
        teams: current.teams,
      ),
    );
  }

  Future<void> saveTeams(
    OrganizationHierarchySnapshot current,
    List<Team> teams,
  ) {
    return save(
      OrganizationHierarchySnapshot(
        organizations: current.organizations,
        branches: current.branches,
        departments: current.departments,
        teams: List.unmodifiable(teams),
      ),
    );
  }
}

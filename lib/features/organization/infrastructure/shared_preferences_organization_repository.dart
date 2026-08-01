import 'package:workforce_core/workforce_core.dart';

import 'organization_hierarchy_store.dart';

final class SharedPreferencesOrganizationRepository
    implements OrganizationRepository {
  SharedPreferencesOrganizationRepository({
    OrganizationHierarchyStore? hierarchyStore,
  }) : hierarchyStore = hierarchyStore ?? OrganizationHierarchyStore();

  final OrganizationHierarchyStore hierarchyStore;

  @override
  Future<Organization?> findById(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    final snapshot = await hierarchyStore.load();

    for (final organization in snapshot.organizations) {
      if (organization.id == normalizedId) {
        return organization;
      }
    }

    return null;
  }

  @override
  Future<OrganizationPage> find(OrganizationQuery query) async {
    final snapshot = await hierarchyStore.load();
    final searchText = query.searchText?.trim().toLowerCase() ?? '';

    final filtered =
        snapshot.organizations.where((organization) {
          if (query.status != null && organization.status != query.status) {
            return false;
          }

          if (searchText.isEmpty) {
            return true;
          }

          return organization.code.toLowerCase().contains(searchText) ||
              organization.name.toLowerCase().contains(searchText);
        }).toList()..sort((a, b) {
          final nameComparison = a.name.compareTo(b.name);

          if (nameComparison != 0) {
            return nameComparison;
          }

          return a.id.compareTo(b.id);
        });

    final start = query.offset.clamp(0, filtered.length);
    final end = (start + query.limit).clamp(start, filtered.length);

    return OrganizationPage(
      items: List.unmodifiable(filtered.sublist(start, end)),
      total: filtered.length,
    );
  }

  @override
  Future<Organization> save(
    Organization organization, {
    required int expectedVersion,
  }) async {
    final snapshot = await hierarchyStore.load();
    final values = List<Organization>.of(snapshot.organizations);

    final duplicateCode = values.any(
      (value) =>
          value.id != organization.id &&
          value.deletedAt == null &&
          value.code.toLowerCase() == organization.code.toLowerCase(),
    );

    if (duplicateCode) {
      throw StateError('Organization code is already in use.');
    }

    final index = values.indexWhere((value) => value.id == organization.id);

    if (index == -1) {
      if (expectedVersion != 0) {
        throw StateError('Expected version must be 0 for a new organization.');
      }

      values.add(organization);
    } else {
      final current = values[index];

      if (current.version != expectedVersion) {
        throw StateError('Organization version conflict.');
      }

      values[index] = organization;
    }

    await hierarchyStore.saveOrganizations(snapshot, values);

    return organization;
  }

  @override
  Future<void> archive({
    required String id,
    required int expectedVersion,
    required DateTime archivedAt,
  }) async {
    final snapshot = await hierarchyStore.load();
    final values = List<Organization>.of(snapshot.organizations);
    final index = values.indexWhere((value) => value.id == id);

    if (index == -1) {
      throw StateError('Organization not found.');
    }

    final current = values[index];

    if (current.version != expectedVersion) {
      throw StateError('Organization version conflict.');
    }

    values[index] = current.copyWith(
      status: OrganizationStatus.archived,
      version: current.version + 1,
      updatedAt: archivedAt.toUtc(),
      deletedAt: archivedAt.toUtc(),
    );

    await hierarchyStore.saveOrganizations(snapshot, values);
  }
}

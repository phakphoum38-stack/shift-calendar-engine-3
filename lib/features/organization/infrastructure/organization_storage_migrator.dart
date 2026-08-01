import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Migrates enterprise organization storage without coupling domain objects to
/// a specific persistence implementation.
final class OrganizationStorageMigrator {
  const OrganizationStorageMigrator({
    this.schemaVersionKey = 'sce.enterprise.schema.version',
    this.currentVersion = 1,
  });

  final String schemaVersionKey;
  final int currentVersion;

  Future<void> migrate(SharedPreferences preferences) async {
    var version = preferences.getInt(schemaVersionKey) ?? 0;
    while (version < currentVersion) {
      final nextVersion = version + 1;
      await _runStep(preferences, nextVersion);
      await preferences.setInt(schemaVersionKey, nextVersion);
      version = nextVersion;
    }
  }

  Future<void> _runStep(
    SharedPreferences preferences,
    int targetVersion,
  ) async {
    switch (targetVersion) {
      case 1:
        await _migrateToVersion1(preferences);
      default:
        throw StateError('Unsupported organization schema $targetVersion');
    }
  }

  Future<void> _migrateToVersion1(SharedPreferences preferences) async {
    const legacyDepartmentKey = 'sce.departments';
    const enterpriseDepartmentKey = 'sce.enterprise.departments.v1';

    if (preferences.containsKey(enterpriseDepartmentKey)) {
      return;
    }

    final legacyValue = preferences.getString(legacyDepartmentKey);
    if (legacyValue == null || legacyValue.trim().isEmpty) {
      return;
    }

    final decoded = jsonDecode(legacyValue);
    if (decoded is! List) {
      return;
    }

    final records = decoded
        .whereType<Map>()
        .map((item) {
          final value = Map<String, dynamic>.from(item);
          return <String, dynamic>{
            'id': value['id']?.toString() ?? '',
            'code': value['code']?.toString() ?? '',
            'name': value['name']?.toString() ?? '',
            'organizationId': value['organizationId']?.toString() ?? '',
            'branchId': value['branchId']?.toString() ?? '',
            'parentDepartmentId': value['parentDepartmentId']?.toString() ?? '',
            'active': value['active'] is bool ? value['active'] : true,
          };
        })
        .toList(growable: false);

    await preferences.setString(
      enterpriseDepartmentKey,
      jsonEncode(<String, dynamic>{'version': 1, 'items': records}),
    );
  }
}

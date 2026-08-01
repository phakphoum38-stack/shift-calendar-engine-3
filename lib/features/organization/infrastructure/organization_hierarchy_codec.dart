import 'dart:convert';

import 'package:workforce_core/workforce_core.dart';

final class OrganizationHierarchySnapshot {
  const OrganizationHierarchySnapshot({
    this.organizations = const [],
    this.branches = const [],
    this.departments = const [],
    this.teams = const [],
  });

  final List<Organization> organizations;
  final List<Branch> branches;
  final List<Department> departments;
  final List<Team> teams;
}

final class OrganizationHierarchyCodec {
  const OrganizationHierarchyCodec();

  static const int schemaVersion = 1;

  String encode(OrganizationHierarchySnapshot snapshot) => jsonEncode({
    'schemaVersion': schemaVersion,
    'organizations': snapshot.organizations.map(_organizationToJson).toList(),
    'branches': snapshot.branches.map(_branchToJson).toList(),
    'departments': snapshot.departments.map(_departmentToJson).toList(),
    'teams': snapshot.teams.map(_teamToJson).toList(),
  });

  OrganizationHierarchySnapshot decode(String payload) {
    final root = jsonDecode(payload);
    if (root is! Map<String, dynamic>) {
      throw const FormatException('Organization hierarchy must be an object.');
    }
    if (root['schemaVersion'] != schemaVersion) {
      throw FormatException(
        'Unsupported organization hierarchy schema: ${root['schemaVersion']}.',
      );
    }
    return OrganizationHierarchySnapshot(
      organizations: _list(root, 'organizations', _organizationFromJson),
      branches: _list(root, 'branches', _branchFromJson),
      departments: _list(root, 'departments', _departmentFromJson),
      teams: _list(root, 'teams', _teamFromJson),
    );
  }

  static List<T> _list<T>(
    Map<String, dynamic> root,
    String key,
    T Function(Map<String, dynamic>) decode,
  ) {
    final value = root[key];
    if (value is! List) {
      throw FormatException('$key must be a list.');
    }
    return List<T>.unmodifiable(
      value.map((item) {
        if (item is! Map<String, dynamic>) {
          throw FormatException('$key contains an invalid item.');
        }
        return decode(item);
      }),
    );
  }

  static Map<String, Object?> _organizationToJson(Organization value) => {
    'id': value.id,
    'code': value.code,
    'name': value.name,
    'status': value.status.name,
    'version': value.version,
    'createdAt': value.createdAt.toUtc().toIso8601String(),
    'updatedAt': value.updatedAt.toUtc().toIso8601String(),
    'deletedAt': value.deletedAt?.toUtc().toIso8601String(),
  };

  static Organization _organizationFromJson(Map<String, dynamic> json) =>
      Organization(
        id: _string(json, 'id'),
        code: _string(json, 'code'),
        name: _string(json, 'name'),
        status: OrganizationStatus.values.byName(_string(json, 'status')),
        version: _integer(json, 'version'),
        createdAt: _date(json, 'createdAt'),
        updatedAt: _date(json, 'updatedAt'),
        deletedAt: _nullableDate(json, 'deletedAt'),
      );

  static Map<String, Object?> _branchToJson(Branch value) => {
    'id': value.id,
    'organizationId': value.organizationId,
    'code': value.code,
    'name': value.name,
    'active': value.active,
    'version': value.version,
    'createdAt': value.createdAt.toUtc().toIso8601String(),
    'updatedAt': value.updatedAt.toUtc().toIso8601String(),
    'deletedAt': value.deletedAt?.toUtc().toIso8601String(),
  };

  static Branch _branchFromJson(Map<String, dynamic> json) => Branch(
    id: _string(json, 'id'),
    organizationId: _string(json, 'organizationId'),
    code: _string(json, 'code'),
    name: _string(json, 'name'),
    active: _boolean(json, 'active'),
    version: _integer(json, 'version'),
    createdAt: _date(json, 'createdAt'),
    updatedAt: _date(json, 'updatedAt'),
    deletedAt: _nullableDate(json, 'deletedAt'),
  );

  static Map<String, Object?> _departmentToJson(Department value) => {
    'id': value.id,
    'organizationId': value.organizationId,
    'branchId': value.branchId,
    'code': value.code,
    'name': value.name,
    'active': value.active,
    'version': value.version,
    'createdAt': value.createdAt.toUtc().toIso8601String(),
    'updatedAt': value.updatedAt.toUtc().toIso8601String(),
    'deletedAt': value.deletedAt?.toUtc().toIso8601String(),
  };

  static Department _departmentFromJson(Map<String, dynamic> json) =>
      Department(
        id: _string(json, 'id'),
        organizationId: _string(json, 'organizationId'),
        branchId: _string(json, 'branchId'),
        code: _string(json, 'code'),
        name: _string(json, 'name'),
        active: _boolean(json, 'active'),
        version: _integer(json, 'version'),
        createdAt: _date(json, 'createdAt'),
        updatedAt: _date(json, 'updatedAt'),
        deletedAt: _nullableDate(json, 'deletedAt'),
      );

  static Map<String, Object?> _teamToJson(Team value) => {
    'id': value.id,
    'organizationId': value.organizationId,
    'branchId': value.branchId,
    'departmentId': value.departmentId,
    'code': value.code,
    'name': value.name,
    'active': value.active,
    'version': value.version,
    'createdAt': value.createdAt.toUtc().toIso8601String(),
    'updatedAt': value.updatedAt.toUtc().toIso8601String(),
    'deletedAt': value.deletedAt?.toUtc().toIso8601String(),
  };

  static Team _teamFromJson(Map<String, dynamic> json) => Team(
    id: _string(json, 'id'),
    organizationId: _string(json, 'organizationId'),
    branchId: _string(json, 'branchId'),
    departmentId: _string(json, 'departmentId'),
    code: _string(json, 'code'),
    name: _string(json, 'name'),
    active: _boolean(json, 'active'),
    version: _integer(json, 'version'),
    createdAt: _date(json, 'createdAt'),
    updatedAt: _date(json, 'updatedAt'),
    deletedAt: _nullableDate(json, 'deletedAt'),
  );

  static String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$key must be a non-empty string.');
    }
    return value;
  }

  static int _integer(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! int) {
      throw FormatException('$key must be an integer.');
    }
    return value;
  }

  static bool _boolean(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! bool) {
      throw FormatException('$key must be a boolean.');
    }
    return value;
  }

  static DateTime _date(Map<String, dynamic> json, String key) =>
      DateTime.parse(_string(json, key)).toUtc();

  static DateTime? _nullableDate(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('$key must be a timestamp or null.');
    }
    return DateTime.parse(value).toUtc();
  }
}

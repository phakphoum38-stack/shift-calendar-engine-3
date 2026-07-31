enum OrganizationStatus { active, inactive, archived }

final class Organization {
  Organization({
    required this.id,
    required String code,
    required String name,
    required this.status,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  }) : code = _required(code, 'code'),
       name = _required(name, 'name') {
    if (version < 1) {
      throw ArgumentError.value(version, 'version', 'must be at least 1');
    }
    if (updatedAt.isBefore(createdAt)) {
      throw ArgumentError('updatedAt must not be before createdAt');
    }
    if (status == OrganizationStatus.archived && deletedAt == null) {
      throw ArgumentError('archived organizations require deletedAt');
    }
  }

  final String id;
  final String code;
  final String name;
  final OrganizationStatus status;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isActive => status == OrganizationStatus.active && deletedAt == null;

  Organization copyWith({
    String? code,
    String? name,
    OrganizationStatus? status,
    int? version,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Organization(
      id: id,
      code: code ?? this.code,
      name: name ?? this.name,
      status: status ?? this.status,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
    );
  }

  static String _required(String value, String field) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, field, 'must not be empty');
    }
    return normalized;
  }

  @override
  bool operator ==(Object other) => other is Organization && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

final class Team {
  Team({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.departmentId,
    required String code,
    required String name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.active = true,
    this.deletedAt,
  }) : code = _required(code, 'code'),
       name = _required(name, 'name') {
    if (organizationId.trim().isEmpty) {
      throw ArgumentError.value(
        organizationId,
        'organizationId',
        'must not be empty',
      );
    }
    if (branchId.trim().isEmpty) {
      throw ArgumentError.value(branchId, 'branchId', 'must not be empty');
    }
    if (departmentId.trim().isEmpty) {
      throw ArgumentError.value(
        departmentId,
        'departmentId',
        'must not be empty',
      );
    }
    if (version < 1) {
      throw ArgumentError.value(version, 'version', 'must be at least 1');
    }
    if (updatedAt.isBefore(createdAt)) {
      throw ArgumentError('updatedAt must not be before createdAt');
    }
  }

  final String id;
  final String organizationId;
  final String branchId;
  final String departmentId;
  final String code;
  final String name;
  final bool active;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isActive => active && deletedAt == null;

  Team copyWith({
    String? organizationId,
    String? branchId,
    String? departmentId,
    String? code,
    String? name,
    bool? active,
    int? version,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Team(
      id: id,
      organizationId: organizationId ?? this.organizationId,
      branchId: branchId ?? this.branchId,
      departmentId: departmentId ?? this.departmentId,
      code: code ?? this.code,
      name: name ?? this.name,
      active: active ?? this.active,
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
  bool operator ==(Object other) => other is Team && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

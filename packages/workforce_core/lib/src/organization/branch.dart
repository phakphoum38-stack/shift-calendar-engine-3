final class Branch {
  Branch({
    required this.id,
    required this.organizationId,
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
    if (version < 1) {
      throw ArgumentError.value(version, 'version', 'must be at least 1');
    }
    if (updatedAt.isBefore(createdAt)) {
      throw ArgumentError('updatedAt must not be before createdAt');
    }
  }

  final String id;
  final String organizationId;
  final String code;
  final String name;
  final bool active;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isActive => active && deletedAt == null;

  Branch copyWith({
    String? organizationId,
    String? code,
    String? name,
    bool? active,
    int? version,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Branch(
      id: id,
      organizationId: organizationId ?? this.organizationId,
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
  bool operator ==(Object other) => other is Branch && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Organizational unit used for roster grouping and permissions.
class Department {
  const Department({
    required this.id,
    required this.code,
    required this.name,
    this.organizationId = '',
    this.branchId = '',
    this.parentDepartmentId = '',
    this.active = true,
  });

  final String id;
  final String code;
  final String name;
  final String organizationId;
  final String branchId;
  final String parentDepartmentId;
  final bool active;

  Department copyWith({
    String? id,
    String? code,
    String? name,
    String? organizationId,
    String? branchId,
    String? parentDepartmentId,
    bool? active,
  }) {
    return Department(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      organizationId: organizationId ?? this.organizationId,
      branchId: branchId ?? this.branchId,
      parentDepartmentId: parentDepartmentId ?? this.parentDepartmentId,
      active: active ?? this.active,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Department &&
          id == other.id &&
          code == other.code &&
          name == other.name &&
          organizationId == other.organizationId &&
          branchId == other.branchId &&
          parentDepartmentId == other.parentDepartmentId &&
          active == other.active;

  @override
  int get hashCode => Object.hash(
        id,
        code,
        name,
        organizationId,
        branchId,
        parentDepartmentId,
        active,
      );
}

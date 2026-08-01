/// Operational team or unit inside a department.
class Team {
  const Team({
    required this.id,
    required this.departmentId,
    required this.code,
    required this.name,
    this.active = true,
  });

  final String id;
  final String departmentId;
  final String code;
  final String name;
  final bool active;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Team &&
          id == other.id &&
          departmentId == other.departmentId &&
          code == other.code &&
          name == other.name &&
          active == other.active;

  @override
  int get hashCode => Object.hash(id, departmentId, code, name, active);
}

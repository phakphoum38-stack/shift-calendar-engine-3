/// Organizational unit used for roster grouping and permissions.
class Department {
  const Department({
    required this.id,
    required this.code,
    required this.name,
    this.active = true,
  });

  final String id;
  final String code;
  final String name;
  final bool active;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Department &&
          id == other.id &&
          code == other.code &&
          name == other.name &&
          active == other.active;

  @override
  int get hashCode => Object.hash(id, code, name, active);
}

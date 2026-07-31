/// Physical or logical site that belongs to an organization.
class Branch {
  const Branch({
    required this.id,
    required this.organizationId,
    required this.code,
    required this.name,
    this.address = '',
    this.timeZone = '',
    this.active = true,
  });

  final String id;
  final String organizationId;
  final String code;
  final String name;
  final String address;
  final String timeZone;
  final bool active;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Branch &&
          id == other.id &&
          organizationId == other.organizationId &&
          code == other.code &&
          name == other.name &&
          address == other.address &&
          timeZone == other.timeZone &&
          active == other.active;

  @override
  int get hashCode => Object.hash(
    id,
    organizationId,
    code,
    name,
    address,
    timeZone,
    active,
  );
}

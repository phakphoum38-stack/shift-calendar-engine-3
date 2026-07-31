/// Top-level organization that owns roster data and settings.
class Organization {
  const Organization({
    required this.id,
    required this.code,
    required this.name,
    this.displayName = '',
    this.timeZone = 'Asia/Bangkok',
    this.locale = 'th',
    this.countryCode = 'TH',
    this.active = true,
  });

  final String id;
  final String code;
  final String name;
  final String displayName;
  final String timeZone;
  final String locale;
  final String countryCode;
  final bool active;

  String get effectiveDisplayName =>
      displayName.trim().isEmpty ? name : displayName.trim();

  Organization copyWith({
    String? id,
    String? code,
    String? name,
    String? displayName,
    String? timeZone,
    String? locale,
    String? countryCode,
    bool? active,
  }) {
    return Organization(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      timeZone: timeZone ?? this.timeZone,
      locale: locale ?? this.locale,
      countryCode: countryCode ?? this.countryCode,
      active: active ?? this.active,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Organization &&
          id == other.id &&
          code == other.code &&
          name == other.name &&
          displayName == other.displayName &&
          timeZone == other.timeZone &&
          locale == other.locale &&
          countryCode == other.countryCode &&
          active == other.active;

  @override
  int get hashCode => Object.hash(
        id,
        code,
        name,
        displayName,
        timeZone,
        locale,
        countryCode,
        active,
      );
}

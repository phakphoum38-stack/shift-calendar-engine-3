/// Configurable reusable shift definition.
class ShiftTemplate {
  const ShiftTemplate({
    required this.id,
    required this.code,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.colorValue,
    required this.workingHours,
    this.rate = 0,
    this.active = true,
  });

  final String id;
  final String code;
  final String name;
  final Duration startTime;
  final Duration endTime;
  final int colorValue;
  final double workingHours;
  final double rate;
  final bool active;

  bool get overnight => endTime <= startTime;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftTemplate &&
          id == other.id &&
          code == other.code &&
          name == other.name &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          colorValue == other.colorValue &&
          workingHours == other.workingHours &&
          rate == other.rate &&
          active == other.active;

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    startTime,
    endTime,
    colorValue,
    workingHours,
    rate,
    active,
  );
}

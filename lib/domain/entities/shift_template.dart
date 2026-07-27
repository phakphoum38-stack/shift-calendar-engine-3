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

  ShiftTemplate copyWith({
    String? id,
    String? code,
    String? name,
    Duration? startTime,
    Duration? endTime,
    int? colorValue,
    double? workingHours,
    double? rate,
    bool? active,
  }) {
    return ShiftTemplate(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      colorValue: colorValue ?? this.colorValue,
      workingHours: workingHours ?? this.workingHours,
      rate: rate ?? this.rate,
      active: active ?? this.active,
    );
  }

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

final class ShiftAssignment {
  ShiftAssignment({
    required this.id,
    required this.employeeId,
    required this.shiftCode,
    required DateTime startsAt,
    required DateTime endsAt,
    this.departmentId = '',
    this.location = '',
  }) : startsAt = startsAt.toUtc(),
       endsAt = endsAt.toUtc() {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be empty');
    }
    if (employeeId.trim().isEmpty) {
      throw ArgumentError.value(employeeId, 'employeeId', 'must not be empty');
    }
    if (shiftCode.trim().isEmpty) {
      throw ArgumentError.value(shiftCode, 'shiftCode', 'must not be empty');
    }
    if (!this.endsAt.isAfter(this.startsAt)) {
      throw ArgumentError('endsAt must be after startsAt');
    }
  }

  final String id;
  final String employeeId;
  final String shiftCode;
  final DateTime startsAt;
  final DateTime endsAt;
  final String departmentId;
  final String location;

  Duration get duration => endsAt.difference(startsAt);

  bool overlaps(ShiftAssignment other) =>
      startsAt.isBefore(other.endsAt) && endsAt.isAfter(other.startsAt);

  ShiftAssignment copyWith({
    String? id,
    String? employeeId,
    String? shiftCode,
    DateTime? startsAt,
    DateTime? endsAt,
    String? departmentId,
    String? location,
  }) {
    return ShiftAssignment(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      shiftCode: shiftCode ?? this.shiftCode,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      departmentId: departmentId ?? this.departmentId,
      location: location ?? this.location,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftAssignment &&
          other.id == id &&
          other.employeeId == employeeId &&
          other.shiftCode == shiftCode &&
          other.startsAt == startsAt &&
          other.endsAt == endsAt &&
          other.departmentId == departmentId &&
          other.location == location;

  @override
  int get hashCode => Object.hash(
    id,
    employeeId,
    shiftCode,
    startsAt,
    endsAt,
    departmentId,
    location,
  );
}

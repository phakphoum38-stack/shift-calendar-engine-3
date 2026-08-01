enum EmployeeTimeWindowKind { availability, leave }

final class EmployeeTimeWindow {
  EmployeeTimeWindow({
    required this.id,
    required this.employeeId,
    required this.kind,
    required DateTime startsAt,
    required DateTime endsAt,
  }) : startsAt = startsAt.toUtc(),
       endsAt = endsAt.toUtc() {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be empty');
    }
    if (employeeId.trim().isEmpty) {
      throw ArgumentError.value(employeeId, 'employeeId', 'must not be empty');
    }
    if (!this.endsAt.isAfter(this.startsAt)) {
      throw ArgumentError('endsAt must be after startsAt');
    }
  }

  final String id;
  final String employeeId;
  final EmployeeTimeWindowKind kind;
  final DateTime startsAt;
  final DateTime endsAt;

  bool overlaps(DateTime start, DateTime end) =>
      startsAt.isBefore(end) && endsAt.isAfter(start);

  bool contains(DateTime start, DateTime end) =>
      !start.isBefore(startsAt) && !end.isAfter(endsAt);
}

enum EmploymentType {
  fullTime,
  partTime,
  temporary,
  contract,
  intern,
  other,
}

/// Employment details kept separate from personal identity.
class Employment {
  const Employment({
    this.type = EmploymentType.fullTime,
    this.startDate,
    this.endDate,
    this.supervisorEmployeeId = '',
    this.shiftGroupId = '',
    this.defaultShiftTemplateId = '',
  });

  final EmploymentType type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String supervisorEmployeeId;
  final String shiftGroupId;
  final String defaultShiftTemplateId;

  bool get isCurrent {
    final now = DateTime.now();
    return (startDate == null || !startDate!.isAfter(now)) &&
        (endDate == null || !endDate!.isBefore(now));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employment &&
          type == other.type &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          supervisorEmployeeId == other.supervisorEmployeeId &&
          shiftGroupId == other.shiftGroupId &&
          defaultShiftTemplateId == other.defaultShiftTemplateId;

  @override
  int get hashCode => Object.hash(
    type,
    startDate,
    endDate,
    supervisorEmployeeId,
    shiftGroupId,
    defaultShiftTemplateId,
  );
}

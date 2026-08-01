enum ShiftPeriod { morning, afternoon, night, other }

final class EmployeeFairnessSummary {
  const EmployeeFairnessSummary({
    required this.employeeId,
    this.totalAssignments = 0,
    this.morningAssignments = 0,
    this.afternoonAssignments = 0,
    this.nightAssignments = 0,
    this.otherAssignments = 0,
    this.weekendAssignments = 0,
  });

  final String employeeId;
  final int totalAssignments;
  final int morningAssignments;
  final int afternoonAssignments;
  final int nightAssignments;
  final int otherAssignments;
  final int weekendAssignments;
}

final class RosterFairnessReport {
  const RosterFairnessReport({
    required this.score,
    required this.employeeSummaries,
    required this.assignmentSpread,
    required this.nightSpread,
    required this.weekendSpread,
  });

  final int score;
  final List<EmployeeFairnessSummary> employeeSummaries;
  final int assignmentSpread;
  final int nightSpread;
  final int weekendSpread;

  bool get isPerfectlyBalanced => score == 100;
}

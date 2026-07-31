enum RosterViolationSeverity { warning, error }

enum RosterViolationCode {
  duplicateAssignment,
  overlappingAssignment,
  insufficientRest,
  maximumConsecutiveDays,
}

final class RosterViolation {
  const RosterViolation({
    required this.code,
    required this.severity,
    required this.message,
    this.employeeId,
    this.assignmentIds = const [],
  });

  final RosterViolationCode code;
  final RosterViolationSeverity severity;
  final String message;
  final String? employeeId;
  final List<String> assignmentIds;
}

final class RosterValidationResult {
  const RosterValidationResult({this.violations = const []});

  final List<RosterViolation> violations;

  bool get isValid => violations.every(
    (violation) => violation.severity != RosterViolationSeverity.error,
  );

  List<RosterViolation> get errors => List.unmodifiable(
    violations.where(
      (violation) => violation.severity == RosterViolationSeverity.error,
    ),
  );

  List<RosterViolation> get warnings => List.unmodifiable(
    violations.where(
      (violation) => violation.severity == RosterViolationSeverity.warning,
    ),
  );
}

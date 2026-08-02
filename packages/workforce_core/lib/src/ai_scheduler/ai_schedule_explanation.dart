enum AiScheduleExplanationKind {
  assignment,
  unassigned,
  constraint,
  fairness,
  approval,
}

final class AiScheduleExplanation {
  const AiScheduleExplanation({
    required this.code,
    required this.kind,
    required this.message,
    this.employeeId,
    this.slotId,
  });

  final String code;
  final AiScheduleExplanationKind kind;
  final String message;
  final String? employeeId;
  final String? slotId;
}

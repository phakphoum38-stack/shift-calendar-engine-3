import '../roster/evaluation_report.dart';
import '../roster/shift_assignment.dart';

final class SchedulerResult {
  const SchedulerResult({
    required this.assignments,
    required this.unfilledSlotIds,
    required this.evaluation,
  });

  final List<ShiftAssignment> assignments;
  final List<String> unfilledSlotIds;
  final RosterEvaluationReport evaluation;

  bool get isComplete => unfilledSlotIds.isEmpty;
}

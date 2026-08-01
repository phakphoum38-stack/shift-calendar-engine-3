import '../roster/evaluation_report.dart';
import '../roster/shift_assignment.dart';

final class SchedulerResult {
  const SchedulerResult({
    required this.assignments,
    required this.unassignedSlotIds,
    required this.evaluation,
  });

  final List<ShiftAssignment> assignments;
  final List<String> unassignedSlotIds;
  final RosterEvaluationReport evaluation;

  bool get isComplete => unassignedSlotIds.isEmpty;
}

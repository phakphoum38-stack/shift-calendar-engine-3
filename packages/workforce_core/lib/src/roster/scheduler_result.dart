import 'evaluation_report.dart';
import 'shift_assignment.dart';

final class RosterSchedulerResult {
  const RosterSchedulerResult({
    required this.assignments,
    required this.unassignedShiftIds,
    required this.evaluation,
  });

  final List<ShiftAssignment> assignments;
  final List<String> unassignedShiftIds;
  final RosterEvaluationReport evaluation;

  bool get isComplete => unassignedShiftIds.isEmpty;
}

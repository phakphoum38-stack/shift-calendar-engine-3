import '../scheduler/scheduler_result.dart' as canonical;
import 'evaluation_report.dart';
import 'shift_assignment.dart';

@Deprecated('Use SchedulerResult from src/scheduler instead.')
final class RosterSchedulerResult {
  const RosterSchedulerResult({
    required this.assignments,
    required this.unassignedShiftIds,
    required this.evaluation,
  });

  factory RosterSchedulerResult.fromCanonical(
    canonical.SchedulerResult result,
  ) {
    return RosterSchedulerResult(
      assignments: result.assignments,
      unassignedShiftIds: result.unassignedSlotIds,
      evaluation: result.evaluation,
    );
  }

  final List<ShiftAssignment> assignments;
  final List<String> unassignedShiftIds;
  final RosterEvaluationReport evaluation;

  bool get isComplete => unassignedShiftIds.isEmpty;
}

import '../roster/evaluation_engine.dart';
import '../roster/shift_assignment.dart';
import 'scheduler_engine.dart';
import 'scheduler_request.dart';
import 'scheduler_result.dart';

final class GreedyScheduler implements SchedulerEngine {
  const GreedyScheduler({
    this.evaluationEngine = const RosterEvaluationEngine(),
  });

  final RosterEvaluationEngine evaluationEngine;

  @override
  SchedulerResult generate(SchedulerRequest request) {
    final assignments = List<ShiftAssignment>.of(request.existingAssignments);
    final unfilled = <String>[];
    final slots = List<SchedulerShiftSlot>.of(request.slots)
      ..sort((a, b) {
        final start = a.startsAt.compareTo(b.startsAt);
        return start != 0 ? start : a.id.compareTo(b.id);
      });

    for (final slot in slots) {
      ShiftAssignment? bestAssignment;
      var bestScore = -1;

      final employeeIds = List<String>.of(request.employeeIds)..sort();
      for (final employeeId in employeeIds) {
        final candidate = ShiftAssignment(
          id: 'generated:${slot.id}:$employeeId',
          employeeId: employeeId,
          shiftCode: slot.shiftCode,
          startsAt: slot.startsAt,
          endsAt: slot.endsAt,
          departmentId: slot.departmentId,
          location: slot.location,
        );
        final candidateAssignments = [...assignments, candidate];
        final evaluation = evaluationEngine.evaluate(
          candidateAssignments,
          timeWindows: request.timeWindows,
          employeeIds: request.employeeIds,
        );

        if (!evaluation.validation.isValid) {
          continue;
        }

        if (evaluation.overallScore > bestScore) {
          bestScore = evaluation.overallScore;
          bestAssignment = candidate;
        }
      }

      if (bestAssignment == null) {
        unfilled.add(slot.id);
      } else {
        assignments.add(bestAssignment);
      }
    }

    final evaluation = evaluationEngine.evaluate(
      assignments,
      timeWindows: request.timeWindows,
      employeeIds: request.employeeIds,
    );

    return SchedulerResult(
      assignments: List.unmodifiable(assignments),
      unfilledSlotIds: List.unmodifiable(unfilled),
      evaluation: evaluation,
    );
  }
}

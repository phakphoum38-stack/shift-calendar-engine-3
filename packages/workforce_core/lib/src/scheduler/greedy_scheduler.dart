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
    final generatedAssignments = <ShiftAssignment>[];
    final unassignedSlotIds = <String>[];
    final loadByEmployee = <String, int>{
      for (final employeeId in request.employeeIds)
        employeeId: request.existingAssignments
            .where((assignment) => assignment.employeeId == employeeId)
            .length,
    };
    final slots = List<SchedulerShiftSlot>.of(request.slots)
      ..sort((a, b) {
        final start = a.startsAt.compareTo(b.startsAt);
        return start != 0 ? start : a.id.compareTo(b.id);
      });

    for (final slot in slots) {
      final candidates = List<String>.of(request.employeeIds)
        ..sort((a, b) {
          final loadComparison = loadByEmployee[a]!.compareTo(
            loadByEmployee[b]!,
          );
          return loadComparison != 0 ? loadComparison : a.compareTo(b);
        });

      ShiftAssignment? selected;
      for (final employeeId in candidates) {
        final candidate = slot.assignTo(employeeId);
        final validation = evaluationEngine.constraintEngine.validate([
          ...request.existingAssignments,
          ...generatedAssignments,
          candidate,
        ], timeWindows: request.timeWindows);
        if (validation.isValid) {
          selected = candidate;
          break;
        }
      }

      if (selected == null) {
        unassignedSlotIds.add(slot.id);
        continue;
      }

      generatedAssignments.add(selected);
      loadByEmployee[selected.employeeId] =
          loadByEmployee[selected.employeeId]! + 1;
    }

    final evaluation = evaluationEngine.evaluate(
      [...request.existingAssignments, ...generatedAssignments],
      timeWindows: request.timeWindows,
      employeeIds: request.employeeIds,
    );

    return SchedulerResult(
      assignments: List.unmodifiable(generatedAssignments),
      unassignedSlotIds: List.unmodifiable(unassignedSlotIds),
      evaluation: evaluation,
    );
  }
}

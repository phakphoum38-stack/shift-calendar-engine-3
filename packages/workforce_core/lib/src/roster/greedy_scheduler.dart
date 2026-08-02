import 'evaluation_engine.dart';
import 'scheduler_request.dart';
import 'scheduler_result.dart';
import 'shift_assignment.dart';

final class GreedyRosterScheduler {
  const GreedyRosterScheduler({
    this.evaluationEngine = const RosterEvaluationEngine(),
  });

  final RosterEvaluationEngine evaluationEngine;

  RosterSchedulerResult generate(RosterSchedulerRequest request) {
    final generated = <ShiftAssignment>[];
    final unassigned = <String>[];
    final counts = <String, int>{
      for (final employeeId in request.employeeIds) employeeId: 0,
    };

    for (final assignment in request.existingAssignments) {
      if (counts.containsKey(assignment.employeeId)) {
        counts[assignment.employeeId] = counts[assignment.employeeId]! + 1;
      }
    }

    final shifts = List<SchedulerShiftSlot>.of(request.shifts)
      ..sort((a, b) {
        final start = a.startsAt.compareTo(b.startsAt);
        return start != 0 ? start : a.id.compareTo(b.id);
      });

    for (final shift in shifts) {
      final candidates = List<String>.of(request.employeeIds)
        ..sort((a, b) {
          final countComparison = counts[a]!.compareTo(counts[b]!);
          return countComparison != 0 ? countComparison : a.compareTo(b);
        });

      ShiftAssignment? selected;
      for (final employeeId in candidates) {
        final candidate = shift.assignTo(employeeId);
        final tentative = <ShiftAssignment>[
          ...request.existingAssignments,
          ...generated,
          candidate,
        ];
        final evaluation = evaluationEngine.evaluate(
          tentative,
          timeWindows: request.timeWindows,
          employeeIds: request.employeeIds,
        );

        if (evaluation.validation.isValid) {
          selected = candidate;
          break;
        }
      }

      if (selected == null) {
        unassigned.add(shift.id);
      } else {
        generated.add(selected);
        counts[selected.employeeId] = counts[selected.employeeId]! + 1;
      }
    }

    final assignments = List<ShiftAssignment>.unmodifiable([
      ...request.existingAssignments,
      ...generated,
    ]);
    final evaluation = evaluationEngine.evaluate(
      assignments,
      timeWindows: request.timeWindows,
      employeeIds: request.employeeIds,
    );

    return RosterSchedulerResult(
      assignments: assignments,
      unassignedShiftIds: List.unmodifiable(unassigned),
      evaluation: evaluation,
    );
  }
}

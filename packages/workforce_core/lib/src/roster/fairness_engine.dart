import 'fairness_policy.dart';
import 'fairness_report.dart';
import 'shift_assignment.dart';

final class RosterFairnessEngine {
  const RosterFairnessEngine({this.policy = const RosterFairnessPolicy()});

  final RosterFairnessPolicy policy;

  RosterFairnessReport evaluate(
    List<ShiftAssignment> assignments, {
    Iterable<String>? employeeIds,
  }) {
    final ids = <String>{
      ...?employeeIds,
      for (final assignment in assignments) assignment.employeeId,
    }.toList()..sort();

    final summaries = <EmployeeFairnessSummary>[];

    for (final employeeId in ids) {
      final employeeAssignments = assignments
          .where((assignment) => assignment.employeeId == employeeId)
          .toList();

      var morning = 0;
      var afternoon = 0;
      var night = 0;
      var other = 0;
      var weekend = 0;

      for (final assignment in employeeAssignments) {
        switch (_periodFor(assignment.shiftCode)) {
          case ShiftPeriod.morning:
            morning++;
          case ShiftPeriod.afternoon:
            afternoon++;
          case ShiftPeriod.night:
            night++;
          case ShiftPeriod.other:
            other++;
        }

        final weekday = assignment.startsAt.weekday;
        if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
          weekend++;
        }
      }

      summaries.add(
        EmployeeFairnessSummary(
          employeeId: employeeId,
          totalAssignments: employeeAssignments.length,
          morningAssignments: morning,
          afternoonAssignments: afternoon,
          nightAssignments: night,
          otherAssignments: other,
          weekendAssignments: weekend,
        ),
      );
    }

    final assignmentSpread = _spread(
      summaries.map((summary) => summary.totalAssignments),
    );
    final nightSpread = _spread(
      summaries.map((summary) => summary.nightAssignments),
    );
    final weekendSpread = _spread(
      summaries.map((summary) => summary.weekendAssignments),
    );

    final score = _score(
      assignmentSpread: assignmentSpread,
      nightSpread: nightSpread,
      weekendSpread: weekendSpread,
    );

    return RosterFairnessReport(
      score: score,
      employeeSummaries: List.unmodifiable(summaries),
      assignmentSpread: assignmentSpread,
      nightSpread: nightSpread,
      weekendSpread: weekendSpread,
    );
  }

  ShiftPeriod _periodFor(String shiftCode) {
    final normalized = policy.normalizeShiftCode(shiftCode);

    if (policy.morningShiftCodes.contains(normalized)) {
      return ShiftPeriod.morning;
    }
    if (policy.afternoonShiftCodes.contains(normalized)) {
      return ShiftPeriod.afternoon;
    }
    if (policy.nightShiftCodes.contains(normalized)) {
      return ShiftPeriod.night;
    }
    return ShiftPeriod.other;
  }

  int _spread(Iterable<int> values) {
    final list = values.toList();
    if (list.isEmpty) return 0;

    var minimum = list.first;
    var maximum = list.first;
    for (final value in list.skip(1)) {
      if (value < minimum) minimum = value;
      if (value > maximum) maximum = value;
    }
    return maximum - minimum;
  }

  int _score({
    required int assignmentSpread,
    required int nightSpread,
    required int weekendSpread,
  }) {
    final assignmentScore = _componentScore(assignmentSpread);
    final nightScore = _componentScore(nightSpread);
    final weekendScore = _componentScore(weekendSpread);

    final weighted =
        assignmentScore * policy.assignmentWeight +
        nightScore * policy.nightWeight +
        weekendScore * policy.weekendWeight;

    return (weighted / 100).round().clamp(0, 100);
  }

  int _componentScore(int spread) => (100 - (spread * 20)).clamp(0, 100);
}

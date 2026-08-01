import 'constraint_engine.dart';
import 'employee_availability.dart';
import 'evaluation_report.dart';
import 'fairness_engine.dart';
import 'shift_assignment.dart';

final class RosterEvaluationEngine {
  const RosterEvaluationEngine({
    this.constraintEngine = const RosterConstraintEngine(),
    this.fairnessEngine = const RosterFairnessEngine(),
  });

  final RosterConstraintEngine constraintEngine;
  final RosterFairnessEngine fairnessEngine;

  RosterEvaluationReport evaluate(
    List<ShiftAssignment> assignments, {
    List<EmployeeTimeWindow> timeWindows = const [],
    Iterable<String>? employeeIds,
  }) {
    final validation = constraintEngine.validate(
      assignments,
      timeWindows: timeWindows,
    );
    final fairness = fairnessEngine.evaluate(
      assignments,
      employeeIds: employeeIds,
    );

    final validationScore = _validationScore(
      errors: validation.errors.length,
      warnings: validation.warnings.length,
    );
    final overallScore =
        ((validationScore * 70) + (fairness.score * 30)) ~/ 100;

    return RosterEvaluationReport(
      validation: validation,
      fairness: fairness,
      overallScore: overallScore.clamp(0, 100),
      recommendations: List.unmodifiable(
        _recommendations(
          errorCount: validation.errors.length,
          warningCount: validation.warnings.length,
          assignmentSpread: fairness.assignmentSpread,
          nightSpread: fairness.nightSpread,
          weekendSpread: fairness.weekendSpread,
        ),
      ),
    );
  }

  int _validationScore({required int errors, required int warnings}) {
    return (100 - (errors * 25) - (warnings * 5)).clamp(0, 100);
  }

  List<String> _recommendations({
    required int errorCount,
    required int warningCount,
    required int assignmentSpread,
    required int nightSpread,
    required int weekendSpread,
  }) {
    final values = <String>[];

    if (errorCount > 0) {
      values.add('Resolve hard constraint violations before publishing.');
    }
    if (warningCount > 0) {
      values.add('Review roster warnings before final approval.');
    }
    if (assignmentSpread > 1) {
      values.add('Redistribute assignments to improve total workload balance.');
    }
    if (nightSpread > 1) {
      values.add('Redistribute night shifts more evenly.');
    }
    if (weekendSpread > 1) {
      values.add('Redistribute weekend shifts more evenly.');
    }

    return values;
  }
}

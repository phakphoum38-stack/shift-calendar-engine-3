import '../roster/employee_availability.dart';
import '../roster/roster_validation.dart';
import '../roster/shift_assignment.dart';

final class AiConstraintContext {
  AiConstraintContext({
    required Iterable<ShiftAssignment> assignments,
    Iterable<EmployeeTimeWindow> timeWindows = const [],
  }) : assignments = List.unmodifiable(assignments),
       timeWindows = List.unmodifiable(timeWindows);

  final List<ShiftAssignment> assignments;
  final List<EmployeeTimeWindow> timeWindows;
}

abstract interface class AiConstraintPlugin {
  String get id;

  Iterable<RosterViolation> evaluate(AiConstraintContext context);
}

final class AiConstraintPluginResult {
  AiConstraintPluginResult({required Iterable<RosterViolation> violations})
    : violations = List.unmodifiable(violations);

  final List<RosterViolation> violations;

  bool get isValid => violations.every(
    (violation) => violation.severity != RosterViolationSeverity.error,
  );
}

final class AiConstraintPluginEngine {
  AiConstraintPluginEngine({required Iterable<AiConstraintPlugin> plugins})
    : plugins = List.unmodifiable(plugins) {
    final ids = this.plugins.map((plugin) => plugin.id).toList();
    if (ids.any((id) => id.trim().isEmpty)) {
      throw ArgumentError('Plugin ids must not be empty.');
    }
    if (ids.toSet().length != ids.length) {
      throw ArgumentError('Plugin ids must be unique.');
    }
  }

  final List<AiConstraintPlugin> plugins;

  AiConstraintPluginResult evaluate(AiConstraintContext context) {
    final violations = <RosterViolation>[];
    for (final plugin in plugins) {
      violations.addAll(plugin.evaluate(context));
    }
    return AiConstraintPluginResult(violations: violations);
  }
}

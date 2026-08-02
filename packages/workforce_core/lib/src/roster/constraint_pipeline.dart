import 'constraint_engine.dart';
import 'employee_availability.dart';
import 'roster_constraint.dart';
import 'roster_validation.dart';
import 'shift_assignment.dart';

final class RosterConstraintContext {
  const RosterConstraintContext({
    required this.assignments,
    this.timeWindows = const [],
    this.policy = const RosterConstraintPolicy(),
  });

  final List<ShiftAssignment> assignments;
  final List<EmployeeTimeWindow> timeWindows;
  final RosterConstraintPolicy policy;
}

abstract interface class RosterConstraintRule {
  String get id;

  Iterable<RosterViolation> evaluate(RosterConstraintContext context);
}

final class RosterConstraintPipeline {
  const RosterConstraintPipeline({
    this.baseEngine = const RosterConstraintEngine(),
    this.rules = const [],
  });

  final RosterConstraintEngine baseEngine;
  final List<RosterConstraintRule> rules;

  RosterValidationResult validate(RosterConstraintContext context) {
    _validateRuleIds();

    final baseValidation = baseEngine.validate(
      context.assignments,
      timeWindows: context.timeWindows,
    );
    final violations = <RosterViolation>[...baseValidation.violations];

    for (final rule in rules) {
      violations.addAll(rule.evaluate(context));
    }

    return RosterValidationResult(violations: List.unmodifiable(violations));
  }

  void _validateRuleIds() {
    final ids = <String>{};
    for (final rule in rules) {
      final id = rule.id.trim();
      if (id.isEmpty) {
        throw StateError('Roster constraint rule id must not be empty.');
      }
      if (!ids.add(id)) {
        throw StateError('Roster constraint rule ids must be unique: $id');
      }
    }
  }
}

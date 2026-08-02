import '../roster/constraint_engine.dart';
import '../roster/roster_validation.dart';
import 'ai_constraint_plugin.dart';

final class CanonicalConstraintPlugin implements AiConstraintPlugin {
  const CanonicalConstraintPlugin({
    this.engine = const RosterConstraintEngine(),
  });

  final RosterConstraintEngine engine;

  @override
  String get id => 'canonical.roster';

  @override
  Iterable<RosterViolation> evaluate(AiConstraintContext context) {
    return engine
        .validate(
          context.assignments,
          timeWindows: context.timeWindows,
        )
        .violations;
  }
}

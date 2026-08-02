import '../scheduler/greedy_scheduler.dart' as canonical;
import 'evaluation_engine.dart';
import 'scheduler_request.dart';
import 'scheduler_result.dart';

@Deprecated('Use GreedyScheduler from src/scheduler instead.')
final class GreedyRosterScheduler {
  const GreedyRosterScheduler({
    this.evaluationEngine = const RosterEvaluationEngine(),
  });

  final RosterEvaluationEngine evaluationEngine;

  RosterSchedulerResult generate(RosterSchedulerRequest request) {
    final scheduler = canonical.GreedyScheduler(
      evaluationEngine: evaluationEngine,
    );
    return RosterSchedulerResult.fromCanonical(
      scheduler.generate(request.toCanonical()),
    );
  }
}

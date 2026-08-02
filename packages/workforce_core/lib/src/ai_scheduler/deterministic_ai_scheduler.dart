import '../scheduler/greedy_scheduler.dart';
import '../scheduler/scheduler_engine.dart';
import '../scheduler/scheduler_request.dart';
import 'ai_schedule_proposal.dart';
import 'ai_scheduler_assistant.dart';
import 'ai_scheduler_rule_engine.dart';

final class DeterministicAiScheduler implements AiSchedulerAssistant {
  const DeterministicAiScheduler({
    this.engine = const GreedyScheduler(),
    this.ruleEngine = const DefaultAiSchedulerRuleEngine(),
  });

  final SchedulerEngine engine;
  final AiSchedulerRuleEngine ruleEngine;

  @override
  AiScheduleProposal propose(SchedulerRequest request) {
    final schedule = engine.generate(request);
    return AiScheduleProposal(
      schedule: schedule,
      details: ruleEngine.explain(request, schedule),
    );
  }
}

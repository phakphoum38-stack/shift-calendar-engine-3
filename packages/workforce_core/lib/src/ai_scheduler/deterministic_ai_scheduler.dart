import '../scheduler/greedy_scheduler.dart';
import '../scheduler/scheduler_engine.dart';
import '../scheduler/scheduler_request.dart';
import 'ai_schedule_proposal.dart';
import 'ai_scheduler_assistant.dart';

final class DeterministicAiScheduler implements AiSchedulerAssistant {
  const DeterministicAiScheduler({
    this.engine = const GreedyScheduler(),
  });

  final SchedulerEngine engine;

  @override
  AiScheduleProposal propose(SchedulerRequest request) {
    final schedule = engine.generate(request);
    final explanations = <String>[
      'Generated ${schedule.assignments.length} assignments using the canonical scheduler engine.',
      if (schedule.unassignedSlotIds.isEmpty)
        'All requested shift slots were assigned.'
      else
        '${schedule.unassignedSlotIds.length} shift slots remain unassigned and require review.',
      'Human approval is required before this proposal is published or saved.',
    ];

    return AiScheduleProposal(
      schedule: schedule,
      explanations: explanations,
    );
  }
}

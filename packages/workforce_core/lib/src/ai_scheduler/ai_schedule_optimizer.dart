import '../scheduler/scheduler_request.dart';
import 'ai_schedule_simulation.dart';
import 'ai_scheduler_assistant.dart';

abstract interface class AiScheduleOptimizer {
  AiScheduleSimulation simulate(SchedulerRequest request);
}

final class DeterministicAiScheduleOptimizer implements AiScheduleOptimizer {
  DeterministicAiScheduleOptimizer({
    required Iterable<AiSchedulerAssistant> assistants,
  }) : assistants = List.unmodifiable(assistants) {
    if (this.assistants.isEmpty) {
      throw ArgumentError.value(
        assistants,
        'assistants',
        'At least one assistant is required.',
      );
    }
  }

  final List<AiSchedulerAssistant> assistants;

  @override
  AiScheduleSimulation simulate(SchedulerRequest request) {
    return AiScheduleSimulation(
      proposals: assistants.map((assistant) => assistant.propose(request)),
    );
  }
}

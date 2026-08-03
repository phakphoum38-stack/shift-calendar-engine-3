import '../scheduler/scheduler_request.dart';
import 'ai_schedule_decision.dart';
import 'ai_schedule_optimizer.dart';

final class AiSchedulerCoordinator {
  const AiSchedulerCoordinator({required this.optimizer});

  final AiScheduleOptimizer optimizer;

  AiScheduleDecision decide(SchedulerRequest request) {
    final simulation = optimizer.simulate(request);
    return AiScheduleDecision(
      simulation: simulation,
      selectedProposal: simulation.bestProposal,
    );
  }
}

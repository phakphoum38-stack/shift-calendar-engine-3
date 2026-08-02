import '../scheduler/scheduler_result.dart';

final class AiScheduleProposal {
  AiScheduleProposal({
    required this.schedule,
    required Iterable<String> explanations,
    this.requiresApproval = true,
  }) : explanations = List.unmodifiable(explanations);

  final SchedulerResult schedule;
  final List<String> explanations;
  final bool requiresApproval;

  bool get isComplete => schedule.isComplete;
}

import '../scheduler/scheduler_result.dart';
import 'ai_schedule_explanation.dart';

final class AiScheduleProposal {
  AiScheduleProposal({
    required this.schedule,
    required Iterable<AiScheduleExplanation> details,
    this.requiresApproval = true,
  }) : details = List.unmodifiable(details);

  final SchedulerResult schedule;
  final List<AiScheduleExplanation> details;
  final bool requiresApproval;

  List<String> get explanations =>
      List.unmodifiable(details.map((item) => item.message));

  bool get isComplete => schedule.isComplete;
}

import '../scheduler/scheduler_request.dart';
import 'ai_schedule_proposal.dart';

abstract interface class AiSchedulerAssistant {
  AiScheduleProposal propose(SchedulerRequest request);
}

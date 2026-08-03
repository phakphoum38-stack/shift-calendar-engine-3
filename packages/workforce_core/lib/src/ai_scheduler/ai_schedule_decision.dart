import 'ai_schedule_proposal.dart';
import 'ai_schedule_simulation.dart';

final class AiScheduleDecision {
  const AiScheduleDecision({
    required this.simulation,
    required this.selectedProposal,
  });

  final AiScheduleSimulation simulation;
  final AiScheduleProposal selectedProposal;

  bool get isComplete => selectedProposal.isComplete;

  bool get requiresApproval => selectedProposal.requiresApproval;

  bool get canPublish =>
      isComplete &&
      selectedProposal.schedule.evaluation.validation.isValid &&
      !requiresApproval;

  int get evaluatedProposalCount => simulation.proposals.length;

  List<String> get explanations => selectedProposal.explanations;
}

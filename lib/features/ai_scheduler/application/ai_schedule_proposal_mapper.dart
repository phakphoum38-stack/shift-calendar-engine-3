import 'package:workforce_core/workforce_core.dart';

import 'ai_scheduler_view_data.dart';

final class AiScheduleProposalMapper {
  const AiScheduleProposalMapper();

  AiSchedulerViewData map(AiScheduleProposal proposal) {
    final evaluation = proposal.schedule.evaluation;
    final fairnessScore = evaluation.fairness.score;

    return AiSchedulerViewData(
      score: evaluation.overallScore,
      conflictCount: evaluation.validation.errors.length,
      fairnessLabel: _fairnessLabel(fairnessScore),
      explanations: List.unmodifiable(proposal.explanations),
      requiresApproval: proposal.requiresApproval,
      isComplete: proposal.isComplete,
    );
  }

  String _fairnessLabel(int score) {
    if (score >= 90) {
      return 'Excellent';
    }
    if (score >= 75) {
      return 'Good';
    }
    if (score >= 60) {
      return 'Fair';
    }
    return 'Needs improvement';
  }
}

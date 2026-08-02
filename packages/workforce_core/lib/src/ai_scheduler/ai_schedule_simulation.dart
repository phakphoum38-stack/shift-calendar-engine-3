import 'ai_schedule_proposal.dart';

final class AiScheduleSimulation {
  AiScheduleSimulation({required Iterable<AiScheduleProposal> proposals})
    : proposals = List.unmodifiable(proposals) {
    if (this.proposals.isEmpty) {
      throw ArgumentError.value(
        proposals,
        'proposals',
        'At least one proposal is required.',
      );
    }
  }

  final List<AiScheduleProposal> proposals;

  AiScheduleProposal get bestProposal {
    final ranked = List<AiScheduleProposal>.of(proposals)..sort(_compare);
    return ranked.first;
  }

  static int _compare(AiScheduleProposal left, AiScheduleProposal right) {
    final leftErrors = left.schedule.evaluation.validation.errors.length;
    final rightErrors = right.schedule.evaluation.validation.errors.length;
    final errorComparison = leftErrors.compareTo(rightErrors);
    if (errorComparison != 0) {
      return errorComparison;
    }

    final unassignedComparison = left.schedule.unassignedSlotIds.length
        .compareTo(right.schedule.unassignedSlotIds.length);
    if (unassignedComparison != 0) {
      return unassignedComparison;
    }

    return right.schedule.evaluation.overallScore.compareTo(
      left.schedule.evaluation.overallScore,
    );
  }
}

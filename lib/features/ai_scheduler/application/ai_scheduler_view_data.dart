final class AiSchedulerViewData {
  const AiSchedulerViewData({
    required this.score,
    required this.conflictCount,
    required this.fairnessLabel,
    required this.explanations,
    required this.requiresApproval,
    required this.isComplete,
  });

  final int score;
  final int conflictCount;
  final String fairnessLabel;
  final List<String> explanations;
  final bool requiresApproval;
  final bool isComplete;
}

final class RosterConstraintPolicy {
  const RosterConstraintPolicy({
    this.minimumRest = const Duration(hours: 8),
    this.maximumConsecutiveDays = 6,
    this.duplicateAssignmentsAreErrors = true,
  }) : assert(maximumConsecutiveDays > 0);

  final Duration minimumRest;
  final int maximumConsecutiveDays;
  final bool duplicateAssignmentsAreErrors;
}

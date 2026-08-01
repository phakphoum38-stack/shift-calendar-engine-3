final class RosterFairnessPolicy {
  const RosterFairnessPolicy({
    this.morningShiftCodes = const {'M', 'AM', 'MORNING'},
    this.afternoonShiftCodes = const {'A', 'PM', 'AFTERNOON'},
    this.nightShiftCodes = const {'N', 'NIGHT'},
    this.assignmentWeight = 60,
    this.nightWeight = 25,
    this.weekendWeight = 15,
  }) : assert(assignmentWeight >= 0),
       assert(nightWeight >= 0),
       assert(weekendWeight >= 0),
       assert(assignmentWeight + nightWeight + weekendWeight == 100);

  final Set<String> morningShiftCodes;
  final Set<String> afternoonShiftCodes;
  final Set<String> nightShiftCodes;
  final int assignmentWeight;
  final int nightWeight;
  final int weekendWeight;

  String normalizeShiftCode(String value) => value.trim().toUpperCase();
}

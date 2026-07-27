import '../../../domain/entities/shift_assignment.dart';

/// Prepared values displayed by the dashboard.
class DashboardSummary {
  const DashboardSummary({
    required this.todayAssignments,
    required this.tomorrowAssignments,
    required this.monthlyAssignmentCount,
    required this.estimatedIncome,
  });

  final List<ShiftAssignment> todayAssignments;
  final List<ShiftAssignment> tomorrowAssignments;
  final int monthlyAssignmentCount;
  final double estimatedIncome;
}

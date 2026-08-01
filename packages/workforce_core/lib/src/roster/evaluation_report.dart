import 'fairness_report.dart';
import 'roster_validation.dart';

final class RosterEvaluationReport {
  const RosterEvaluationReport({
    required this.validation,
    required this.fairness,
    required this.overallScore,
    this.recommendations = const [],
  });

  final RosterValidationResult validation;
  final RosterFairnessReport fairness;
  final int overallScore;
  final List<String> recommendations;

  bool get isValid => validation.isValid;
  bool get isExcellent => isValid && overallScore >= 90;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/application/ai_schedule_proposal_mapper.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  const mapper = AiScheduleProposalMapper();

  test('maps canonical proposal into deterministic view data', () {
    final proposal = AiScheduleProposal(
      schedule: const SchedulerResult(
        assignments: [],
        unassignedSlotIds: [],
        evaluation: RosterEvaluationReport(
          validation: RosterValidationResult(),
          fairness: RosterFairnessReport(
            score: 92,
            employeeSummaries: [],
            assignmentSpread: 0,
            nightSpread: 0,
            weekendSpread: 0,
          ),
          overallScore: 95,
        ),
      ),
      details: const [
        AiScheduleExplanation(
          code: 'balanced-proposal',
          kind: AiScheduleExplanationKind.fairness,
          message: 'Balanced proposal',
        ),
      ],
    );

    final result = mapper.map(proposal);

    expect(result.score, 95);
    expect(result.conflictCount, 0);
    expect(result.fairnessLabel, 'Excellent');
    expect(result.explanations, ['Balanced proposal']);
    expect(result.requiresApproval, isTrue);
    expect(result.isComplete, isTrue);
  });

  test('counts only validation errors as conflicts', () {
    final proposal = AiScheduleProposal(
      schedule: const SchedulerResult(
        assignments: [],
        unassignedSlotIds: ['slot-1'],
        evaluation: RosterEvaluationReport(
          validation: RosterValidationResult(
            violations: [
              RosterViolation(
                code: RosterViolationCode.insufficientRest,
                severity: RosterViolationSeverity.warning,
                message: 'Review rest window',
              ),
              RosterViolation(
                code: RosterViolationCode.overlappingAssignment,
                severity: RosterViolationSeverity.error,
                message: 'Overlap detected',
              ),
            ],
          ),
          fairness: RosterFairnessReport(
            score: 74,
            employeeSummaries: [],
            assignmentSpread: 2,
            nightSpread: 1,
            weekendSpread: 1,
          ),
          overallScore: 60,
        ),
      ),
      details: const [],
    );

    final result = mapper.map(proposal);

    expect(result.conflictCount, 1);
    expect(result.fairnessLabel, 'Fair');
    expect(result.isComplete, isFalse);
  });
}

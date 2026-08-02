import '../scheduler/scheduler_request.dart';
import '../scheduler/scheduler_result.dart';
import 'ai_schedule_explanation.dart';

abstract interface class AiSchedulerRuleEngine {
  List<AiScheduleExplanation> explain(
    SchedulerRequest request,
    SchedulerResult result,
  );
}

final class DefaultAiSchedulerRuleEngine implements AiSchedulerRuleEngine {
  const DefaultAiSchedulerRuleEngine();

  @override
  List<AiScheduleExplanation> explain(
    SchedulerRequest request,
    SchedulerResult result,
  ) {
    final existingIds = request.existingAssignments
        .map((item) => item.id)
        .toSet();
    final explanations = <AiScheduleExplanation>[];

    for (final assignment in result.assignments) {
      if (existingIds.contains(assignment.id)) {
        continue;
      }
      explanations.add(
        AiScheduleExplanation(
          code: 'assignment.selected',
          kind: AiScheduleExplanationKind.assignment,
          message:
              'Assigned ${assignment.employeeId} to ${assignment.shiftCode} '
              'after constraint validation and load balancing.',
          employeeId: assignment.employeeId,
          slotId: assignment.id.split('::').first,
        ),
      );
    }

    for (final slotId in result.unassignedSlotIds) {
      explanations.add(
        AiScheduleExplanation(
          code: 'assignment.unassigned',
          kind: AiScheduleExplanationKind.unassigned,
          message: 'Shift slot $slotId could not be assigned without '
              'violating the active rules.',
          slotId: slotId,
        ),
      );
    }

    final validation = result.evaluation.validation;
    explanations.add(
      AiScheduleExplanation(
        code: validation.isValid ? 'constraints.passed' : 'constraints.review',
        kind: AiScheduleExplanationKind.constraint,
        message: validation.isValid
            ? 'The proposal passes all active roster constraints.'
            : 'The proposal contains ${validation.violations.length} '
                'constraint findings that require review.',
      ),
    );

    explanations.add(
      AiScheduleExplanation(
        code: 'fairness.score',
        kind: AiScheduleExplanationKind.fairness,
        message: 'The evaluated schedule score is '
            '${result.evaluation.overallScore} out of 100.',
      ),
    );

    explanations.add(
      const AiScheduleExplanation(
        code: 'approval.required',
        kind: AiScheduleExplanationKind.approval,
        message: 'Human approval is required before this proposal is '
            'published or saved.',
      ),
    );

    return List.unmodifiable(explanations);
  }
}

import '../roster/constraint_pipeline.dart';
import '../roster/roster_validation.dart';
import '../roster/shift_assignment.dart';
import 'greedy_scheduler.dart';
import 'scheduler_engine.dart';
import 'scheduler_request.dart';
import 'scheduler_result.dart';

final class SchedulerInputException implements Exception {
  const SchedulerInputException(this.validation);

  final RosterValidationResult validation;

  @override
  String toString() {
    return 'SchedulerInputException(${validation.errors.length} errors)';
  }
}

final class SchedulerExecution {
  const SchedulerExecution({
    required this.result,
    required this.validation,
  });

  final SchedulerResult result;
  final RosterValidationResult validation;

  bool get canPublish => result.isComplete && validation.isValid;
}

final class SchedulerApi {
  const SchedulerApi({
    this.engine = const GreedyScheduler(),
    this.constraintPipeline = const RosterConstraintPipeline(),
  });

  final SchedulerEngine engine;
  final RosterConstraintPipeline constraintPipeline;

  SchedulerExecution generate(SchedulerRequest request) {
    final inputValidation = constraintPipeline.validate(
      RosterConstraintContext(
        assignments: request.existingAssignments,
        timeWindows: request.timeWindows,
      ),
    );
    if (!inputValidation.isValid) {
      throw SchedulerInputException(inputValidation);
    }

    final result = engine.generate(request);
    final finalAssignments = <ShiftAssignment>[
      ...request.existingAssignments,
      ...result.assignments,
    ];
    final finalValidation = constraintPipeline.validate(
      RosterConstraintContext(
        assignments: finalAssignments,
        timeWindows: request.timeWindows,
      ),
    );

    return SchedulerExecution(
      result: result,
      validation: finalValidation,
    );
  }
}

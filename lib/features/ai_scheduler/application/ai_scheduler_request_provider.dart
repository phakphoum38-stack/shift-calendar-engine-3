import 'package:workforce_core/workforce_core.dart' as core;

import '../../../core/result/result.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/repositories/employee_repository.dart';
import 'ai_scheduler_request_factory.dart';

/// Loads canonical employees and builds an explicit scheduler request.
///
/// Requested shifts remain an explicit input. This provider never infers new
/// work from existing assignments or presentation state.
final class AiSchedulerRequestProvider {
  const AiSchedulerRequestProvider({
    required this.employeeRepository,
    this.factory = const AiSchedulerRequestFactory(),
  });

  final EmployeeRepository employeeRepository;
  final AiSchedulerRequestFactory factory;

  Future<core.SchedulerRequest> build({
    required Iterable<AiSchedulerShiftInput> requestedShifts,
    required Schedule schedule,
  }) async {
    final result = await employeeRepository.findAll(activeOnly: true);

    if (result case Success(value: final employees)) {
      return factory.build(
        employees: employees,
        requestedShifts: requestedShifts,
        schedule: schedule,
      );
    }

    final failure = result as Failure<List<Employee>>;
    throw AiSchedulerRequestLoadException(
      failure.message,
      cause: failure.cause,
    );
  }
}

final class AiSchedulerRequestLoadException implements Exception {
  const AiSchedulerRequestLoadException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'AiSchedulerRequestLoadException: $message';
}

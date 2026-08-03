import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/core/result/result.dart';
import 'package:shift_calendar_engine/domain/entities/department.dart';
import 'package:shift_calendar_engine/domain/entities/employee.dart';
import 'package:shift_calendar_engine/domain/entities/schedule.dart';
import 'package:shift_calendar_engine/domain/repositories/employee_repository.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/application/ai_scheduler_request_provider.dart';

void main() {
  test('loads active employees from the canonical repository', () async {
    final repository = _EmployeeRepository(
      const Success([
        Employee(
          id: 'employee-1',
          employeeCode: 'E001',
          firstName: 'Ada',
          lastName: 'Lovelace',
          department: Department(
            id: 'dep-1',
            code: 'RAD',
            name: 'Radiology',
          ),
          position: 'Technologist',
        ),
      ]),
    );
    final provider = AiSchedulerRequestProvider(
      employeeRepository: repository,
    );

    final request = await provider.build(
      requestedShifts: const [],
      schedule: Schedule(id: 'schedule-1', name: 'August'),
    );

    expect(repository.lastActiveOnly, isTrue);
    expect(request.employeeIds, const ['employee-1']);
    expect(request.slots, isEmpty);
  });

  test('surfaces repository failures without inventing a request', () async {
    final cause = StateError('offline');
    final provider = AiSchedulerRequestProvider(
      employeeRepository: _EmployeeRepository(
        NetworkFailure('Unable to load employees', cause: cause),
      ),
    );

    try {
      await provider.build(
        requestedShifts: const [],
        schedule: Schedule(id: 'schedule-1', name: 'August'),
      );
      fail('Expected AiSchedulerRequestLoadException');
    } on AiSchedulerRequestLoadException catch (error) {
      expect(error.message, 'Unable to load employees');
      expect(error.cause, same(cause));
    }
  });
}

final class _EmployeeRepository implements EmployeeRepository {
  _EmployeeRepository(this.result);

  final Result<List<Employee>> result;
  bool? lastActiveOnly;

  @override
  Future<Result<List<Employee>>> findAll({bool activeOnly = true}) async {
    lastActiveOnly = activeOnly;
    return result;
  }

  @override
  Future<Result<void>> delete(String id) =>
      throw UnsupportedError('Not used by this test');

  @override
  Future<Result<Employee?>> findById(String id) =>
      throw UnsupportedError('Not used by this test');

  @override
  Future<Result<Employee>> save(Employee employee) =>
      throw UnsupportedError('Not used by this test');

  @override
  Future<Result<List<Employee>>> search(EmployeeQuery query) =>
      throw UnsupportedError('Not used by this test');
}

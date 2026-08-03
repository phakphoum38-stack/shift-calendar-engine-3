import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/core/result/result.dart';
import 'package:shift_calendar_engine/domain/entities/employee.dart';
import 'package:shift_calendar_engine/domain/entities/schedule.dart';
import 'package:shift_calendar_engine/domain/entities/shift_template.dart';
import 'package:shift_calendar_engine/domain/repositories/employee_repository.dart';
import 'package:shift_calendar_engine/domain/repositories/shift_template_repository.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/application/ai_scheduler_controller.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/application/ai_scheduler_request_provider.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/presentation/ai_scheduler_runtime.dart';
import 'package:shift_calendar_engine/features/shift_templates/application/shift_template_controller.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  testWidgets('loads templates once and exposes only active templates', (
    tester,
  ) async {
    final repository = _ShiftTemplateRepository([
      _template(id: 'active', code: 'A', name: 'Active shift'),
      _template(
        id: 'inactive',
        code: 'I',
        name: 'Inactive shift',
        active: false,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiSchedulerRuntime(
            controller: AiSchedulerController(
              assistant: const _NoopAssistant(),
            ),
            requestProvider: AiSchedulerRequestProvider(
              employeeRepository: _EmployeeRepository(),
            ),
            schedule: Schedule(id: 'schedule-1', name: 'August'),
            shiftTemplateControllerFactory: () =>
                ShiftTemplateController(repository: repository),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.findAllCalls, 1);
    expect(find.text('Add shift'), findsOneWidget);

    await tester.tap(find.text('Add shift'));
    await tester.pumpAndSettle();

    expect(find.text('A — Active shift'), findsOneWidget);
    expect(find.text('I — Inactive shift'), findsNothing);
  });
}

ShiftTemplate _template({
  required String id,
  required String code,
  required String name,
  bool active = true,
}) {
  return ShiftTemplate(
    id: id,
    code: code,
    name: name,
    startTime: const Duration(hours: 8),
    endTime: const Duration(hours: 16),
    colorValue: 0,
    workingHours: 8,
    active: active,
  );
}

final class _ShiftTemplateRepository implements ShiftTemplateRepository {
  _ShiftTemplateRepository(this.templates);

  final List<ShiftTemplate> templates;
  int findAllCalls = 0;

  @override
  Future<Result<List<ShiftTemplate>>> findAll({bool activeOnly = true}) async {
    findAllCalls += 1;
    return Success(templates);
  }

  @override
  Future<Result<ShiftTemplate>> save(ShiftTemplate template) async {
    return Success(template);
  }

  @override
  Future<Result<void>> delete(String id) async => const Success(null);
}

final class _EmployeeRepository implements EmployeeRepository {
  @override
  Future<Result<List<Employee>>> findAll({bool activeOnly = true}) async {
    return const Success([]);
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

final class _NoopAssistant implements AiSchedulerAssistant {
  const _NoopAssistant();

  @override
  AiScheduleProposal propose(SchedulerRequest request) {
    return const AiScheduleProposal(
      schedule: SchedulerResult(
        assignments: [],
        unassignedSlotIds: [],
        evaluation: RosterEvaluationReport(
          validation: RosterValidationResult(),
          fairness: RosterFairnessReport(
            score: 100,
            employeeSummaries: [],
            assignmentSpread: 0,
            nightSpread: 0,
            weekendSpread: 0,
          ),
          overallScore: 100,
        ),
      ),
    );
  }
}

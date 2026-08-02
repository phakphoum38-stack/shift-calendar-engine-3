import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/core/result/result.dart';
import 'package:shift_calendar_engine/domain/entities/employee.dart';
import 'package:shift_calendar_engine/domain/entities/schedule.dart';
import 'package:shift_calendar_engine/domain/repositories/employee_repository.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/application/ai_scheduler_controller.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/application/ai_scheduler_request_provider.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/presentation/ai_scheduler_workspace.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  testWidgets('loads a canonical request before generating a proposal', (
    tester,
  ) async {
    final repository = _EmployeeRepository(const Success([]));
    final controller = AiSchedulerController(
      assistant: _FakeAssistant(_proposal()),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiSchedulerWorkspace(
            controller: controller,
            requestProvider: AiSchedulerRequestProvider(
              employeeRepository: repository,
            ),
            schedule: Schedule(id: 'schedule-1', name: 'August'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Generate proposal').first);
    await tester.pumpAndSettle();

    expect(repository.lastActiveOnly, isTrue);
    expect(find.text('95'), findsOneWidget);
    expect(find.text('Balanced proposal'), findsOneWidget);
  });

  testWidgets('shows a generation failure without creating a proposal', (
    tester,
  ) async {
    final controller = AiSchedulerController(
      assistant: const _ThrowingAssistant(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiSchedulerWorkspace(
            controller: controller,
            requestProvider: AiSchedulerRequestProvider(
              employeeRepository: _EmployeeRepository(const Success([])),
            ),
            schedule: Schedule(id: 'schedule-1', name: 'August'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Generate proposal').first);
    await tester.pumpAndSettle();

    expect(find.text('สร้างข้อเสนอไม่สำเร็จ'), findsOneWidget);
    expect(find.textContaining('generation failed'), findsOneWidget);
    expect(controller.proposal, isNull);
  });

  testWidgets('shows canonical repository failures without generating', (
    tester,
  ) async {
    final controller = AiSchedulerController(
      assistant: _FakeAssistant(_proposal()),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiSchedulerWorkspace(
            controller: controller,
            requestProvider: AiSchedulerRequestProvider(
              employeeRepository: _EmployeeRepository(
                const NetworkFailure('employee service unavailable'),
              ),
            ),
            schedule: Schedule(id: 'schedule-1', name: 'August'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Generate proposal').first);
    await tester.pumpAndSettle();

    expect(find.text('สร้างข้อเสนอไม่สำเร็จ'), findsOneWidget);
    expect(find.textContaining('employee service unavailable'), findsOneWidget);
    expect(controller.proposal, isNull);
  });
}

AiScheduleProposal _proposal() {
  return AiScheduleProposal(
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
        code: 'balanced',
        kind: AiScheduleExplanationKind.fairness,
        message: 'Balanced proposal',
      ),
    ],
  );
}

final class _FakeAssistant implements AiSchedulerAssistant {
  const _FakeAssistant(this.proposal);

  final AiScheduleProposal proposal;

  @override
  AiScheduleProposal propose(SchedulerRequest request) => proposal;
}

final class _ThrowingAssistant implements AiSchedulerAssistant {
  const _ThrowingAssistant();

  @override
  AiScheduleProposal propose(SchedulerRequest request) {
    throw StateError('generation failed');
  }
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

import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/app/ai_scheduler_dependencies.dart';
import 'package:shift_calendar_engine/app/app_dependencies.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/application/ai_scheduler_controller.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/application/ai_scheduler_request_factory.dart';
import 'package:shift_calendar_engine/features/ai_scheduler/application/ai_scheduler_request_provider.dart';
import 'package:workforce_core/workforce_core.dart';

void main() {
  test('composition helpers inject the canonical assistant', () {
    final dependencies = AppDependencies();
    final assistant = _RecordingAssistant(_proposal());
    final controller = dependencies.createAiSchedulerController(assistant);
    final request = SchedulerRequest(
      employeeIds: const ['employee-1'],
      slots: const [],
    );

    controller.generate(request);

    expect(controller, isA<AiSchedulerController>());
    expect(controller.status, AiSchedulerStatus.ready);
    expect(controller.proposal?.score, 95);
    expect(assistant.lastRequest, same(request));
  });

  test('default composition uses the deterministic canonical scheduler', () {
    final dependencies = AppDependencies();
    final controller = dependencies.createDefaultAiSchedulerController();
    final request = SchedulerRequest(
      employeeIds: const ['employee-1'],
      slots: [
        SchedulerShiftSlot(
          id: 'slot-1',
          shiftCode: 'M',
          startsAt: DateTime(2026, 8, 3, 8),
          endsAt: DateTime(2026, 8, 3, 16),
        ),
      ],
    );

    controller.generate(request);

    expect(controller.status, AiSchedulerStatus.ready);
    expect(controller.error, isNull);
    expect(controller.proposal, isNotNull);
    expect(controller.proposal!.conflictCount, 0);
    expect(controller.proposal!.isComplete, isTrue);
  });

  test('composition helpers expose the canonical request boundary', () {
    final dependencies = AppDependencies();

    final factory = dependencies.createAiSchedulerRequestFactory();

    expect(factory, isA<AiSchedulerRequestFactory>());
  });

  test('request provider uses the configured canonical employee repository', () {
    final dependencies = AppDependencies();

    final provider = dependencies.createAiSchedulerRequestProvider();

    expect(provider, isA<AiSchedulerRequestProvider>());
    expect(provider.employeeRepository, same(dependencies.employeeRepository));
    expect(provider.factory, isA<AiSchedulerRequestFactory>());
  });
}

AiScheduleProposal _proposal() {
  return AiScheduleProposal(
    schedule: SchedulerResult(
      assignments: const [],
      unassignedSlotIds: const [],
      evaluation: RosterEvaluationReport(
        validation: RosterValidationResult(),
        fairness: const RosterFairnessReport(
          score: 92,
          employeeSummaries: [],
          assignmentSpread: 0,
          nightSpread: 0,
          weekendSpread: 0,
        ),
        overallScore: 95,
      ),
    ),
    details: const [],
  );
}

final class _RecordingAssistant implements AiSchedulerAssistant {
  _RecordingAssistant(this.proposal);

  final AiScheduleProposal proposal;
  SchedulerRequest? lastRequest;

  @override
  AiScheduleProposal propose(SchedulerRequest request) {
    lastRequest = request;
    return proposal;
  }
}

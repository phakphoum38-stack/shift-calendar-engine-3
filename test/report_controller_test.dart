import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/app/app_dependencies.dart';
import 'package:shift_calendar_engine/domain/entities/schedule.dart';
import 'package:shift_calendar_engine/features/reports/application/report_controller.dart';
import 'package:shift_calendar_engine/features/reports/application/report_service.dart';
import 'package:shift_calendar_engine/features/reports/domain/monthly_roster_report.dart';

import 'support/fixtures.dart';

void main() {
  test(
    'controller generates, prints, and shares through injected boundaries',
    () async {
      final service = _FakeReportService();
      final gateway = _FakeOutputGateway();
      final controller = ReportController(
        schedule: canonicalScheduleFixture(),
        reportService: service,
        outputGateway: gateway,
        initialOptions: MonthlyRosterReportOptions(
          month: DateTime(2027, 4),
          language: ReportLanguage.english,
        ),
        clock: () => DateTime(2027, 4, 1),
      );
      addTearDown(controller.dispose);

      expect(await controller.generate(), isTrue);
      expect(controller.status, ReportStatus.ready);
      expect(controller.fileName, 'shift_schedule_2027_04.pdf');
      expect(await controller.printReport(), isTrue);
      expect(await controller.shareReport(), isTrue);
      expect(service.calls, 1);
      expect(gateway.printCalls, 1);
      expect(gateway.shareCalls, 1);
    },
  );

  test('cancellation is not reported as output success', () async {
    final controller = ReportController(
      schedule: canonicalScheduleFixture(),
      reportService: _FakeReportService(),
      outputGateway: _FakeOutputGateway(completes: false),
      initialOptions: MonthlyRosterReportOptions(
        month: DateTime(2027, 4),
        language: ReportLanguage.english,
      ),
    );
    addTearDown(controller.dispose);

    expect(await controller.printReport(), isFalse);
    expect(controller.status, ReportStatus.ready);
  });

  test('composition root allows report boundary replacement', () {
    final service = _FakeReportService();
    final gateway = _FakeOutputGateway();
    final dependencies = AppDependencies(
      reportServiceOverride: service,
      reportOutputGateway: gateway,
    );

    final controller = dependencies.createReportController(
      canonicalScheduleFixture(),
      MonthlyRosterReportOptions(
        month: DateTime(2027, 4),
        language: ReportLanguage.thai,
      ),
    );
    addTearDown(controller.dispose);

    expect(controller.reportService, same(service));
    expect(controller.outputGateway, same(gateway));
  });
}

class _FakeReportService implements MonthlyRosterReportService {
  int calls = 0;

  @override
  Future<Uint8List> generate({
    required Schedule schedule,
    required MonthlyRosterReportOptions options,
    required DateTime generatedAt,
  }) async {
    calls++;
    return Uint8List.fromList([37, 80, 68, 70, 45]);
  }
}

class _FakeOutputGateway implements ReportOutputGateway {
  _FakeOutputGateway({this.completes = true});

  final bool completes;
  int printCalls = 0;
  int shareCalls = 0;

  @override
  Future<bool> printPdf(Uint8List bytes, {required String documentName}) async {
    printCalls++;
    return completes;
  }

  @override
  Future<bool> sharePdf(Uint8List bytes, {required String fileName}) async {
    shareCalls++;
    return completes;
  }
}

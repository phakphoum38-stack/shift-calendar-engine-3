import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/features/reports/application/monthly_roster_report_mapper.dart';
import 'package:shift_calendar_engine/features/reports/domain/monthly_roster_report.dart';
import 'package:shift_calendar_engine/features/reports/infrastructure/monthly_roster_pdf_service.dart';

import 'support/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('A4 PDF generation supports Thai canonical data', () async {
    final service = MonthlyRosterPdfService(
      mapper: const MonthlyRosterReportMapper(),
    );

    final bytes = await service.generate(
      schedule: canonicalScheduleFixture(),
      options: MonthlyRosterReportOptions(
        month: DateTime(2027, 4),
        language: ReportLanguage.thai,
      ),
      generatedAt: DateTime(2027, 4, 1, 9, 30),
    );

    expect(bytes.length, greaterThan(1000));
    expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
  });

  test('empty English report still produces valid PDF', () async {
    final schedule = canonicalScheduleFixture();
    final service = MonthlyRosterPdfService(
      mapper: const MonthlyRosterReportMapper(),
    );

    final bytes = await service.generate(
      schedule: schedule,
      options: MonthlyRosterReportOptions(
        month: DateTime(2030, 1),
        language: ReportLanguage.english,
      ),
      generatedAt: DateTime(2030, 1, 1),
    );

    expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
  });
}

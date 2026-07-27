import 'dart:typed_data';

import '../../../domain/entities/schedule.dart';
import '../domain/monthly_roster_report.dart';

/// Generates a printable monthly report from the canonical schedule.
abstract interface class MonthlyRosterReportService {
  Future<Uint8List> generate({
    required Schedule schedule,
    required MonthlyRosterReportOptions options,
    required DateTime generatedAt,
  });
}

/// Boundary for platform print and share operations.
abstract interface class ReportOutputGateway {
  Future<bool> printPdf(Uint8List bytes, {required String documentName});

  Future<bool> sharePdf(Uint8List bytes, {required String fileName});
}

import 'package:flutter/foundation.dart';

import '../../../domain/entities/schedule.dart';
import '../domain/monthly_roster_report.dart';
import 'report_service.dart';

/// Explicit report workflow states exposed to presentation.
enum ReportStatus {
  idle,
  preparing,
  ready,
  printing,
  sharing,
  success,
  failure,
}

/// Coordinates report generation and platform output without owning schedule.
class ReportController extends ChangeNotifier {
  ReportController({
    required this.schedule,
    required this.reportService,
    required this.outputGateway,
    required MonthlyRosterReportOptions initialOptions,
    DateTime Function()? clock,
  }) : options = initialOptions,
       clock = clock ?? DateTime.now;

  final Schedule schedule;
  final MonthlyRosterReportService reportService;
  final ReportOutputGateway outputGateway;
  final DateTime Function() clock;

  MonthlyRosterReportOptions options;
  ReportStatus status = ReportStatus.idle;
  Uint8List? bytes;
  String? error;

  bool get busy =>
      status == ReportStatus.preparing ||
      status == ReportStatus.printing ||
      status == ReportStatus.sharing;

  String get fileName {
    final year = options.month.year.toString().padLeft(4, '0');
    final month = options.month.month.toString().padLeft(2, '0');
    return 'shift_schedule_${year}_$month.pdf';
  }

  void updateOptions(MonthlyRosterReportOptions value) {
    options = value;
    bytes = null;
    error = null;
    status = ReportStatus.idle;
    notifyListeners();
  }

  Future<bool> generate() async {
    _setStatus(ReportStatus.preparing);
    try {
      bytes = await reportService.generate(
        schedule: schedule,
        options: options,
        generatedAt: clock(),
      );
      if (bytes!.isEmpty) throw StateError('Generated PDF is empty.');
      _setStatus(ReportStatus.ready);
      return true;
    } catch (exception) {
      error = 'Unable to generate the report.';
      _setStatus(ReportStatus.failure);
      return false;
    }
  }

  Future<bool> printReport() async {
    if (bytes == null && !await generate()) return false;
    _setStatus(ReportStatus.printing);
    try {
      final completed = await outputGateway.printPdf(
        bytes!,
        documentName: fileName,
      );
      _setStatus(completed ? ReportStatus.success : ReportStatus.ready);
      return completed;
    } catch (exception) {
      error = 'Unable to print the report.';
      _setStatus(ReportStatus.failure);
      return false;
    }
  }

  Future<bool> shareReport() async {
    if (bytes == null && !await generate()) return false;
    _setStatus(ReportStatus.sharing);
    try {
      final completed = await outputGateway.sharePdf(
        bytes!,
        fileName: fileName,
      );
      _setStatus(completed ? ReportStatus.success : ReportStatus.ready);
      return completed;
    } catch (exception) {
      error = 'Unable to share the report.';
      _setStatus(ReportStatus.failure);
      return false;
    }
  }

  void _setStatus(ReportStatus value) {
    status = value;
    notifyListeners();
  }
}

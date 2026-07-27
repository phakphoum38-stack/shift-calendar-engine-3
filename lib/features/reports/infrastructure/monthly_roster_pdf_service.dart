import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/schedule.dart';
import '../application/monthly_roster_report_mapper.dart';
import '../application/report_service.dart';
import '../domain/monthly_roster_report.dart';

/// A4 landscape PDF renderer using the bundled OFL Noto Sans Thai font.
class MonthlyRosterPdfService implements MonthlyRosterReportService {
  MonthlyRosterPdfService({
    required this.mapper,
    Future<ByteData> Function(String key)? loadAsset,
  }) : loadAsset = loadAsset ?? rootBundle.load;

  final MonthlyRosterReportMapper mapper;
  final Future<ByteData> Function(String key) loadAsset;

  @override
  Future<Uint8List> generate({
    required Schedule schedule,
    required MonthlyRosterReportOptions options,
    required DateTime generatedAt,
  }) async {
    final report = mapper.map(schedule, options);
    final locale = options.language == ReportLanguage.thai ? 'th' : 'en';
    await initializeDateFormatting(locale);
    final fontData = await loadAsset('assets/fonts/NotoSansThai.ttf');
    final font = pw.Font.ttf(fontData);
    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: font),
    );
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(18),
        header: (context) => _header(report, generatedAt),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 7),
          ),
        ),
        build: (context) => [
          if (report.rows.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 36),
              child: pw.Center(child: pw.Text(report.labels.noData)),
            )
          else
            _scheduleTable(report),
          if (report.options.includeLegend && report.legend.isNotEmpty)
            _legend(report),
          if (report.options.includeSummary) _summary(report),
          if (report.notes.isNotEmpty) _notes(report),
          _signatures(report),
        ],
      ),
    );
    return document.save();
  }

  pw.Widget _header(MonthlyRosterReport report, DateTime generatedAt) {
    final locale = report.options.language == ReportLanguage.thai ? 'th' : 'en';
    final month = DateFormat.yMMMM(locale).format(report.month);
    final generated = DateFormat.yMd(locale).add_Hm().format(generatedAt);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            report.labels.title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '${report.scheduleName} · $month',
            style: const pw.TextStyle(fontSize: 9),
          ),
          if (report.departmentName != null)
            pw.Text(
              '${report.labels.department}: ${report.departmentName}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          pw.Text(
            '${report.labels.generatedAt}: $generated',
            style: const pw.TextStyle(fontSize: 7),
          ),
        ],
      ),
    );
  }

  pw.Widget _scheduleTable(MonthlyRosterReport report) {
    final border = pw.TableBorder.all(color: PdfColors.grey600, width: 0.35);
    final employeeWidth = 106.0;
    return pw.Table(
      border: border,
      columnWidths: {
        0: pw.FixedColumnWidth(employeeWidth),
        for (var index = 0; index < report.dates.length; index++)
          index + 1: const pw.FlexColumnWidth(),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          repeat: true,
          children: [
            _tableText(report.labels.employee, bold: true, alignLeft: true),
            for (final date in report.dates)
              _tableText(
                '${date.day}\n${_weekday(date, report.options.language)}',
                bold: true,
              ),
          ],
        ),
        for (final row in report.rows)
          pw.TableRow(
            children: [
              _tableText(
                '${row.employeeName}\n${row.position} · ${row.departmentName}',
                alignLeft: true,
              ),
              for (final cell in row.cells)
                pw.Container(
                  color: cell.holidayName != null
                      ? PdfColors.grey300
                      : cell.isWeekend
                      ? PdfColors.grey100
                      : null,
                  child: _tableText(cell.displayValue),
                ),
            ],
          ),
      ],
    );
  }

  pw.Widget _tableText(
    String value, {
    bool bold = false,
    bool alignLeft = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 1.5, vertical: 2),
      child: pw.Text(
        value,
        textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center,
        maxLines: 3,
        style: pw.TextStyle(
          fontSize: 5.5,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _legend(MonthlyRosterReport report) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10),
      child: pw.Wrap(
        spacing: 10,
        runSpacing: 3,
        children: [
          pw.Text(
            '${report.labels.legend}:',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
          for (final entry in report.legend)
            pw.Text(
              '${entry.code} = ${entry.name}',
              style: const pw.TextStyle(fontSize: 8),
            ),
        ],
      ),
    );
  }

  pw.Widget _summary(MonthlyRosterReport report) {
    final statistics = report.statistics;
    final shifts = statistics.assignmentsByShift.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(' · ');
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            report.labels.summary,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '${report.labels.totalEmployees}: ${statistics.employeeCount} · '
            '${report.labels.totalAssignments}: '
            '${statistics.assignmentCount}',
            style: const pw.TextStyle(fontSize: 8),
          ),
          if (shifts.isNotEmpty)
            pw.Text(shifts, style: const pw.TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  pw.Widget _notes(MonthlyRosterReport report) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 8),
    child: pw.Text(
      '${report.labels.notes}: ${report.notes.join(' · ')}',
      style: const pw.TextStyle(fontSize: 8),
    ),
  );

  pw.Widget _signatures(MonthlyRosterReport report) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 20),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _signature(report.labels.preparedBy),
        _signature(report.labels.checkedBy),
        _signature(report.labels.approvedBy),
      ],
    ),
  );

  pw.Widget _signature(String label) => pw.SizedBox(
    width: 150,
    child: pw.Column(
      children: [
        pw.Container(
          height: 18,
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
          ),
        ),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
      ],
    ),
  );

  String _weekday(DateTime date, ReportLanguage language) {
    const english = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const thai = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
    return (language == ReportLanguage.thai ? thai : english)[date.weekday - 1];
  }
}

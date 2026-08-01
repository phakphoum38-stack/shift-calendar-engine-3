import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../domain/entities/schedule.dart';
import '../../../l10n/l10n.dart';
import '../../../l10n/localized_date_format.dart';
import '../application/report_controller.dart';
import '../domain/monthly_roster_report.dart';

/// Canonical monthly A4 report options, preview, print, and share surface.
class ReportsPage extends StatefulWidget {
  const ReportsPage({
    required this.schedule,
    required this.controllerFactory,
    super.key,
  });

  final Schedule schedule;
  final ReportController Function(
    Schedule schedule,
    MonthlyRosterReportOptions options,
  )
  controllerFactory;

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  ReportController? controller;
  ReportLanguage? language;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextLanguage = Localizations.localeOf(context).languageCode == 'th'
        ? ReportLanguage.thai
        : ReportLanguage.english;
    if (controller == null) {
      language = nextLanguage;
      controller = widget.controllerFactory(
        widget.schedule,
        MonthlyRosterReportOptions(
          month: _initialMonth(widget.schedule),
          language: nextLanguage,
        ),
      )..addListener(_refresh);
    } else if (language != nextLanguage) {
      language = nextLanguage;
      controller!.updateOptions(
        controller!.options.copyWith(language: nextLanguage),
      );
    }
  }

  @override
  void didUpdateWidget(covariant ReportsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schedule != widget.schedule) {
      _replaceController();
    }
  }

  @override
  void dispose() {
    controller
      ?..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = controller!;
    final months = widget.schedule.months
        .map((entry) => entry.month)
        .toList(growable: false);
    final departments = {
      for (final assignment in widget.schedule.assignments)
        assignment.employee.department.id: assignment.employee.department.name,
    };
    final sortedDepartments = departments.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.reportCenter,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownMenu<DateTime>(
                  width: 220,
                  label: Text(context.l10n.reportMonth),
                  initialSelection: value.options.month,
                  dropdownMenuEntries: [
                    for (final month in months)
                      DropdownMenuEntry(
                        value: month,
                        label: formatLocalizedDate(
                          DateFormat.yMMMM(
                            Localizations.localeOf(context).toLanguageTag(),
                          ),
                          month,
                          locale: Localizations.localeOf(
                            context,
                          ).toLanguageTag(),
                        ),
                      ),
                  ],
                  onSelected: (month) {
                    if (month != null) {
                      value.updateOptions(value.options.copyWith(month: month));
                    }
                  },
                ),
                DropdownMenu<String?>(
                  width: 220,
                  label: Text(context.l10n.departmentName),
                  initialSelection: value.options.departmentId,
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                      value: null,
                      label: context.l10n.allDepartments,
                    ),
                    for (final department in sortedDepartments)
                      DropdownMenuEntry(
                        value: department.key,
                        label: department.value,
                      ),
                  ],
                  onSelected: (departmentId) => value.updateOptions(
                    value.options.copyWith(
                      departmentId: departmentId,
                      clearDepartment: departmentId == null,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: value.busy
                      ? null
                      : () => unawaited(value.generate()),
                  icon: const Icon(Icons.preview_outlined),
                  label: Text(context.l10n.previewReport),
                ),
                OutlinedButton.icon(
                  onPressed: value.busy
                      ? null
                      : () => unawaited(value.printReport()),
                  icon: const Icon(Icons.print_outlined),
                  label: Text(context.l10n.printReport),
                ),
                OutlinedButton.icon(
                  onPressed: value.busy
                      ? null
                      : () => unawaited(value.shareReport()),
                  icon: const Icon(Icons.share_outlined),
                  label: Text(context.l10n.sharePdf),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (value.busy) const LinearProgressIndicator(),
            if (value.status == ReportStatus.failure)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  context.l10n.reportGenerationError,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: value.bytes == null
                  ? _ReportEmptyState(
                      hasSchedule: widget.schedule.assignments.isNotEmpty,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: PdfPreview(
                        key: ValueKey(
                          '${value.options.month.year}-'
                          '${value.options.month.month}-'
                          '${value.options.departmentId}-'
                          '${value.options.language.name}',
                        ),
                        build: (_) async => value.bytes!,
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        allowPrinting: false,
                        allowSharing: false,
                        pdfFileName: value.fileName,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _replaceController() {
    final previous = controller!;
    previous.removeListener(_refresh);
    previous.dispose();
    controller = widget.controllerFactory(
      widget.schedule,
      MonthlyRosterReportOptions(
        month: _initialMonth(widget.schedule),
        language: language ?? ReportLanguage.english,
      ),
    )..addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  DateTime _initialMonth(Schedule schedule) =>
      schedule.months.isEmpty ? DateTime.now() : schedule.months.first.month;
}

class _ReportEmptyState extends StatelessWidget {
  const _ReportEmptyState({required this.hasSchedule});

  final bool hasSchedule;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.picture_as_pdf_outlined, size: 56),
        const SizedBox(height: 12),
        Text(
          hasSchedule
              ? context.l10n.previewReportDescription
              : context.l10n.noReports,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

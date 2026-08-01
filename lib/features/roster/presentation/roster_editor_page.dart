import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/employee.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/entities/shift_assignment.dart';
import '../../../domain/entities/shift_template.dart';
import '../../../l10n/l10n.dart';
import '../../../l10n/localized_date_format.dart';
import '../application/roster_editor_controller.dart';

/// Explicit preview-and-save editor for canonical assignments.
class RosterEditorPage extends StatefulWidget {
  const RosterEditorPage({
    required this.schedule,
    required this.controllerFactory,
    required this.onSaved,
    super.key,
  });

  final Schedule schedule;
  final RosterEditorController Function(Schedule) controllerFactory;
  final ValueChanged<Schedule> onSaved;

  @override
  State<RosterEditorPage> createState() => _RosterEditorPageState();
}

class _RosterEditorPageState extends State<RosterEditorPage> {
  late final RosterEditorController controller = widget.controllerFactory(
    widget.schedule,
  );

  @override
  void initState() {
    super.initState();
    unawaited(controller.loadCatalogs());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.manualRosterEditor),
        actions: [
          TextButton.icon(
            onPressed: controller.loading ? null : _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(context.l10n.save),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            controller.loading ||
                controller.employees.isEmpty ||
                controller.shifts.isEmpty
            ? null
            : _add,
        icon: const Icon(Icons.add),
        label: Text(context.l10n.addAssignment),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (controller.loading) const LinearProgressIndicator(),
          if (controller.error case final error?)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (controller.employees.isEmpty || controller.shifts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(context.l10n.catalogRequired),
              ),
            ),
          for (final month in controller.schedule.months)
            for (final day in month.days.where(
              (value) => value.assignments.isNotEmpty,
            ))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      formatLocalizedDate(
                        DateFormat.yMMMMEEEEd(
                          Localizations.localeOf(context).toLanguageTag(),
                        ),
                        day.date,
                        locale: Localizations.localeOf(context).toLanguageTag(),
                      ),
                    ),
                    children: [
                      for (final assignment in day.assignments)
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(assignment.shift.colorValue),
                            child: Text(assignment.shift.code),
                          ),
                          title: Text(assignment.employee.displayName),
                          subtitle: Text(
                            [
                              assignment.location,
                              assignment.remark,
                            ].whereType<String>().join(' • '),
                          ),
                          trailing: IconButton(
                            tooltip: context.l10n.delete,
                            onPressed: () => _delete(day.date, assignment),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    ),
  );

  Future<void> _add() async {
    final value = await showDialog<_AssignmentDraft>(
      context: context,
      builder: (context) => _AssignmentDialog(
        employees: controller.employees,
        shifts: controller.shifts,
      ),
    );
    if (value == null || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.previewChanges),
        content: ListTile(
          leading: CircleAvatar(child: Text(value.shift.code)),
          title: Text(value.employee.displayName),
          subtitle: Text(
            formatLocalizedDate(
              DateFormat.yMMMMEEEEd(
                Localizations.localeOf(context).toLanguageTag(),
              ),
              value.date,
              locale: Localizations.localeOf(context).toLanguageTag(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    controller.addAssignment(
      value.date,
      ShiftAssignment(
        id:
            '${value.date.toIso8601String()}:'
            '${value.employee.id}:${value.shift.id}',
        employee: value.employee,
        shift: value.shift,
        location: value.location,
        remark: value.remark,
      ),
    );
  }

  Future<void> _delete(DateTime date, ShiftAssignment assignment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.previewChanges),
        content: Text(
          '${context.l10n.delete}: '
          '${assignment.employee.displayName} • ${assignment.shift.code}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      controller.deleteAssignment(date, assignment.id);
    }
  }

  Future<void> _save() async {
    if (!await controller.save() || !mounted) return;
    widget.onSaved(controller.schedule);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.scheduleSaved)));
  }
}

class _AssignmentDraft {
  const _AssignmentDraft({
    required this.date,
    required this.employee,
    required this.shift,
    this.location,
    this.remark,
  });

  final DateTime date;
  final Employee employee;
  final ShiftTemplate shift;
  final String? location;
  final String? remark;
}

class _AssignmentDialog extends StatefulWidget {
  const _AssignmentDialog({required this.employees, required this.shifts});

  final List<Employee> employees;
  final List<ShiftTemplate> shifts;

  @override
  State<_AssignmentDialog> createState() => _AssignmentDialogState();
}

class _AssignmentDialogState extends State<_AssignmentDialog> {
  late DateTime date = DateTime.now();
  late Employee employee = widget.employees.first;
  late ShiftTemplate shift = widget.shifts.first;
  final location = TextEditingController();
  final remark = TextEditingController();

  @override
  void dispose() {
    location.dispose();
    remark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.addAssignment),
    content: SizedBox(
      width: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.event_outlined),
            label: Text(
              formatLocalizedDate(
                DateFormat.yMMMMEEEEd(
                  Localizations.localeOf(context).toLanguageTag(),
                ),
                date,
                locale: Localizations.localeOf(context).toLanguageTag(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Employee>(
            initialValue: employee,
            isExpanded: true,
            decoration: InputDecoration(labelText: context.l10n.employee),
            items: [
              for (final value in widget.employees)
                DropdownMenuItem(value: value, child: Text(value.displayName)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => employee = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ShiftTemplate>(
            initialValue: shift,
            isExpanded: true,
            decoration: InputDecoration(labelText: context.l10n.shift),
            items: [
              for (final value in widget.shifts)
                DropdownMenuItem(
                  value: value,
                  child: Text('${value.code} — ${value.name}'),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => shift = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: location,
            decoration: InputDecoration(labelText: context.l10n.location),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: remark,
            decoration: InputDecoration(labelText: context.l10n.remark),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(
          context,
          _AssignmentDraft(
            date: date,
            employee: employee,
            shift: shift,
            location: location.text.trim().isEmpty
                ? null
                : location.text.trim(),
            remark: remark.text.trim().isEmpty ? null : remark.text.trim(),
          ),
        ),
        child: Text(context.l10n.confirm),
      ),
    ],
  );

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(date.year - 2),
      lastDate: DateTime(date.year + 3),
      initialDate: date,
    );
    if (value != null) setState(() => date = value);
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/entities/shift_template.dart';
import '../../../l10n/l10n.dart';
import '../application/shift_template_controller.dart';

/// Persistent Material 3 shift-template editor.
class ShiftTemplatesPage extends StatefulWidget {
  const ShiftTemplatesPage({required this.controllerFactory, super.key});

  final ShiftTemplateController Function() controllerFactory;

  @override
  State<ShiftTemplatesPage> createState() => _ShiftTemplatesPageState();
}

class _ShiftTemplatesPageState extends State<ShiftTemplatesPage> {
  late final ShiftTemplateController controller = widget.controllerFactory();

  @override
  void initState() {
    super.initState();
    unawaited(controller.load());
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
      appBar: AppBar(title: Text(context.l10n.shiftTemplates)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.loading ? null : () => _edit(),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.addShiftTemplate),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(context.l10n.shiftTemplatesDescription),
          if (controller.loading) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (controller.error case final error?) ...[
            const SizedBox(height: 12),
            Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          for (final template in controller.templates)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(template.colorValue),
                    child: Text(template.code),
                  ),
                  title: Text(template.name),
                  subtitle: Text(
                    '${_time(template.startTime)}–${_time(template.endTime)}'
                    ' • ${template.workingHours.toStringAsFixed(1)} h'
                    ' • ${template.rate.toStringAsFixed(0)}',
                  ),
                  trailing: PopupMenuButton<_TemplateAction>(
                    onSelected: (action) {
                      if (action == _TemplateAction.edit) {
                        unawaited(_edit(template));
                      } else {
                        unawaited(controller.deactivate(template));
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _TemplateAction.edit,
                        child: Text(context.l10n.editShiftTemplate),
                      ),
                      PopupMenuItem(
                        value: _TemplateAction.deactivate,
                        child: Text(context.l10n.deactivate),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Future<void> _edit([ShiftTemplate? template]) async {
    final value = await showDialog<ShiftTemplate>(
      context: context,
      builder: (context) => _ShiftTemplateDialog(template: template),
    );
    if (value != null) await controller.save(value);
  }

  String _time(Duration value) {
    final hour = value.inHours.remainder(24).toString().padLeft(2, '0');
    final minute = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

enum _TemplateAction { edit, deactivate }

class _ShiftTemplateDialog extends StatefulWidget {
  const _ShiftTemplateDialog({this.template});

  final ShiftTemplate? template;

  @override
  State<_ShiftTemplateDialog> createState() => _ShiftTemplateDialogState();
}

class _ShiftTemplateDialogState extends State<_ShiftTemplateDialog> {
  final formKey = GlobalKey<FormState>();
  late final code = TextEditingController(text: widget.template?.code ?? '');
  late final name = TextEditingController(text: widget.template?.name ?? '');
  late final hours = TextEditingController(
    text: '${widget.template?.workingHours ?? 8}',
  );
  late final rate = TextEditingController(
    text: '${widget.template?.rate ?? 0}',
  );
  late TimeOfDay start = _timeOfDay(
    widget.template?.startTime ?? const Duration(hours: 8),
  );
  late TimeOfDay end = _timeOfDay(
    widget.template?.endTime ?? const Duration(hours: 16),
  );

  @override
  void dispose() {
    code.dispose();
    name.dispose();
    hours.dispose();
    rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.template == null
          ? context.l10n.addShiftTemplate
          : context.l10n.editShiftTemplate,
    ),
    content: SizedBox(
      width: 520,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(code, context.l10n.shiftCode),
            _field(name, context.l10n.shiftName),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(true),
                    child: Text(
                      '${context.l10n.startTime}: ${start.format(context)}',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(false),
                    child: Text(
                      '${context.l10n.endTime}: ${end.format(context)}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _numberField(hours, context.l10n.workingHours),
            _numberField(rate, context.l10n.rate),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      FilledButton(onPressed: _submit, child: Text(context.l10n.save)),
    ],
  );

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: '$label *'),
        validator: (value) => value == null || value.trim().isEmpty
            ? context.l10n.requiredField
            : null,
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          final parsed = double.tryParse(value ?? '');
          return parsed == null || parsed < 0
              ? context.l10n.requiredField
              : null;
        },
      ),
    );
  }

  Future<void> _pickTime(bool isStart) async {
    final value = await showTimePicker(
      context: context,
      initialTime: isStart ? start : end,
    );
    if (value == null) return;
    setState(() {
      if (isStart) {
        start = value;
      } else {
        end = value;
      }
    });
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;
    final normalizedCode = code.text.trim();
    Navigator.pop(
      context,
      ShiftTemplate(
        id: widget.template?.id ?? normalizedCode.toLowerCase(),
        code: normalizedCode,
        name: name.text.trim(),
        startTime: Duration(hours: start.hour, minutes: start.minute),
        endTime: Duration(hours: end.hour, minutes: end.minute),
        colorValue: widget.template?.colorValue ?? 0xFF039BE5,
        workingHours: double.parse(hours.text),
        rate: double.parse(rate.text),
        active: widget.template?.active ?? true,
      ),
    );
  }

  TimeOfDay _timeOfDay(Duration value) {
    return TimeOfDay(
      hour: value.inHours.remainder(24),
      minute: value.inMinutes.remainder(60),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../design_system/enterprise_tokens.dart';
import '../../../domain/entities/shift_template.dart';
import '../application/ai_scheduler_request_factory.dart';
import 'ai_scheduler_shift_input_controller.dart';

/// Minimal editor for explicit shift slots requested before AI generation.
///
/// The panel only captures user intent. It never derives slots from existing
/// assignments and delegates deterministic identifiers and ordering to the
/// canonical presentation controller.
class AiSchedulerShiftInputPanel extends StatelessWidget {
  const AiSchedulerShiftInputPanel({
    required this.controller,
    required this.templates,
    super.key,
  });

  final AiSchedulerShiftInputController controller;
  final List<ShiftTemplate> templates;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final inputs = controller.inputs;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(EnterpriseSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: EnterpriseSpacing.md,
                  runSpacing: EnterpriseSpacing.sm,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Requested shifts',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: EnterpriseSpacing.xs),
                        Text('${inputs.length} explicit slot(s)'),
                      ],
                    ),
                    FilledButton.tonalIcon(
                      onPressed: templates.isEmpty
                          ? null
                          : () => _showAddDialog(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add shift'),
                    ),
                  ],
                ),
                if (templates.isEmpty) ...[
                  const SizedBox(height: EnterpriseSpacing.md),
                  const Text(
                    'No active shift templates are available. Configure shift templates before adding requested shifts.',
                  ),
                ] else if (inputs.isEmpty) ...[
                  const SizedBox(height: EnterpriseSpacing.md),
                  const Text(
                    'Add the exact shifts that should be included in the next proposal.',
                  ),
                ] else ...[
                  const SizedBox(height: EnterpriseSpacing.md),
                  for (final input in inputs)
                    _ShiftInputTile(
                      input: input,
                      onRemove: () => controller.remove(input.id),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: controller.clear,
                      icon: const Icon(Icons.clear_all_rounded),
                      label: const Text('Clear all'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    var date = DateUtils.dateOnly(DateTime.now());
    var template = templates.first;
    final departmentController = TextEditingController();
    final locationController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add requested shift'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_outlined),
                      title: const Text('Date'),
                      subtitle: Text(_formatDate(date)),
                      trailing: const Icon(Icons.edit_calendar_outlined),
                      onTap: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(date.year - 1),
                          lastDate: DateTime(date.year + 2, 12, 31),
                        );
                        if (selected != null) {
                          setDialogState(() => date = selected);
                        }
                      },
                    ),
                    DropdownButtonFormField<ShiftTemplate>(
                      initialValue: template,
                      decoration: const InputDecoration(labelText: 'Shift'),
                      items: [
                        for (final value in templates)
                          DropdownMenuItem(
                            value: value,
                            child: Text('${value.code} — ${value.name}'),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => template = value);
                        }
                      },
                    ),
                    const SizedBox(height: EnterpriseSpacing.md),
                    TextField(
                      controller: departmentController,
                      decoration: const InputDecoration(
                        labelText: 'Department ID (optional)',
                      ),
                    ),
                    const SizedBox(height: EnterpriseSpacing.md),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location (optional)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      controller.add(
        date: date,
        shift: template,
        departmentId: departmentController.text,
        location: locationController.text,
      );
    }

    departmentController.dispose();
    locationController.dispose();
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _ShiftInputTile extends StatelessWidget {
  const _ShiftInputTile({required this.input, required this.onRemove});

  final AiSchedulerShiftInput input;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final metadata = [
      if (input.departmentId.isNotEmpty) input.departmentId,
      if (input.location.isNotEmpty) input.location,
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Text(input.shift.code)),
      title: Text('${_formatDate(input.date)} · ${input.shift.name}'),
      subtitle: metadata.isEmpty ? null : Text(metadata.join(' · ')),
      trailing: IconButton(
        tooltip: 'Remove requested shift',
        onPressed: onRemove,
        icon: const Icon(Icons.delete_outline_rounded),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

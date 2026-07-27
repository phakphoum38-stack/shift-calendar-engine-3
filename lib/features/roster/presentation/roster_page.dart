import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/schedule.dart';
import '../../../l10n/l10n.dart';
import '../application/roster_controller.dart';
import '../application/roster_editor_controller.dart';
import 'roster_editor_page.dart';

/// Canonical month roster viewer with responsive date cards.
class RosterPage extends StatefulWidget {
  const RosterPage({
    required this.schedule,
    required this.controllerFactory,
    required this.editorControllerFactory,
    required this.onScheduleSaved,
    super.key,
  });

  final Schedule schedule;
  final RosterController Function(Schedule) controllerFactory;
  final RosterEditorController Function(Schedule) editorControllerFactory;
  final ValueChanged<Schedule> onScheduleSaved;

  @override
  State<RosterPage> createState() => _RosterPageState();
}

class _RosterPageState extends State<RosterPage> {
  late final RosterController controller = widget.controllerFactory(
    widget.schedule,
  );

  @override
  void didUpdateWidget(covariant RosterPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.updateSchedule(widget.schedule);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final month = controller.month;
      final locale = Localizations.localeOf(context).toLanguageTag();
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Text(
                context.l10n.roster,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (context) => RosterEditorPage(
                      schedule: widget.schedule,
                      controllerFactory: widget.editorControllerFactory,
                      onSaved: widget.onScheduleSaved,
                    ),
                  ),
                ),
                icon: const Icon(Icons.edit_calendar_outlined),
                label: Text(context.l10n.manualRosterEditor),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: context.l10n.previousMonth,
                onPressed: controller.previousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat.yMMMM(locale).format(controller.visibleMonth),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                tooltip: context.l10n.nextMonth,
                onPressed: controller.nextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (month == null ||
              month.days.every((day) => day.assignments.isEmpty))
            _EmptyRosterCard()
          else
            for (final day in month.days.where(
              (day) => day.assignments.isNotEmpty,
            ))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    leading: CircleAvatar(child: Text('${day.date.day}')),
                    title: Text(DateFormat.yMMMMEEEEd(locale).format(day.date)),
                    subtitle: Text(
                      '${day.assignments.length} ${context.l10n.monthlyAssignments.toLowerCase()}',
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
                              assignment.shift.name,
                              assignment.location,
                              assignment.remark,
                            ].whereType<String>().join(' • '),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
        ],
      );
    },
  );
}

class _EmptyRosterCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.calendar_month_outlined, size: 52),
          const SizedBox(height: 12),
          Text(
            context.l10n.noSchedule,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(context.l10n.noScheduleDescription),
        ],
      ),
    ),
  );
}

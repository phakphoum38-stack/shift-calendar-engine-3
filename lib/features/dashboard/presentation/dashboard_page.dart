import 'package:flutter/material.dart';

import '../../../domain/entities/schedule.dart';
import '../../../l10n/l10n.dart';
import '../application/dashboard_summary_service.dart';

/// Responsive daily and monthly operational overview.
class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.schedule,
    required this.summaryService,
    required this.openRoster,
    super.key,
  });

  final Schedule schedule;
  final DashboardSummaryService summaryService;
  final VoidCallback openRoster;

  @override
  Widget build(BuildContext context) {
    final summary = summaryService.build(schedule, DateTime.now());
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          context.l10n.dashboard,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width >= 900 ? 4 : 2,
          childAspectRatio: MediaQuery.sizeOf(context).width >= 900
              ? 1.55
              : 1.2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _MetricCard(
              icon: Icons.today_outlined,
              label: context.l10n.today,
              value: '${summary.todayAssignments.length}',
            ),
            _MetricCard(
              icon: Icons.event_outlined,
              label: context.l10n.tomorrow,
              value: '${summary.tomorrowAssignments.length}',
            ),
            _MetricCard(
              icon: Icons.calendar_month_outlined,
              label: context.l10n.monthlyAssignments,
              value: '${summary.monthlyAssignmentCount}',
            ),
            _MetricCard(
              icon: Icons.payments_outlined,
              label: context.l10n.estimatedIncome,
              value: summary.estimatedIncome.toStringAsFixed(0),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: schedule.assignments.isEmpty
                ? Column(
                    children: [
                      const Icon(Icons.event_busy_outlined, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.noSchedule,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(context.l10n.noScheduleDescription),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: openRoster,
                        icon: const Icon(Icons.add),
                        label: Text(context.l10n.createRoster),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.l10n.nextShift,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      for (final assignment in summary.todayAssignments)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            child: Text(assignment.shift.code),
                          ),
                          title: Text(assignment.employee.displayName),
                          subtitle: Text(
                            [
                              assignment.shift.name,
                              assignment.location,
                            ].whereType<String>().join(' • '),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    ),
  );
}

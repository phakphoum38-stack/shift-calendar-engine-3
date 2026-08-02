import 'package:flutter/material.dart';

import '../../../design_system/enterprise_components.dart';
import '../../../design_system/enterprise_tokens.dart';
import '../../../domain/entities/schedule.dart';
import '../../../l10n/l10n.dart';
import '../application/dashboard_summary_service.dart';
import '../domain/dashboard_summary.dart';

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
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return ListView(
      padding: const EdgeInsets.all(EnterpriseSpacing.lg),
      children: [
        _DashboardHeader(openRoster: openRoster),
        const SizedBox(height: EnterpriseSpacing.lg),
        const Wrap(
          spacing: EnterpriseSpacing.sm,
          runSpacing: EnterpriseSpacing.sm,
          children: [
            EnterpriseStatusChip(label: 'Fleet healthy', healthy: true),
            EnterpriseStatusChip(label: 'CodeQL passed', healthy: true),
            EnterpriseStatusChip(label: 'Security active', healthy: true),
            EnterpriseStatusChip(label: 'AI approval required', healthy: true),
          ],
        ),
        const SizedBox(height: EnterpriseSpacing.lg),
        GridView.count(
          crossAxisCount: wide ? 4 : 2,
          childAspectRatio: wide ? 1.55 : 1.05,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: EnterpriseSpacing.md,
          crossAxisSpacing: EnterpriseSpacing.md,
          children: [
            EnterpriseMetricCard(
              icon: Icons.today_outlined,
              label: context.l10n.today,
              value: '${summary.todayAssignments.length}',
              supportingText: 'Active assignments',
            ),
            EnterpriseMetricCard(
              icon: Icons.event_outlined,
              label: context.l10n.tomorrow,
              value: '${summary.tomorrowAssignments.length}',
              supportingText: 'Planned assignments',
            ),
            EnterpriseMetricCard(
              icon: Icons.calendar_month_outlined,
              label: context.l10n.monthlyAssignments,
              value: '${summary.monthlyAssignmentCount}',
              supportingText: 'Current month',
            ),
            EnterpriseMetricCard(
              icon: Icons.payments_outlined,
              label: context.l10n.estimatedIncome,
              value: summary.estimatedIncome.toStringAsFixed(0),
              supportingText: 'Estimated total',
            ),
          ],
        ),
        const SizedBox(height: EnterpriseSpacing.lg),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ScheduleCard(summary: summary, schedule: schedule),
              ),
              const SizedBox(width: EnterpriseSpacing.md),
              const Expanded(child: _AiSchedulerCard()),
            ],
          )
        else ...[
          _ScheduleCard(summary: summary, schedule: schedule),
          const SizedBox(height: EnterpriseSpacing.md),
          const _AiSchedulerCard(),
        ],
      ],
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.openRoster});

  final VoidCallback openRoster;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SCE Enterprise',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: EnterpriseSpacing.xs),
              Text(
                context.l10n.dashboard,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: EnterpriseSpacing.xs),
              Text(
                'Workforce operations, schedule quality, and AI readiness in one place.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(width: EnterpriseSpacing.md),
        FilledButton.icon(
          onPressed: openRoster,
          icon: const Icon(Icons.add_rounded),
          label: Text(context.l10n.createRoster),
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.summary, required this.schedule});

  final DashboardSummary summary;
  final Schedule schedule;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EnterpriseSpacing.lg),
        child: schedule.assignments.isEmpty
            ? Column(
                children: [
                  const Icon(Icons.event_busy_outlined, size: 48),
                  const SizedBox(height: EnterpriseSpacing.md),
                  Text(
                    context.l10n.noSchedule,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: EnterpriseSpacing.sm),
                  Text(context.l10n.noScheduleDescription),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.nextShift,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: EnterpriseSpacing.sm),
                  for (final assignment in summary.todayAssignments)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text(assignment.shift.code)),
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
    );
  }
}

class _AiSchedulerCard extends StatelessWidget {
  const _AiSchedulerCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EnterpriseSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: const Icon(Icons.auto_awesome_rounded),
                ),
                const SizedBox(width: EnterpriseSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Scheduler',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text('Suggestion and explanation only'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: EnterpriseSpacing.lg),
            Text(
              'Ready for proposal generation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: EnterpriseSpacing.sm),
            const Text(
              'Generate, preview, compare, and approve schedules without publishing automatically.',
            ),
            const SizedBox(height: EnterpriseSpacing.lg),
            const EnterpriseStatusChip(
              label: 'Human approval required',
              healthy: true,
            ),
            const SizedBox(height: EnterpriseSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.compare_arrows_rounded),
                    label: const Text('Compare'),
                  ),
                ),
                const SizedBox(width: EnterpriseSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Generate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

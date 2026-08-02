import 'package:flutter/material.dart';

import '../../../design_system/enterprise_components.dart';
import '../../../design_system/enterprise_tokens.dart';

/// Read-only presentation model for an AI-generated schedule proposal.
///
/// The application layer will map canonical workforce_core results into this
/// model. This page intentionally contains no scheduling business logic.
final class AiSchedulerPresentationModel {
  const AiSchedulerPresentationModel({
    required this.score,
    required this.conflictCount,
    required this.fairnessLabel,
    required this.explanations,
    required this.requiresApproval,
  });

  final int score;
  final int conflictCount;
  final String fairnessLabel;
  final List<String> explanations;
  final bool requiresApproval;
}

/// Enterprise AI scheduler workspace.
class AiSchedulerPage extends StatelessWidget {
  const AiSchedulerPage({
    this.proposal,
    this.onGenerate,
    this.onPreview,
    this.onCompare,
    this.onApprove,
    this.onReject,
    super.key,
  });

  final AiSchedulerPresentationModel? proposal;
  final VoidCallback? onGenerate;
  final VoidCallback? onPreview;
  final VoidCallback? onCompare;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final currentProposal = proposal;

    return ListView(
      padding: const EdgeInsets.all(EnterpriseSpacing.lg),
      children: [
        Wrap(
          spacing: EnterpriseSpacing.md,
          runSpacing: EnterpriseSpacing.md,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Scheduler',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: EnterpriseSpacing.xs),
                Text(
                  'สร้าง ตรวจสอบ และอนุมัติข้อเสนอตารางเวรอย่างปลอดภัย',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Generate proposal'),
            ),
          ],
        ),
        const SizedBox(height: EnterpriseSpacing.lg),
        const Wrap(
          spacing: EnterpriseSpacing.sm,
          runSpacing: EnterpriseSpacing.sm,
          children: [
            EnterpriseStatusChip(
              label: 'Human approval required',
              healthy: true,
            ),
            EnterpriseStatusChip(
              label: 'Explainable decisions',
              healthy: true,
            ),
            EnterpriseStatusChip(
              label: 'No autonomous publishing',
              healthy: true,
            ),
          ],
        ),
        const SizedBox(height: EnterpriseSpacing.lg),
        if (currentProposal == null)
          _EmptyProposal(onGenerate: onGenerate)
        else
          _ProposalWorkspace(
            proposal: currentProposal,
            onPreview: onPreview,
            onCompare: onCompare,
            onApprove: onApprove,
            onReject: onReject,
          ),
      ],
    );
  }
}

class _EmptyProposal extends StatelessWidget {
  const _EmptyProposal({required this.onGenerate});

  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EnterpriseSpacing.xl),
        child: Column(
          children: [
            Icon(
              Icons.calendar_view_month_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: EnterpriseSpacing.md),
            Text(
              'ยังไม่มีข้อเสนอตารางเวร',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: EnterpriseSpacing.sm),
            const Text(
              'กด Generate เพื่อให้ AI สร้างข้อเสนอจากกฎและข้อมูลใน Canonical Core',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: EnterpriseSpacing.lg),
            FilledButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Generate proposal'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProposalWorkspace extends StatelessWidget {
  const _ProposalWorkspace({
    required this.proposal,
    required this.onPreview,
    required this.onCompare,
    required this.onApprove,
    required this.onReject,
  });

  final AiSchedulerPresentationModel proposal;
  final VoidCallback? onPreview;
  final VoidCallback? onCompare;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100 ? 3 : width >= 700 ? 2 : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: EnterpriseSpacing.md,
          crossAxisSpacing: EnterpriseSpacing.md,
          childAspectRatio: columns == 1 ? 2.5 : 1.8,
          children: [
            EnterpriseMetricCard(
              icon: Icons.stars_outlined,
              label: 'Score',
              value: '${proposal.score}',
            ),
            EnterpriseMetricCard(
              icon: Icons.balance_outlined,
              label: 'Fairness',
              value: proposal.fairnessLabel,
            ),
            EnterpriseMetricCard(
              icon: Icons.report_problem_outlined,
              label: 'Conflicts',
              value: '${proposal.conflictCount}',
            ),
          ],
        ),
        const SizedBox(height: EnterpriseSpacing.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(EnterpriseSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explanation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: EnterpriseSpacing.md),
                if (proposal.explanations.isEmpty)
                  const Text('ไม่มีคำอธิบายเพิ่มเติม')
                else
                  for (final explanation in proposal.explanations)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check_circle_outline_rounded),
                      title: Text(explanation),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: EnterpriseSpacing.lg),
        Wrap(
          spacing: EnterpriseSpacing.sm,
          runSpacing: EnterpriseSpacing.sm,
          children: [
            OutlinedButton.icon(
              onPressed: onPreview,
              icon: const Icon(Icons.preview_outlined),
              label: const Text('Preview'),
            ),
            OutlinedButton.icon(
              onPressed: onCompare,
              icon: const Icon(Icons.compare_arrows_rounded),
              label: const Text('Compare'),
            ),
            FilledButton.tonalIcon(
              onPressed: onReject,
              icon: const Icon(Icons.close_rounded),
              label: const Text('Reject'),
            ),
            FilledButton.icon(
              onPressed: proposal.requiresApproval ? onApprove : null,
              icon: const Icon(Icons.task_alt_rounded),
              label: const Text('Approve'),
            ),
          ],
        ),
      ],
    );
  }
}

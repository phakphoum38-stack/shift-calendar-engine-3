import 'package:flutter/material.dart';

import '../../../design_system/enterprise_components.dart';
import '../../../design_system/enterprise_tokens.dart';
import '../application/ai_scheduler_view_data.dart';

/// Enterprise AI scheduler workspace.
class AiSchedulerPage extends StatelessWidget {
  const AiSchedulerPage({
    this.proposal,
    this.loading = false,
    this.errorMessage,
    this.onGenerate,
    this.onPreview,
    this.onCompare,
    this.onApprove,
    this.onReject,
    super.key,
  });

  final AiSchedulerViewData? proposal;
  final bool loading;
  final String? errorMessage;
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
              onPressed: loading ? null : onGenerate,
              icon: loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(loading ? 'Generating...' : 'Generate proposal'),
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
            EnterpriseStatusChip(label: 'Explainable decisions', healthy: true),
            EnterpriseStatusChip(
              label: 'No autonomous publishing',
              healthy: true,
            ),
          ],
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: EnterpriseSpacing.lg),
          _ErrorCard(message: errorMessage!, onRetry: onGenerate),
        ],
        const SizedBox(height: EnterpriseSpacing.lg),
        if (loading)
          const _GeneratingCard()
        else if (currentProposal == null)
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

class _GeneratingCard extends StatelessWidget {
  const _GeneratingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EnterpriseSpacing.xl),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: EnterpriseSpacing.lg),
            Text(
              'กำลังสร้างข้อเสนอตารางเวร',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: EnterpriseSpacing.sm),
            const Text(
              'Canonical Core กำลังตรวจ constraints, fairness และ conflicts',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EnterpriseSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, color: scheme.error),
            const SizedBox(width: EnterpriseSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'สร้างข้อเสนอไม่สำเร็จ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: EnterpriseSpacing.xs),
                  Text(message),
                ],
              ),
            ),
            const SizedBox(width: EnterpriseSpacing.md),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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

  final AiSchedulerViewData proposal;
  final VoidCallback? onPreview;
  final VoidCallback? onCompare;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100
        ? 3
        : width >= 700
        ? 2
        : 1;

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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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

import 'package:flutter/material.dart';

import 'enterprise_tokens.dart';

class EnterpriseStatusChip extends StatelessWidget {
  const EnterpriseStatusChip({
    required this.label,
    required this.healthy,
    super.key,
  });

  final String label;
  final bool healthy;

  @override
  Widget build(BuildContext context) {
    final color = healthy ? EnterpriseColors.success : EnterpriseColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: EnterpriseSpacing.md,
        vertical: EnterpriseSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: EnterpriseRadius.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: EnterpriseSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class EnterpriseMetricCard extends StatelessWidget {
  const EnterpriseMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    this.supportingText,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? supportingText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EnterpriseSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: Icon(icon),
            ),
            const SizedBox(width: EnterpriseSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (supportingText != null)
                    Text(
                      supportingText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

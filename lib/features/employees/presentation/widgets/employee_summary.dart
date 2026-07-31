import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';

class EmployeeSummary extends StatelessWidget {
  const EmployeeSummary({
    required this.total,
    required this.active,
    required this.inactive,
    required this.departments,
    super.key,
  });

  final int total;
  final int active;
  final int inactive;
  final int departments;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1000
          ? 4
          : constraints.maxWidth >= 640
          ? 2
          : 1;

      return GridView.count(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: columns == 1 ? 4.2 : 2.5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _SummaryCard(
            icon: Icons.groups_outlined,
            value: total,
            label: context.l10n.employeeDirectory,
          ),
          _SummaryCard(
            icon: Icons.check_circle_outline,
            value: active,
            label: context.l10n.active,
          ),
          _SummaryCard(
            icon: Icons.block_outlined,
            value: inactive,
            label: context.l10n.inactive,
          ),
          _SummaryCard(
            icon: Icons.apartment_outlined,
            value: departments,
            label: context.l10n.departmentName,
          ),
        ],
      );
    },
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(child: Icon(icon)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

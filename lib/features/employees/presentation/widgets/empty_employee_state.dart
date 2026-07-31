import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';

class EmptyEmployeeState extends StatelessWidget {
  const EmptyEmployeeState({required this.onAdd, super.key});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.groups_outlined, size: 52),
          const SizedBox(height: 12),
          Text(
            context.l10n.noEmployees,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_outlined),
            label: Text(context.l10n.addEmployee),
          ),
        ],
      ),
    ),
  );
}

import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';

class EmployeeHeader extends StatelessWidget {
  const EmployeeHeader({required this.loading, required this.onAdd, super.key});

  final bool loading;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 560;
      final title = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.employeeDirectory,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(context.l10n.employeeDirectoryDescription),
        ],
      );
      final button = FilledButton.icon(
        onPressed: loading ? null : onAdd,
        icon: const Icon(Icons.person_add_outlined),
        label: Text(context.l10n.addEmployee),
      );

      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [title, const SizedBox(height: 12), button],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: title),
          const SizedBox(width: 16),
          button,
        ],
      );
    },
  );
}

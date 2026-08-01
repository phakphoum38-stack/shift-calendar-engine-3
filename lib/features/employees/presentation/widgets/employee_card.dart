import 'package:flutter/material.dart';

import '../../../../domain/entities/employee.dart';
import '../../../../l10n/l10n.dart';

enum EmployeeAction { edit, deactivate }

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({
    required this.employee,
    required this.onEdit,
    required this.onDeactivate,
    super.key,
  });

  final Employee employee;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    final displayName = employee.displayName.trim();
    final avatarText = displayName.isEmpty ? '?' : displayName.characters.first;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(child: Text(avatarText)),
      title: Row(
        children: [
          Expanded(
            child: Text(
              displayName.isEmpty ? employee.employeeCode : displayName,
            ),
          ),
          const SizedBox(width: 8),
          Chip(
            label: Text(
              employee.active ? context.l10n.active : context.l10n.inactive,
            ),
            avatar: Icon(
              employee.active
                  ? Icons.check_circle_outline
                  : Icons.block_outlined,
              size: 18,
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      subtitle: Text(
        [
          employee.employeeCode,
          employee.position,
          employee.department.name,
        ].where((value) => value.isNotEmpty).join(' • '),
      ),
      trailing: PopupMenuButton<EmployeeAction>(
        onSelected: (action) {
          switch (action) {
            case EmployeeAction.edit:
              onEdit();
            case EmployeeAction.deactivate:
              onDeactivate();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: EmployeeAction.edit,
            child: Text(context.l10n.editEmployee),
          ),
          if (employee.active)
            PopupMenuItem(
              value: EmployeeAction.deactivate,
              child: Text(context.l10n.deactivate),
            ),
        ],
      ),
    );
  }
}

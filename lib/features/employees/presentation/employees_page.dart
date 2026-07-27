import 'package:flutter/material.dart';

import '../../../domain/entities/schedule.dart';
import '../../../l10n/l10n.dart';
import '../application/employee_directory_service.dart';

/// Read-only canonical employee directory foundation.
class EmployeesPage extends StatelessWidget {
  const EmployeesPage({
    required this.schedule,
    this.service = const EmployeeDirectoryService(),
    super.key,
  });

  final Schedule schedule;
  final EmployeeDirectoryService service;

  @override
  Widget build(BuildContext context) {
    final employees = service.fromSchedule(schedule);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          context.l10n.employeeDirectory,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(context.l10n.employeeDirectoryDescription),
        const SizedBox(height: 16),
        if (employees.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.groups_outlined, size: 52),
                  const SizedBox(height: 12),
                  Text(context.l10n.noEmployees),
                ],
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (var index = 0; index < employees.length; index++) ...[
                  ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        employees[index].displayName.characters.first,
                      ),
                    ),
                    title: Text(employees[index].displayName),
                    subtitle: Text(
                      [
                        employees[index].employeeCode,
                        employees[index].position,
                        employees[index].department.name,
                      ].where((value) => value.isNotEmpty).join(' • '),
                    ),
                  ),
                  if (index != employees.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

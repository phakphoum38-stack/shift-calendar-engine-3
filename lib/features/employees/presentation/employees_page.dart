import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/entities/employee.dart';
import '../../../domain/entities/schedule.dart';
import '../../../l10n/l10n.dart';
import '../application/employee_directory_controller.dart';
import 'dialogs/employee_dialog.dart';
import 'widgets/employee_card.dart';
import 'widgets/employee_filters.dart';
import 'widgets/employee_header.dart';
import 'widgets/employee_summary.dart';
import 'widgets/empty_employee_state.dart';

/// Persistent canonical employee directory.
class EmployeesPage extends StatefulWidget {
  const EmployeesPage({
    required this.schedule,
    required this.controllerFactory,
    super.key,
  });

  final Schedule schedule;
  final EmployeeDirectoryController Function(Schedule) controllerFactory;

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  late final EmployeeDirectoryController controller = widget.controllerFactory(
    widget.schedule,
  );

  @override
  void initState() {
    super.initState();
    unawaited(controller.load());
  }

  @override
  void didUpdateWidget(covariant EmployeesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.updateSchedule(widget.schedule);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final state = controller.state;
      final visibleEmployees = state.visibleEmployees;

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            EmployeeHeader(loading: state.loading, onAdd: _edit),
            const SizedBox(height: 16),
            EmployeeSummary(
              total: state.employees.length,
              active: state.activeCount,
              inactive: state.employees.length - state.activeCount,
              departments: state.departments.length,
            ),
            const SizedBox(height: 16),
            EmployeeFilters(
              statusFilter: state.statusFilter,
              employeeSort: state.employeeSort,
              departmentId: state.departmentId,
              departments: state.departments,
              onSearchChanged: controller.search,
              onStatusChanged: controller.setStatusFilter,
              onSortChanged: controller.setSort,
              onDepartmentChanged: controller.setDepartment,
            ),
            if (state.loading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            if (state.error case final error?) ...[
              const SizedBox(height: 12),
              Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            if (visibleEmployees.isEmpty)
              EmptyEmployeeState(onAdd: state.loading ? null : _edit)
            else
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < visibleEmployees.length;
                      index++
                    ) ...[
                      EmployeeCard(
                        employee: visibleEmployees[index],
                        onEdit: () => _edit(visibleEmployees[index]),
                        onDeactivate: () =>
                            _deactivate(visibleEmployees[index]),
                      ),
                      if (index != visibleEmployees.length - 1)
                        const Divider(height: 1),
                    ],
                  ],
                ),
              ),
          ],
        ),
      );
    },
  );

  Future<void> _edit([Employee? employee]) async {
    final value = await showDialog<Employee>(
      context: context,
      builder: (context) => EmployeeDialog(employee: employee),
    );
    if (value != null) await controller.save(value);
  }

  Future<void> _deactivate(Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deactivate),
        content: Text('${context.l10n.deactivate}: ${employee.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.deactivate),
          ),
        ],
      ),
    );

    if (confirmed == true) await controller.deactivate(employee);
  }
}

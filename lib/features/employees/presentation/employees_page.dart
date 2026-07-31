import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/entities/department.dart';
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

  EmployeeStatusFilter statusFilter = EmployeeStatusFilter.all;
  EmployeeSort employeeSort = EmployeeSort.nameAscending;
  String? departmentId;

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
      final employees = controller.employees;
      final activeCount = employees.where((employee) => employee.active).length;
      final departments = _departmentsFrom(employees);
      final visibleEmployees = _visibleEmployees(employees);

      if (departmentId != null &&
          !departments.any((department) => department.id == departmentId)) {
        departmentId = null;
      }

      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          EmployeeHeader(loading: controller.loading, onAdd: _edit),
          const SizedBox(height: 16),
          EmployeeSummary(
            total: employees.length,
            active: activeCount,
            inactive: employees.length - activeCount,
            departments: departments.length,
          ),
          const SizedBox(height: 16),
          EmployeeFilters(
            statusFilter: statusFilter,
            employeeSort: employeeSort,
            departmentId: departmentId,
            departments: departments,
            onSearchChanged: controller.search,
            onStatusChanged: (value) => setState(() => statusFilter = value),
            onSortChanged: (value) => setState(() => employeeSort = value),
            onDepartmentChanged: (value) =>
                setState(() => departmentId = value),
          ),
          if (controller.loading) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (controller.error case final error?) ...[
            const SizedBox(height: 12),
            Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          if (visibleEmployees.isEmpty)
            EmptyEmployeeState(onAdd: controller.loading ? null : _edit)
          else
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var index = 0;
                      index < visibleEmployees.length;
                      index++) ...[
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
      );
    },
  );

  List<Department> _departmentsFrom(List<Employee> employees) {
    final departments = <String, Department>{};
    for (final employee in employees) {
      final department = employee.department;
      if (department.id.isNotEmpty) departments[department.id] = department;
    }
    final result = departments.values.toList();
    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return result;
  }

  List<Employee> _visibleEmployees(List<Employee> employees) {
    final result = employees.where((employee) {
      final matchesStatus = switch (statusFilter) {
        EmployeeStatusFilter.all => true,
        EmployeeStatusFilter.active => employee.active,
        EmployeeStatusFilter.inactive => !employee.active,
      };
      final matchesDepartment =
          departmentId == null || employee.department.id == departmentId;
      return matchesStatus && matchesDepartment;
    }).toList();

    result.sort((a, b) {
      switch (employeeSort) {
        case EmployeeSort.nameAscending:
          return a.displayName.toLowerCase().compareTo(
            b.displayName.toLowerCase(),
          );
        case EmployeeSort.nameDescending:
          return b.displayName.toLowerCase().compareTo(
            a.displayName.toLowerCase(),
          );
        case EmployeeSort.employeeCode:
          return a.employeeCode.toLowerCase().compareTo(
            b.employeeCode.toLowerCase(),
          );
      }
    });
    return result;
  }

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

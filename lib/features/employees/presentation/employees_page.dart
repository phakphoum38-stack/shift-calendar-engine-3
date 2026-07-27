import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/entities/department.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/entities/schedule.dart';
import '../../../l10n/l10n.dart';
import '../application/employee_directory_controller.dart';

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
    builder: (context, _) => ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.employeeDirectory,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            FilledButton.icon(
              onPressed: controller.loading ? null : () => _edit(),
              icon: const Icon(Icons.person_add_outlined),
              label: Text(context.l10n.addEmployee),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(context.l10n.employeeDirectoryDescription),
        const SizedBox(height: 16),
        TextField(
          onChanged: controller.search,
          decoration: InputDecoration(
            labelText: context.l10n.search,
            prefixIcon: const Icon(Icons.search),
          ),
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
        if (controller.employees.isEmpty)
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
                for (
                  var index = 0;
                  index < controller.employees.length;
                  index++
                ) ...[
                  ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        controller
                            .employees[index]
                            .displayName
                            .characters
                            .first,
                      ),
                    ),
                    title: Text(controller.employees[index].displayName),
                    subtitle: Text(
                      [
                        controller.employees[index].employeeCode,
                        controller.employees[index].position,
                        controller.employees[index].department.name,
                      ].where((value) => value.isNotEmpty).join(' • '),
                    ),
                    trailing: PopupMenuButton<_EmployeeAction>(
                      onSelected: (action) {
                        if (action == _EmployeeAction.edit) {
                          unawaited(_edit(controller.employees[index]));
                        } else {
                          unawaited(
                            controller.deactivate(controller.employees[index]),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: _EmployeeAction.edit,
                          child: Text(context.l10n.editEmployee),
                        ),
                        PopupMenuItem(
                          value: _EmployeeAction.deactivate,
                          child: Text(context.l10n.deactivate),
                        ),
                      ],
                    ),
                  ),
                  if (index != controller.employees.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
      ],
    ),
  );

  Future<void> _edit([Employee? employee]) async {
    final value = await showDialog<Employee>(
      context: context,
      builder: (context) => _EmployeeDialog(employee: employee),
    );
    if (value != null) await controller.save(value);
  }
}

enum _EmployeeAction { edit, deactivate }

class _EmployeeDialog extends StatefulWidget {
  const _EmployeeDialog({this.employee});

  final Employee? employee;

  @override
  State<_EmployeeDialog> createState() => _EmployeeDialogState();
}

class _EmployeeDialogState extends State<_EmployeeDialog> {
  final formKey = GlobalKey<FormState>();
  late final code = TextEditingController(
    text: widget.employee?.employeeCode ?? '',
  );
  late final firstName = TextEditingController(
    text: widget.employee?.firstName ?? '',
  );
  late final lastName = TextEditingController(
    text: widget.employee?.lastName ?? '',
  );
  late final nickname = TextEditingController(
    text: widget.employee?.nickname ?? '',
  );
  late final position = TextEditingController(
    text: widget.employee?.position ?? '',
  );
  late final departmentCode = TextEditingController(
    text: widget.employee?.department.code ?? '',
  );
  late final departmentName = TextEditingController(
    text: widget.employee?.department.name ?? '',
  );

  @override
  void dispose() {
    code.dispose();
    firstName.dispose();
    lastName.dispose();
    nickname.dispose();
    position.dispose();
    departmentCode.dispose();
    departmentName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.employee == null
          ? context.l10n.addEmployee
          : context.l10n.editEmployee,
    ),
    content: SizedBox(
      width: 540,
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _field(code, context.l10n.employeeCode, required: true),
              _field(firstName, context.l10n.firstName, required: true),
              _field(lastName, context.l10n.lastName),
              _field(nickname, context.l10n.nickname),
              _field(position, context.l10n.position),
              _field(
                departmentCode,
                context.l10n.departmentCode,
                required: true,
              ),
              _field(
                departmentName,
                context.l10n.departmentName,
                required: true,
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      FilledButton(onPressed: _submit, child: Text(context.l10n.save)),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: required ? '$label *' : label),
        validator: required
            ? (value) => value == null || value.trim().isEmpty
                  ? context.l10n.requiredField
                  : null
            : null,
      ),
    );
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;
    final normalizedCode = code.text.trim();
    final normalizedDepartment = departmentCode.text.trim();
    Navigator.pop(
      context,
      Employee(
        id: widget.employee?.id ?? 'employee:${normalizedCode.toLowerCase()}',
        employeeCode: normalizedCode,
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        nickname: nickname.text.trim(),
        department: Department(
          id: 'department:${normalizedDepartment.toLowerCase()}',
          code: normalizedDepartment,
          name: departmentName.text.trim(),
        ),
        position: position.text.trim(),
        active: widget.employee?.active ?? true,
      ),
    );
  }
}

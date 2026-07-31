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
    builder: (context, _) {
      final employees = controller.employees;
      final activeCount = employees.where((employee) => employee.active).length;
      final inactiveCount = employees.length - activeCount;
      final departmentCount = employees
          .map((employee) => employee.department.id)
          .where((id) => id.isNotEmpty)
          .toSet()
          .length;

      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Header(
            loading: controller.loading,
            onAdd: _edit,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1000
                  ? 4
                  : width >= 640
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
                    value: employees.length,
                    label: context.l10n.employeeDirectory,
                  ),
                  _SummaryCard(
                    icon: Icons.check_circle_outline,
                    value: activeCount,
                    label: context.l10n.active,
                  ),
                  _SummaryCard(
                    icon: Icons.block_outlined,
                    value: inactiveCount,
                    label: context.l10n.inactive,
                  ),
                  _SummaryCard(
                    icon: Icons.apartment_outlined,
                    value: departmentCount,
                    label: context.l10n.departmentName,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SearchBar(
            onChanged: controller.search,
            leading: const Icon(Icons.search),
            hintText: context.l10n.search,
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
          if (employees.isEmpty)
            _EmptyState(
              onAdd: controller.loading ? null : _edit,
            )
          else
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var index = 0; index < employees.length; index++) ...[
                    _EmployeeTile(
                      employee: employees[index],
                      onEdit: () => _edit(employees[index]),
                      onDeactivate: () => _deactivate(employees[index]),
                    ),
                    if (index != employees.length - 1)
                      const Divider(height: 1),
                  ],
                ],
              ),
            ),
        ],
      );
    },
  );

  Future<void> _edit([Employee? employee]) async {
    final value = await showDialog<Employee>(
      context: context,
      builder: (context) => _EmployeeDialog(employee: employee),
    );
    if (value != null) await controller.save(value);
  }

  Future<void> _deactivate(Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deactivate),
        content: Text(
          '${context.l10n.deactivate}: ${employee.displayName}?',
        ),
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

    if (confirmed == true) {
      await controller.deactivate(employee);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.loading, required this.onAdd});

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
          children: [
            title,
            const SizedBox(height: 12),
            button,
          ],
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

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

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({
    required this.employee,
    required this.onEdit,
    required this.onDeactivate,
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
          Expanded(child: Text(displayName.isEmpty ? employee.employeeCode : displayName)),
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
      trailing: PopupMenuButton<_EmployeeAction>(
        onSelected: (action) {
          switch (action) {
            case _EmployeeAction.edit:
              onEdit();
            case _EmployeeAction.deactivate:
              onDeactivate();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _EmployeeAction.edit,
            child: Text(context.l10n.editEmployee),
          ),
          if (employee.active)
            PopupMenuItem(
              value: _EmployeeAction.deactivate,
              child: Text(context.l10n.deactivate),
            ),
        ],
      ),
    );
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
        id:
            widget.employee?.id ??
            'employee:${DateTime.now().microsecondsSinceEpoch}',
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

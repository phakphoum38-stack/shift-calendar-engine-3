import 'package:flutter/material.dart';

import '../../../../domain/entities/department.dart';
import '../../../../domain/entities/employee.dart';
import '../../../../l10n/l10n.dart';

class EmployeeDialog extends StatefulWidget {
  const EmployeeDialog({this.employee, super.key});

  final Employee? employee;

  @override
  State<EmployeeDialog> createState() => _EmployeeDialogState();
}

class _EmployeeDialogState extends State<EmployeeDialog> {
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionTitle(context, context.l10n.employeeDirectory),
              _field(code, context.l10n.employeeCode, required: true),
              _field(firstName, context.l10n.firstName, required: true),
              _field(lastName, context.l10n.lastName),
              _field(nickname, context.l10n.nickname),
              const SizedBox(height: 8),
              _sectionTitle(context, context.l10n.departmentName),
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

  Widget _sectionTitle(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
  }) => Padding(
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

  void _submit() {
    if (!formKey.currentState!.validate()) return;
    final normalizedDepartment = departmentCode.text.trim();
    Navigator.pop(
      context,
      Employee(
        id:
            widget.employee?.id ??
            'employee:${DateTime.now().microsecondsSinceEpoch}',
        employeeCode: code.text.trim(),
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

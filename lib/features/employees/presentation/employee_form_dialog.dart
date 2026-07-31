import 'package:flutter/material.dart';

import '../../../domain/entities/department.dart';
import '../../../domain/entities/employee.dart';

/// Reusable add/edit dialog for employee directory records.
class EmployeeFormDialog extends StatefulWidget {
  const EmployeeFormDialog({
    required this.onSave,
    this.employee,
    this.fieldErrors = const <String, String>{},
    this.saving = false,
    super.key,
  });

  final Employee? employee;
  final Map<String, String> fieldErrors;
  final bool saving;
  final Future<bool> Function(Employee employee) onSave;

  bool get editing => employee != null;

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _employeeCode;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _nickname;
  late final TextEditingController _position;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _organizationId;
  late final TextEditingController _branchId;
  late final TextEditingController _departmentId;
  late final TextEditingController _departmentCode;
  late final TextEditingController _departmentName;
  late final TextEditingController _teamId;
  late bool _active;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final employee = widget.employee;
    _employeeCode = TextEditingController(text: employee?.employeeCode ?? '');
    _firstName = TextEditingController(text: employee?.firstName ?? '');
    _lastName = TextEditingController(text: employee?.lastName ?? '');
    _nickname = TextEditingController(text: employee?.nickname ?? '');
    _position = TextEditingController(text: employee?.position ?? '');
    _email = TextEditingController(text: employee?.email ?? '');
    _phone = TextEditingController(text: employee?.phone ?? '');
    _organizationId = TextEditingController(text: employee?.organizationId ?? '');
    _branchId = TextEditingController(text: employee?.branchId ?? '');
    _departmentId = TextEditingController(text: employee?.department.id ?? '');
    _departmentCode = TextEditingController(text: employee?.department.code ?? '');
    _departmentName = TextEditingController(text: employee?.department.name ?? '');
    _teamId = TextEditingController(text: employee?.teamId ?? '');
    _active = employee?.active ?? true;
  }

  @override
  void dispose() {
    _employeeCode.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _nickname.dispose();
    _position.dispose();
    _email.dispose();
    _phone.dispose();
    _organizationId.dispose();
    _branchId.dispose();
    _departmentId.dispose();
    _departmentCode.dispose();
    _departmentName.dispose();
    _teamId.dispose();
    super.dispose();
  }

  String? _required(String field, String label, String? value) {
    final serverError = widget.fieldErrors[field];
    if (serverError != null && serverError.isNotEmpty) return serverError;
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  String? _optionalError(String field) {
    final value = widget.fieldErrors[field];
    return value == null || value.isEmpty ? null : value;
  }

  Future<void> _submit() async {
    if (_submitting || widget.saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    final current = widget.employee;
    final department = Department(
      id: _departmentId.text.trim(),
      code: _departmentCode.text.trim(),
      name: _departmentName.text.trim(),
      organizationId: _organizationId.text.trim(),
      branchId: _branchId.text.trim(),
      parentDepartmentId: current?.department.parentDepartmentId ?? '',
      active: current?.department.active ?? true,
    );
    final defaults = const EmployeePlaceholderData();
    final employee = Employee(
      id: current?.id ?? 'employee-${DateTime.now().microsecondsSinceEpoch}',
      employeeCode: _employeeCode.text.trim(),
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      nickname: _nickname.text.trim(),
      organizationId: _organizationId.text.trim(),
      branchId: _branchId.text.trim(),
      department: department,
      teamId: _teamId.text.trim(),
      position: _position.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      employment: current?.employment ?? defaults.employment,
      calendarProfile: current?.calendarProfile ?? defaults.calendarProfile,
      sourceProfile: current?.sourceProfile ?? defaults.sourceProfile,
      active: _active,
    );

    final saved = await widget.onSave(employee);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (saved) Navigator.of(context).pop(employee);
  }

  @override
  Widget build(BuildContext context) {
    final busy = _submitting || widget.saving;
    return AlertDialog(
      title: Text(widget.editing ? 'Edit employee' : 'Add employee'),
      content: SizedBox(
        width: 720,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionTitle('Identity'),
                _responsiveFields([
                  _field(controller: _employeeCode, label: 'Employee code', field: 'employeeCode', requiredField: true),
                  _field(controller: _firstName, label: 'First name', field: 'firstName', requiredField: true),
                  _field(controller: _lastName, label: 'Last name', field: 'lastName', requiredField: true),
                  _field(controller: _nickname, label: 'Nickname', field: 'nickname'),
                ]),
                const SizedBox(height: 16),
                _sectionTitle('Organization'),
                _responsiveFields([
                  _field(controller: _organizationId, label: 'Organization ID', field: 'organizationId', requiredField: true),
                  _field(controller: _branchId, label: 'Branch ID', field: 'branchId', requiredField: true),
                  _field(controller: _departmentId, label: 'Department ID', field: 'departmentId', requiredField: true),
                  _field(controller: _departmentCode, label: 'Department code', field: 'departmentCode', requiredField: true),
                  _field(controller: _departmentName, label: 'Department name', field: 'departmentName', requiredField: true),
                  _field(controller: _teamId, label: 'Team ID', field: 'teamId'),
                ]),
                const SizedBox(height: 16),
                _sectionTitle('Work and contact'),
                _responsiveFields([
                  _field(controller: _position, label: 'Position', field: 'position', requiredField: true),
                  _field(controller: _email, label: 'Email', field: 'email', keyboardType: TextInputType.emailAddress),
                  _field(controller: _phone, label: 'Phone', field: 'phone', keyboardType: TextInputType.phone),
                ]),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active employee'),
                  value: _active,
                  onChanged: busy ? null : (value) => setState(() => _active = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: busy ? null : _submit,
          icon: busy
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(widget.editing ? 'Save changes' : 'Add employee'),
        ),
      ],
    );
  }

  Widget _sectionTitle(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(value, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _responsiveFields(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 620
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: children.map((child) => SizedBox(width: width, child: child)).toList(),
        );
      },
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String field,
    bool requiredField = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_submitting && !widget.saving,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: _optionalError(field),
      ),
      validator: requiredField
          ? (value) => _required(field, label, value)
          : (_) => _optionalError(field),
    );
  }
}

/// Supplies const defaults without introducing demo or personal employee data.
class EmployeePlaceholderData extends Employee {
  const EmployeePlaceholderData()
      : super(
          id: '',
          employeeCode: '',
          firstName: '',
          lastName: '',
          department: const Department(id: '', code: '', name: ''),
          position: '',
        );
}

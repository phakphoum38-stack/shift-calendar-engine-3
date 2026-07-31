import 'package:flutter/material.dart';

import '../../../../domain/entities/department.dart';
import '../../../../l10n/l10n.dart';

enum EmployeeStatusFilter { all, active, inactive }

enum EmployeeSort { nameAscending, nameDescending, employeeCode }

class EmployeeFilters extends StatelessWidget {
  const EmployeeFilters({
    required this.statusFilter,
    required this.employeeSort,
    required this.departmentId,
    required this.departments,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onSortChanged,
    required this.onDepartmentChanged,
    super.key,
  });

  final EmployeeStatusFilter statusFilter;
  final EmployeeSort employeeSort;
  final String? departmentId;
  final List<Department> departments;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<EmployeeStatusFilter> onStatusChanged;
  final ValueChanged<EmployeeSort> onSortChanged;
  final ValueChanged<String?> onDepartmentChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SearchBar(
        onChanged: onSearchChanged,
        leading: const Icon(Icons.search),
        hintText: context.l10n.search,
      ),
      const SizedBox(height: 12),
      LayoutBuilder(
        builder: (context, constraints) {
          final controls = <Widget>[
            DropdownMenu<EmployeeStatusFilter>(
              initialSelection: statusFilter,
              leadingIcon: const Icon(Icons.person_search_outlined),
              label: Text(context.l10n.active),
              dropdownMenuEntries: [
                DropdownMenuEntry(
                  value: EmployeeStatusFilter.all,
                  label: context.l10n.employeeDirectory,
                ),
                DropdownMenuEntry(
                  value: EmployeeStatusFilter.active,
                  label: context.l10n.active,
                ),
                DropdownMenuEntry(
                  value: EmployeeStatusFilter.inactive,
                  label: context.l10n.inactive,
                ),
              ],
              onSelected: (value) {
                if (value != null) onStatusChanged(value);
              },
            ),
            DropdownMenu<String?>(
              initialSelection: departmentId,
              leadingIcon: const Icon(Icons.apartment_outlined),
              label: Text(context.l10n.departmentName),
              dropdownMenuEntries: [
                DropdownMenuEntry<String?>(
                  value: null,
                  label: context.l10n.departmentName,
                ),
                for (final department in departments)
                  DropdownMenuEntry<String?>(
                    value: department.id,
                    label: department.name.isEmpty
                        ? department.code
                        : department.name,
                  ),
              ],
              onSelected: onDepartmentChanged,
            ),
            DropdownMenu<EmployeeSort>(
              initialSelection: employeeSort,
              leadingIcon: const Icon(Icons.sort_outlined),
              label: Text(context.l10n.search),
              dropdownMenuEntries: [
                DropdownMenuEntry(
                  value: EmployeeSort.nameAscending,
                  label: '${context.l10n.firstName} A–Z',
                ),
                DropdownMenuEntry(
                  value: EmployeeSort.nameDescending,
                  label: '${context.l10n.firstName} Z–A',
                ),
                DropdownMenuEntry(
                  value: EmployeeSort.employeeCode,
                  label: context.l10n.employeeCode,
                ),
              ],
              onSelected: (value) {
                if (value != null) onSortChanged(value);
              },
            ),
          ];

          if (constraints.maxWidth < 760) {
            return Wrap(spacing: 12, runSpacing: 12, children: controls);
          }

          return Row(
            children: [
              for (var index = 0; index < controls.length; index++) ...[
                Expanded(child: controls[index]),
                if (index != controls.length - 1)
                  const SizedBox(width: 12),
              ],
            ],
          );
        },
      ),
    ],
  );
}

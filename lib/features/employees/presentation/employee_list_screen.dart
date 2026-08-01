import 'package:flutter/material.dart';

import '../../../domain/entities/employee.dart';
import '../application/employee_controller.dart';
import '../application/employee_state.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({
    required this.controller,
    this.onAddEmployee,
    this.onEditEmployee,
    this.onDeleteEmployee,
    super.key,
  });

  final EmployeeController controller;
  final VoidCallback? onAddEmployee;
  final ValueChanged<Employee>? onEditEmployee;
  final ValueChanged<Employee>? onDeleteEmployee;

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.controller.state.query.searchText;
    widget.controller.addListener(_handleControllerChanged);
    if (widget.controller.state.items.isEmpty) {
      widget.controller.load();
    }
  }

  @override
  void didUpdateWidget(covariant EmployeeListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_handleControllerChanged);
    widget.controller.addListener(_handleControllerChanged);
    _searchController.text = widget.controller.state.query.searchText;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _EmployeeToolbar(
              searchController: _searchController,
              state: state,
              onSearch: widget.controller.search,
              onRefresh: widget.controller.load,
              onActiveOnlyChanged: widget.controller.setActiveOnly,
              onClearFilters: widget.controller.clearHierarchyFilters,
              onAddEmployee: widget.onAddEmployee,
            ),
            if (state.loading) const LinearProgressIndicator(),
            if (state.errorMessage != null)
              _EmployeeErrorBanner(
                message: state.errorMessage!,
                onDismiss: widget.controller.clearError,
                onRetry: widget.controller.load,
              ),
            Expanded(child: _buildContent(state)),
            _EmployeePagination(
              state: state,
              onPrevious: widget.controller.previousPage,
              onNext: widget.controller.nextPage,
              onPageSizeChanged: widget.controller.setPageSize,
            ),
          ],
        ),
      ),
      floatingActionButton: widget.onAddEmployee == null
          ? null
          : FloatingActionButton.extended(
              onPressed: widget.onAddEmployee,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add employee'),
            ),
    );
  }

  Widget _buildContent(EmployeeState state) {
    if (state.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.items.isEmpty) {
      return const _EmployeeEmptyState();
    }
    return RefreshIndicator(
      onRefresh: widget.controller.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: state.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final employee = state.items[index];
          return _EmployeeCard(
            employee: employee,
            onEdit: widget.onEditEmployee == null
                ? null
                : () => widget.onEditEmployee!(employee),
            onDelete: widget.onDeleteEmployee == null
                ? null
                : () => widget.onDeleteEmployee!(employee),
          );
        },
      ),
    );
  }
}

class _EmployeeToolbar extends StatelessWidget {
  const _EmployeeToolbar({
    required this.searchController,
    required this.state,
    required this.onSearch,
    required this.onRefresh,
    required this.onActiveOnlyChanged,
    required this.onClearFilters,
    this.onAddEmployee,
  });

  final TextEditingController searchController;
  final EmployeeState state;
  final ValueChanged<String> onSearch;
  final VoidCallback onRefresh;
  final ValueChanged<bool> onActiveOnlyChanged;
  final VoidCallback onClearFilters;
  final VoidCallback? onAddEmployee;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 360,
            child: SearchBar(
              controller: searchController,
              hintText: 'Search employees',
              leading: const Icon(Icons.search),
              trailing: [
                if (searchController.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      searchController.clear();
                      onSearch('');
                    },
                    icon: const Icon(Icons.clear),
                  ),
              ],
              onSubmitted: onSearch,
            ),
          ),
          FilterChip(
            label: const Text('Active only'),
            selected: state.query.activeOnly,
            onSelected: onActiveOnlyChanged,
          ),
          OutlinedButton.icon(
            onPressed: onClearFilters,
            icon: const Icon(Icons.filter_alt_off),
            label: const Text('Clear filters'),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
          if (onAddEmployee != null)
            FilledButton.icon(
              onPressed: onAddEmployee,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add employee'),
            ),
        ],
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({required this.employee, this.onEdit, this.onDelete});

  final Employee employee;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            employee.firstName.trim().isEmpty
                ? '?'
                : employee.firstName.trim()[0].toUpperCase(),
          ),
        ),
        title: Text(employee.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${employee.employeeCode} โ€ข ${employee.position}'),
            Text(
              '${employee.department.name} โ€ข ${employee.active ? 'Active' : 'Inactive'}',
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 4,
          children: [
            Icon(
              employee.active ? Icons.check_circle : Icons.pause_circle,
              color: employee.active
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            if (onEdit != null)
              IconButton(
                tooltip: 'Edit employee',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Delete employee',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmployeePagination extends StatelessWidget {
  const _EmployeePagination({
    required this.state,
    required this.onPrevious,
    required this.onNext,
    required this.onPageSizeChanged,
  });

  final EmployeeState state;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text('${state.totalItems} employees'),
            const Spacer(),
            const Text('Rows:'),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: state.query.pageSize,
              items: const [10, 20, 50, 100]
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text('$value')),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) onPageSizeChanged(value);
              },
            ),
            const SizedBox(width: 16),
            Text(
              'Page ${state.query.page} of ${state.totalPages == 0 ? 1 : state.totalPages}',
            ),
            IconButton(
              tooltip: 'Previous page',
              onPressed: state.hasPreviousPage ? onPrevious : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: 'Next page',
              onPressed: state.hasNextPage ? onNext : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeEmptyState extends StatelessWidget {
  const _EmployeeEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 56),
          SizedBox(height: 12),
          Text('No employees found'),
          SizedBox(height: 4),
          Text('Change the search or filters, or add a new employee.'),
        ],
      ),
    );
  }
}

class _EmployeeErrorBanner extends StatelessWidget {
  const _EmployeeErrorBanner({
    required this.message,
    required this.onDismiss,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onDismiss;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(message),
      leading: const Icon(Icons.error_outline),
      actions: [
        TextButton(onPressed: onRetry, child: const Text('Retry')),
        TextButton(onPressed: onDismiss, child: const Text('Dismiss')),
      ],
    );
  }
}

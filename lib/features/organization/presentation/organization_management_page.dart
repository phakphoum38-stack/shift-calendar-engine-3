import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workforce_core/workforce_core.dart';

import '../../../l10n/l10n.dart';
import '../application/organization_management_controller.dart';

class OrganizationManagementPage extends StatefulWidget {
  const OrganizationManagementPage({
    required this.controllerFactory,
    super.key,
  });

  final OrganizationManagementController Function() controllerFactory;

  @override
  State<OrganizationManagementPage> createState() =>
      _OrganizationManagementPageState();
}

class _OrganizationManagementPageState
    extends State<OrganizationManagementPage> {
  late final OrganizationManagementController controller = widget
      .controllerFactory();

  @override
  void initState() {
    super.initState();
    unawaited(controller.load());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                loading: state.loading,
                onRefresh: () => unawaited(controller.refresh()),
              ),
              const SizedBox(height: 16),
              _Summary(
                organizations: state.organizations.length,
                branches: state.branches.length,
                departments: state.departments.length,
                teams: state.teams.length,
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                MaterialBanner(
                  content: Text(state.errorMessage!),
                  actions: [
                    TextButton(
                      onPressed: () => unawaited(controller.load()),
                      child: Text(context.l10n.confirm),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    final hierarchy = _HierarchyPane(controller: controller);
                    final details = _DetailsPane(controller: controller);
                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 4, child: hierarchy),
                          const SizedBox(width: 16),
                          Expanded(flex: 6, child: details),
                        ],
                      );
                    }
                    return ListView(
                      children: [
                        SizedBox(height: 420, child: hierarchy),
                        const SizedBox(height: 16),
                        SizedBox(height: 360, child: details),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.loading, required this.onRefresh});

  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.organizationManagement,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(context.l10n.organizationManagementDescription),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: context.l10n.refresh,
          onPressed: loading ? null : onRefresh,
          icon: loading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.organizations,
    required this.branches,
    required this.departments,
    required this.teams,
  });

  final int organizations;
  final int branches;
  final int departments;
  final int teams;

  @override
  Widget build(BuildContext context) {
    final values = [
      (context.l10n.organizations, organizations, Icons.apartment_outlined),
      (context.l10n.branches, branches, Icons.account_tree_outlined),
      (context.l10n.departments, departments, Icons.domain_outlined),
      (context.l10n.teams, teams, Icons.groups_2_outlined),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final value in values)
          SizedBox(
            width: 180,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(value.$3),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${value.$2}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(value.$1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HierarchyPane extends StatelessWidget {
  const _HierarchyPane({required this.controller});

  final OrganizationManagementController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Text(
              context.l10n.organizationHierarchy,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (state.organizations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text(context.l10n.noOrganizations)),
              ),
            for (final organization in state.organizations)
              _OrganizationTile(
                organization: organization,
                controller: controller,
              ),
          ],
        ),
      ),
    );
  }
}

class _OrganizationTile extends StatelessWidget {
  const _OrganizationTile({
    required this.organization,
    required this.controller,
  });

  final Organization organization;
  final OrganizationManagementController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final selected = state.selectedOrganization?.id == organization.id;
    return ExpansionTile(
      key: ValueKey(organization.id),
      initiallyExpanded: selected,
      leading: const Icon(Icons.apartment_outlined),
      title: Text(organization.name),
      subtitle: Text(organization.code),
      onExpansionChanged: (expanded) {
        if (expanded) unawaited(controller.selectOrganization(organization));
      },
      children: selected
          ? [
              for (final branch in state.branches)
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 40, right: 8),
                  leading: const Icon(Icons.account_tree_outlined),
                  selected: state.selectedBranch?.id == branch.id,
                  title: Text(branch.name),
                  subtitle: Text(branch.code),
                  onTap: () => unawaited(controller.selectBranch(branch)),
                ),
              if (state.branches.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(context.l10n.noBranches),
                  ),
                ),
            ]
          : const [],
    );
  }
}

class _DetailsPane extends StatelessWidget {
  const _DetailsPane({required this.controller});

  final OrganizationManagementController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              context.l10n.details,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _EntityDetails(
              icon: Icons.apartment_outlined,
              label: context.l10n.organization,
              name: state.selectedOrganization?.name,
              code: state.selectedOrganization?.code,
            ),
            const Divider(height: 32),
            _ChoiceSection<Branch>(
              label: context.l10n.branch,
              values: state.branches,
              selected: state.selectedBranch,
              nameOf: (value) => value.name,
              codeOf: (value) => value.code,
              onSelected: (value) => unawaited(controller.selectBranch(value)),
            ),
            const Divider(height: 32),
            _ChoiceSection<Department>(
              label: context.l10n.department,
              values: state.departments,
              selected: state.selectedDepartment,
              nameOf: (value) => value.name,
              codeOf: (value) => value.code,
              onSelected: (value) =>
                  unawaited(controller.selectDepartment(value)),
            ),
            const Divider(height: 32),
            _ChoiceSection<Team>(
              label: context.l10n.team,
              values: state.teams,
              selected: state.selectedTeam,
              nameOf: (value) => value.name,
              codeOf: (value) => value.code,
              onSelected: controller.selectTeam,
            ),
          ],
        ),
      ),
    );
  }
}

class _EntityDetails extends StatelessWidget {
  const _EntityDetails({
    required this.icon,
    required this.label,
    required this.name,
    required this.code,
  });

  final IconData icon;
  final String label;
  final String? name;
  final String? code;

  @override
  Widget build(BuildContext context) {
    if (name == null) return Text(context.l10n.selectOrganization);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(name!),
      subtitle: Text('$label ยท $code'),
    );
  }
}

class _ChoiceSection<T> extends StatelessWidget {
  const _ChoiceSection({
    required this.label,
    required this.values,
    required this.selected,
    required this.nameOf,
    required this.codeOf,
    required this.onSelected,
  });

  final String label;
  final List<T> values;
  final T? selected;
  final String Function(T value) nameOf;
  final String Function(T value) codeOf;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (values.isEmpty)
          Text(context.l10n.noData)
        else
          DropdownButtonFormField<T>(
            initialValue: selected,
            isExpanded: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: label,
            ),
            items: [
              for (final value in values)
                DropdownMenuItem<T>(
                  value: value,
                  child: Text('${nameOf(value)} (${codeOf(value)})'),
                ),
            ],
            onChanged: onSelected,
          ),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../features/dashboard/application/dashboard_summary_service.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/employees/presentation/employees_page.dart';
import '../features/exchange/presentation/exchange_page.dart';
import '../features/reports/presentation/reports_page.dart';
import '../features/roster/application/roster_controller.dart';
import '../features/roster/application/roster_editor_controller.dart';
import '../features/roster/presentation/roster_page.dart';
import '../features/employees/application/employee_directory_controller.dart';
import '../features/shift_templates/application/shift_template_controller.dart';
import '../features/shift_templates/presentation/shift_templates_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../l10n/l10n.dart';
import '../domain/entities/schedule.dart';
import 'app_controller.dart';

/// Adaptive six-destination application shell.
class AppShell extends StatefulWidget {
  const AppShell({
    required this.controller,
    required this.dashboardSummaryService,
    required this.rosterControllerFactory,
    required this.rosterEditorControllerFactory,
    required this.employeeDirectoryControllerFactory,
    required this.shiftTemplateControllerFactory,
    super.key,
  });

  final AppController controller;
  final DashboardSummaryService dashboardSummaryService;
  final RosterController Function(Schedule schedule) rosterControllerFactory;
  final RosterEditorController Function(Schedule schedule)
  rosterEditorControllerFactory;
  final EmployeeDirectoryController Function(Schedule schedule)
  employeeDirectoryControllerFactory;
  final ShiftTemplateController Function() shiftTemplateControllerFactory;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        label: context.l10n.dashboard,
      ),
      NavigationDestination(
        icon: const Icon(Icons.calendar_month_outlined),
        label: context.l10n.roster,
      ),
      NavigationDestination(
        icon: const Icon(Icons.groups_outlined),
        label: context.l10n.employees,
      ),
      NavigationDestination(
        icon: const Icon(Icons.swap_horiz_outlined),
        label: context.l10n.exchange,
      ),
      NavigationDestination(
        icon: const Icon(Icons.assessment_outlined),
        label: context.l10n.reports,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        label: context.l10n.settings,
      ),
    ];
    final pages = [
      DashboardPage(
        schedule: widget.controller.schedule,
        summaryService: widget.dashboardSummaryService,
        openRoster: () => setState(() => selectedIndex = 1),
      ),
      RosterPage(
        schedule: widget.controller.schedule,
        controllerFactory: widget.rosterControllerFactory,
        editorControllerFactory: widget.rosterEditorControllerFactory,
        onScheduleSaved: widget.controller.adoptSchedule,
      ),
      EmployeesPage(
        schedule: widget.controller.schedule,
        controllerFactory: widget.employeeDirectoryControllerFactory,
      ),
      const ExchangePage(),
      const ReportsPage(),
      SettingsPage(
        settings: widget.controller.settings,
        onChanged: (value) =>
            unawaited(widget.controller.updateSettings(value)),
        openShiftTemplates: _openShiftTemplates,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        final body = IndexedStack(index: selectedIndex, children: pages);
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.appTitle)),
          body: wide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (value) =>
                          setState(() => selectedIndex = value),
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        for (final destination in destinations)
                          NavigationRailDestination(
                            icon: destination.icon,
                            label: Text(destination.label),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: body),
                  ],
                )
              : body,
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) =>
                      setState(() => selectedIndex = value),
                  destinations: destinations,
                ),
        );
      },
    );
  }

  void _openShiftTemplates() {
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (context) => ShiftTemplatesPage(
            controllerFactory: widget.shiftTemplateControllerFactory,
          ),
        ),
      ),
    );
  }
}

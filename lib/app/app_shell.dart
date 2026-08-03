import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/entities/schedule.dart';
import '../features/ai_scheduler/application/ai_scheduler_controller.dart';
import '../features/ai_scheduler/application/ai_scheduler_request_provider.dart';
import '../features/ai_scheduler/presentation/ai_scheduler_page.dart';
import '../features/ai_scheduler/presentation/ai_scheduler_runtime.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/dashboard/application/dashboard_summary_service.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/employees/application/employee_directory_controller.dart';
import '../features/employees/presentation/employees_page.dart';
import '../features/exchange/presentation/exchange_page.dart';
import '../features/organization/application/organization_management_controller.dart';
import '../features/organization/presentation/organization_management_page.dart';
import '../features/reports/application/report_controller.dart';
import '../features/reports/domain/monthly_roster_report.dart';
import '../features/reports/presentation/reports_page.dart';
import '../features/roster/application/drive_roster_source_controller.dart';
import '../features/roster/application/roster_controller.dart';
import '../features/roster/application/roster_editor_controller.dart';
import '../features/roster/presentation/roster_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/shift_templates/application/shift_template_controller.dart';
import '../features/shift_templates/presentation/shift_templates_page.dart';
import '../l10n/l10n.dart';
import 'app_controller.dart';

/// Adaptive application shell.
class AppShell extends StatefulWidget {
  const AppShell({
    required this.controller,
    required this.authController,
    required this.dashboardSummaryService,
    required this.rosterControllerFactory,
    required this.rosterEditorControllerFactory,
    required this.driveRosterSourceControllerFactory,
    required this.employeeDirectoryControllerFactory,
    required this.organizationManagementControllerFactory,
    required this.shiftTemplateControllerFactory,
    required this.reportControllerFactory,
    this.aiSchedulerController,
    this.aiSchedulerRequestProvider,
    super.key,
  });

  final AppController controller;
  final AuthController authController;
  final AiSchedulerController? aiSchedulerController;
  final AiSchedulerRequestProvider? aiSchedulerRequestProvider;
  final DashboardSummaryService dashboardSummaryService;
  final RosterController Function(Schedule schedule) rosterControllerFactory;
  final RosterEditorController Function(Schedule schedule)
  rosterEditorControllerFactory;
  final DriveRosterSourceController Function()
  driveRosterSourceControllerFactory;
  final EmployeeDirectoryController Function(Schedule schedule)
  employeeDirectoryControllerFactory;
  final OrganizationManagementController Function()
  organizationManagementControllerFactory;
  final ShiftTemplateController Function() shiftTemplateControllerFactory;
  final ReportController Function(
    Schedule schedule,
    MonthlyRosterReportOptions options,
  )
  reportControllerFactory;

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
      const NavigationDestination(
        icon: Icon(Icons.auto_awesome_outlined),
        label: 'AI Scheduler',
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
        icon: const Icon(Icons.account_tree_outlined),
        label: context.l10n.organizationManagement,
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
        openRoster: () => setState(() => selectedIndex = 2),
      ),
      _buildAiSchedulerPage(),
      RosterPage(
        schedule: widget.controller.schedule,
        controllerFactory: widget.rosterControllerFactory,
        editorControllerFactory: widget.rosterEditorControllerFactory,
        driveSourceControllerFactory: widget.driveRosterSourceControllerFactory,
        onScheduleSaved: widget.controller.adoptSchedule,
      ),
      EmployeesPage(
        schedule: widget.controller.schedule,
        controllerFactory: widget.employeeDirectoryControllerFactory,
      ),
      OrganizationManagementPage(
        controllerFactory: widget.organizationManagementControllerFactory,
      ),
      const ExchangePage(),
      ReportsPage(
        schedule: widget.controller.schedule,
        controllerFactory: widget.reportControllerFactory,
      ),
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
          appBar: AppBar(
            title: Text(context.l10n.appTitle),
            actions: [
              _AccountMenu(authController: widget.authController),
              const SizedBox(width: 8),
            ],
          ),
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

  Widget _buildAiSchedulerPage() {
    final controller = widget.aiSchedulerController;
    final requestProvider = widget.aiSchedulerRequestProvider;

    if (controller == null || requestProvider == null) {
      return AiSchedulerPage(onGenerate: _showSchedulerConnectionNotice);
    }

    return AiSchedulerRuntime(
      controller: controller,
      requestProvider: requestProvider,
      schedule: widget.controller.schedule,
      shiftTemplateControllerFactory: widget.shiftTemplateControllerFactory,
    );
  }

  void _showSchedulerConnectionNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'หน้า AI Scheduler พร้อมแล้ว กำลังเชื่อม Application Layer กับ Canonical Core',
        ),
      ),
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

enum _AccountAction { logout }

class _AccountMenu extends StatelessWidget {
  const _AccountMenu({required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final session = authController.state.session;
    final user = session?.user;
    final loading = authController.state.loading;

    return PopupMenuButton<_AccountAction>(
      tooltip: 'บัญชีผู้ใช้',
      enabled: !loading,
      onSelected: (action) async {
        switch (action) {
          case _AccountAction.logout:
            final confirmed = await _confirmLogout(context);

            if (!confirmed || !context.mounted) {
              return;
            }

            await authController.logout();
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem<_AccountAction>(
            enabled: false,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 220),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name.isNotEmpty == true ? user!.name : 'ผู้ใช้งาน',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem<_AccountAction>(
            value: _AccountAction.logout,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.logout_rounded),
              title: Text('ออกจากระบบ'),
            ),
          ),
        ];
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_initials(user?.name)),
            ),
            const SizedBox(width: 8),
            if (MediaQuery.sizeOf(context).width >= 720)
              Text(user?.name.isNotEmpty == true ? user!.name : 'บัญชี'),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  String _initials(String? name) {
    final normalized = name?.trim() ?? '';

    if (normalized.isEmpty) {
      return '?';
    }

    final parts = normalized
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  Future<bool> _confirmLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.logout_rounded),
          title: const Text('ออกจากระบบ'),
          content: const Text('ต้องการออกจากระบบบนอุปกรณ์นี้หรือไม่'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('ออกจากระบบ'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}

import 'package:flutter/material.dart';

import '../design_system/enterprise_tokens.dart';
import '../domain/entities/app_settings.dart';
import '../features/ai_scheduler/application/ai_scheduler_controller.dart';
import '../l10n/app_localizations.dart';
import 'ai_scheduler_dependencies.dart';
import 'app_controller.dart';
import 'app_dependencies.dart';
import 'app_shell.dart';

/// Root Material 3 application configured for Flutter-only operation.
class ShiftCalendarEngineApp extends StatefulWidget {
  const ShiftCalendarEngineApp({
    required this.dependencies,
    this.controller,
    this.aiSchedulerController,
    super.key,
  });

  final AppDependencies dependencies;
  final AppController? controller;
  final AiSchedulerController? aiSchedulerController;

  @override
  State<ShiftCalendarEngineApp> createState() => _ShiftCalendarEngineAppState();
}

class _ShiftCalendarEngineAppState extends State<ShiftCalendarEngineApp> {
  late final AppController controller =
      widget.controller ?? widget.dependencies.createAppController();

  late final AiSchedulerController aiSchedulerController =
      widget.aiSchedulerController ??
      widget.dependencies.createDefaultAiSchedulerController();

  late final bool ownsController = widget.controller == null;
  late final bool ownsAiSchedulerController =
      widget.aiSchedulerController == null;

  @override
  void initState() {
    super.initState();
    controller.initialize();
  }

  @override
  void dispose() {
    if (ownsController) {
      controller.dispose();
    }

    if (ownsAiSchedulerController) {
      aiSchedulerController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final settings = controller.settings;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: switch (settings.locale) {
            LocalePreference.system => null,
            LocalePreference.english => const Locale('en'),
            LocalePreference.thai => const Locale('th'),
          },
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          themeMode: switch (settings.theme) {
            ThemePreference.system => ThemeMode.system,
            ThemePreference.light => ThemeMode.light,
            ThemePreference.dark => ThemeMode.dark,
          },
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          home: controller.loading
              ? const _StartupScreen()
              : AppShell(
                  controller: controller,
                  dashboardSummaryService:
                      widget.dependencies.dashboardSummaryService,
                  rosterControllerFactory:
                      widget.dependencies.createRosterController,
                  rosterEditorControllerFactory:
                      widget.dependencies.createRosterEditorController,
                  driveRosterSourceControllerFactory:
                      widget.dependencies.createDriveRosterSourceController,
                  employeeDirectoryControllerFactory:
                      widget.dependencies.createEmployeeDirectoryController,
                  organizationManagementControllerFactory: widget
                      .dependencies
                      .createOrganizationManagementController,
                  shiftTemplateControllerFactory:
                      widget.dependencies.createShiftTemplateController,
                  reportControllerFactory:
                      widget.dependencies.createReportController,
                ),
        );
      },
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('กำลังโหลดข้อมูลในเครื่อง...'),
          ],
        ),
      ),
    );
  }
}

ThemeData _theme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: EnterpriseColors.seed,
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surfaceContainerLowest,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLowest,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: EnterpriseRadius.card,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
  );
}

import 'package:flutter/material.dart';

import '../domain/entities/app_settings.dart';
import '../l10n/app_localizations.dart';
import 'app_controller.dart';
import 'app_dependencies.dart';
import 'app_shell.dart';

/// Root Material 3 application configured by explicit dependencies.
class ShiftCalendarEngineApp extends StatefulWidget {
  const ShiftCalendarEngineApp({
    required this.dependencies,
    this.controller,
    super.key,
  });

  final AppDependencies dependencies;
  final AppController? controller;

  @override
  State<ShiftCalendarEngineApp> createState() => _ShiftCalendarEngineAppState();
}

class _ShiftCalendarEngineAppState extends State<ShiftCalendarEngineApp> {
  late final AppController controller =
      widget.controller ?? widget.dependencies.createAppController();
  late final bool ownsController = widget.controller == null;

  @override
  void initState() {
    super.initState();
    controller.initialize();
  }

  @override
  void dispose() {
    if (ownsController) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
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
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : AppShell(
                controller: controller,
                dashboardSummaryService:
                    widget.dependencies.dashboardSummaryService,
                rosterControllerFactory:
                    widget.dependencies.createRosterController,
                rosterEditorControllerFactory:
                    widget.dependencies.createRosterEditorController,
                employeeDirectoryControllerFactory:
                    widget.dependencies.createEmployeeDirectoryController,
                organizationManagementControllerFactory:
                    widget.dependencies.createOrganizationManagementController,
                shiftTemplateControllerFactory:
                    widget.dependencies.createShiftTemplateController,
                reportControllerFactory:
                    widget.dependencies.createReportController,
              ),
      );
    },
  );
}

ThemeData _theme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF006B68),
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surfaceContainerLowest,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
  );
}

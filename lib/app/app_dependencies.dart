import '../domain/entities/app_settings.dart';
import '../domain/repositories/schedule_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/repositories/employee_repository.dart';
import '../domain/repositories/shift_template_repository.dart';
import '../features/dashboard/application/dashboard_summary_service.dart';
import '../features/foundation/infrastructure/memory_schedule_repository.dart';
import '../features/foundation/infrastructure/memory_settings_repository.dart';
import '../features/foundation/infrastructure/shared_preferences_schedule_repository.dart';
import '../features/employees/application/employee_application_service.dart';
import '../features/employees/infrastructure/shared_preferences_employee_repository.dart';
import '../features/settings/infrastructure/shared_preferences_settings_repository.dart';
import '../features/shift_templates/infrastructure/shared_preferences_shift_template_repository.dart';
import '../features/roster/application/roster_controller.dart';
import '../features/roster/application/roster_editor_controller.dart';
import '../features/reports/application/monthly_roster_report_mapper.dart';
import '../features/reports/application/report_controller.dart';
import '../features/reports/application/report_service.dart';
import '../features/reports/domain/monthly_roster_report.dart';
import '../features/reports/infrastructure/monthly_roster_pdf_service.dart';
import '../features/reports/infrastructure/printing_report_output_gateway.dart';
import '../features/employees/application/employee_directory_controller.dart';
import '../features/shift_templates/application/shift_template_controller.dart';
import '../domain/entities/schedule.dart';
import 'app_controller.dart';

/// Explicit composition root for all production dependencies.
class AppDependencies {
  AppDependencies({
    ScheduleRepository? scheduleRepository,
    SettingsRepository? settingsRepository,
    EmployeeRepository? employeeRepository,
    ShiftTemplateRepository? shiftTemplateRepository,
    MonthlyRosterReportMapper? monthlyRosterReportMapper,
    this.reportServiceOverride,
    ReportOutputGateway? reportOutputGateway,
    this.dashboardSummaryService = const DashboardSummaryService(),
  }) : scheduleRepository = scheduleRepository ?? MemoryScheduleRepository(),
       settingsRepository =
           settingsRepository ??
           MemorySettingsRepository(initialSettings: const AppSettings()),
       employeeRepository =
           employeeRepository ?? SharedPreferencesEmployeeRepository(),
       shiftTemplateRepository =
           shiftTemplateRepository ??
           SharedPreferencesShiftTemplateRepository(),
       monthlyRosterReportMapper =
           monthlyRosterReportMapper ?? const MonthlyRosterReportMapper(),
       reportOutputGateway =
           reportOutputGateway ?? const PrintingReportOutputGateway();

  factory AppDependencies.production() {
    return AppDependencies(
      scheduleRepository: SharedPreferencesScheduleRepository(),
      settingsRepository: SharedPreferencesSettingsRepository(),
    );
  }

  final ScheduleRepository scheduleRepository;
  final SettingsRepository settingsRepository;
  final EmployeeRepository employeeRepository;
  final ShiftTemplateRepository shiftTemplateRepository;
  final DashboardSummaryService dashboardSummaryService;
  final MonthlyRosterReportMapper monthlyRosterReportMapper;
  final ReportOutputGateway reportOutputGateway;
  final MonthlyRosterReportService? reportServiceOverride;

  MonthlyRosterReportService get monthlyRosterReportService =>
      reportServiceOverride ??
      MonthlyRosterPdfService(mapper: monthlyRosterReportMapper);

  EmployeeApplicationService get employeeApplicationService =>
      EmployeeApplicationService(repository: employeeRepository);

  AppController createAppController() {
    return AppController(
      scheduleRepository: scheduleRepository,
      settingsRepository: settingsRepository,
    );
  }

  RosterController createRosterController(Schedule schedule) {
    return RosterController(schedule: schedule);
  }

  RosterEditorController createRosterEditorController(Schedule schedule) {
    return RosterEditorController(
      scheduleRepository: scheduleRepository,
      employeeRepository: employeeRepository,
      shiftTemplateRepository: shiftTemplateRepository,
      schedule: schedule,
    );
  }

  EmployeeDirectoryController createEmployeeDirectoryController(
    Schedule schedule,
  ) {
    return EmployeeDirectoryController(
      repository: employeeRepository,
      schedule: schedule,
    );
  }

  EmployeeApplicationService createEmployeeApplicationService() {
    return EmployeeApplicationService(repository: employeeRepository);
  }

  ShiftTemplateController createShiftTemplateController() {
    return ShiftTemplateController(repository: shiftTemplateRepository);
  }

  ReportController createReportController(
    Schedule schedule,
    MonthlyRosterReportOptions options,
  ) {
    return ReportController(
      schedule: schedule,
      reportService: monthlyRosterReportService,
      outputGateway: reportOutputGateway,
      initialOptions: options,
    );
  }
}

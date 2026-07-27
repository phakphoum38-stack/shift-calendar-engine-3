import '../domain/entities/app_settings.dart';
import '../domain/repositories/schedule_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/repositories/employee_repository.dart';
import '../domain/repositories/shift_template_repository.dart';
import '../features/dashboard/application/dashboard_summary_service.dart';
import '../features/foundation/infrastructure/memory_schedule_repository.dart';
import '../features/foundation/infrastructure/memory_settings_repository.dart';
import '../features/foundation/infrastructure/shared_preferences_schedule_repository.dart';
import '../features/employees/infrastructure/shared_preferences_employee_repository.dart';
import '../features/settings/infrastructure/shared_preferences_settings_repository.dart';
import '../features/shift_templates/infrastructure/shared_preferences_shift_template_repository.dart';
import '../features/roster/application/roster_controller.dart';
import '../features/roster/application/roster_editor_controller.dart';
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
    this.dashboardSummaryService = const DashboardSummaryService(),
  }) : scheduleRepository = scheduleRepository ?? MemoryScheduleRepository(),
       settingsRepository =
           settingsRepository ??
           MemorySettingsRepository(initialSettings: const AppSettings()),
       employeeRepository =
           employeeRepository ?? SharedPreferencesEmployeeRepository(),
       shiftTemplateRepository =
           shiftTemplateRepository ??
           SharedPreferencesShiftTemplateRepository();

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

  ShiftTemplateController createShiftTemplateController() {
    return ShiftTemplateController(repository: shiftTemplateRepository);
  }
}

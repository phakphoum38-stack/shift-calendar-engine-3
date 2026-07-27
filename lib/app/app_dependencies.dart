import '../domain/entities/app_settings.dart';
import '../domain/repositories/schedule_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../features/dashboard/application/dashboard_summary_service.dart';
import '../features/foundation/infrastructure/memory_schedule_repository.dart';
import '../features/foundation/infrastructure/memory_settings_repository.dart';
import '../features/roster/application/roster_controller.dart';
import '../domain/entities/schedule.dart';
import 'app_controller.dart';

/// Explicit composition root for all production dependencies.
class AppDependencies {
  AppDependencies({
    ScheduleRepository? scheduleRepository,
    SettingsRepository? settingsRepository,
    this.dashboardSummaryService = const DashboardSummaryService(),
  }) : scheduleRepository = scheduleRepository ?? MemoryScheduleRepository(),
       settingsRepository =
           settingsRepository ??
           MemorySettingsRepository(initialSettings: const AppSettings());

  factory AppDependencies.production() => AppDependencies();

  final ScheduleRepository scheduleRepository;
  final SettingsRepository settingsRepository;
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
}

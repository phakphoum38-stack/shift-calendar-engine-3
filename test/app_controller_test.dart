import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/app/app_controller.dart';
import 'package:shift_calendar_engine/domain/entities/app_settings.dart';
import 'package:shift_calendar_engine/features/foundation/infrastructure/memory_schedule_repository.dart';
import 'package:shift_calendar_engine/features/foundation/infrastructure/memory_settings_repository.dart';

void main() {
  test(
    'controller loads settings and activates demo only explicitly',
    () async {
      final controller = AppController(
        scheduleRepository: MemoryScheduleRepository(),
        settingsRepository: MemorySettingsRepository(),
        clock: () => DateTime(2027, 4, 12),
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      expect(controller.schedule.assignments, isEmpty);

      await controller.updateSettings(
        const AppSettings(locale: LocalePreference.thai, demoMode: true),
      );

      expect(controller.settings.locale, LocalePreference.thai);
      expect(controller.schedule.assignments, hasLength(1));
    },
  );
}

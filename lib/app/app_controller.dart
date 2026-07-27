import 'package:flutter/foundation.dart';

import '../core/result/result.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/schedule.dart';
import '../domain/repositories/schedule_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../features/foundation/application/demo_schedule_factory.dart';

/// Root orchestration state; feature business logic remains in services.
class AppController extends ChangeNotifier {
  AppController({
    required this.scheduleRepository,
    required this.settingsRepository,
    this.demoScheduleFactory = const DemoScheduleFactory(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final ScheduleRepository scheduleRepository;
  final SettingsRepository settingsRepository;
  final DemoScheduleFactory demoScheduleFactory;
  final DateTime Function() _clock;

  Schedule _schedule = Schedule(id: 'active', name: 'Roster');
  AppSettings _settings = const AppSettings();
  bool _loading = false;
  String? _error;

  Schedule get schedule => _schedule;
  AppSettings get settings => _settings;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> initialize() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    final settingsResult = await settingsRepository.load();
    if (settingsResult case Success<AppSettings>(value: final value)) {
      _settings = value;
    } else if (settingsResult case Failure<AppSettings>()) {
      _error = settingsResult.message;
    }

    final scheduleResult = await scheduleRepository.loadActive();
    if (scheduleResult case Success<Schedule?>(value: final value)) {
      _schedule =
          value ??
          (_settings.demoMode
              ? demoScheduleFactory.create(_clock())
              : Schedule(id: 'active', name: 'Roster'));
    } else if (scheduleResult case Failure<Schedule?>()) {
      _error = scheduleResult.message;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings settings) async {
    final result = await settingsRepository.save(settings);
    if (result case Success<AppSettings>(value: final value)) {
      final demoChanged = _settings.demoMode != value.demoMode;
      _settings = value;
      if (demoChanged) {
        _schedule = value.demoMode
            ? demoScheduleFactory.create(_clock())
            : Schedule(id: 'active', name: 'Roster');
      }
      _error = null;
    } else if (result case Failure<AppSettings>()) {
      _error = result.message;
    }
    notifyListeners();
  }

  void adoptSchedule(Schedule schedule) {
    if (identical(schedule, _schedule)) return;
    _schedule = schedule;
    notifyListeners();
  }
}

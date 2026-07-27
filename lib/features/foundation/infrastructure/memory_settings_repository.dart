import '../../../core/result/result.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../domain/repositories/settings_repository.dart';

/// Process-local settings store with an injectable initial value.
class MemorySettingsRepository implements SettingsRepository {
  MemorySettingsRepository({AppSettings initialSettings = const AppSettings()})
    : _settings = initialSettings;

  AppSettings _settings;

  @override
  Future<Result<AppSettings>> load() async => Success(_settings);

  @override
  Future<Result<AppSettings>> save(AppSettings settings) async {
    _settings = settings;
    return Success(settings);
  }
}

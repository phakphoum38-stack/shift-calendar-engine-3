import '../../core/result/result.dart';
import '../entities/app_settings.dart';

/// Persistence boundary for application preferences.
abstract interface class SettingsRepository {
  Future<Result<AppSettings>> load();

  Future<Result<AppSettings>> save(AppSettings settings);
}

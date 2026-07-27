import 'dart:convert';

import '../../../core/result/result.dart';
import '../../../core/storage/atomic_string_store.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../domain/repositories/settings_repository.dart';

/// Atomic production repository for locale, theme, and demo preferences.
class SharedPreferencesSettingsRepository implements SettingsRepository {
  SharedPreferencesSettingsRepository({AtomicStringStore? store})
    : store =
          store ?? AtomicStringStore(keyPrefix: 'sce3.application_settings.v1');

  final AtomicStringStore store;

  @override
  Future<Result<AppSettings>> load() async {
    try {
      final payload = await store.read();
      if (payload == null) return const Success(AppSettings());
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, Object?> || decoded['formatVersion'] != 1) {
        return const ValidationFailure('Unsupported settings format.');
      }
      return Success(
        AppSettings(
          locale: _locale(decoded['locale']),
          theme: _theme(decoded['theme']),
          demoMode: decoded['demoMode'] == true,
        ),
      );
    } on Object catch (error, stackTrace) {
      return PersistenceFailure(
        'Could not load application settings.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Result<AppSettings>> save(AppSettings settings) async {
    try {
      await store.write(
        jsonEncode({
          'formatVersion': 1,
          'locale': settings.locale.name,
          'theme': settings.theme.name,
          'demoMode': settings.demoMode,
        }),
      );
      return Success(settings);
    } on Object catch (error, stackTrace) {
      return PersistenceFailure(
        'Could not save application settings.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  LocalePreference _locale(Object? value) {
    return LocalePreference.values
            .where((item) => item.name == value)
            .firstOrNull ??
        LocalePreference.system;
  }

  ThemePreference _theme(Object? value) {
    return ThemePreference.values
            .where((item) => item.name == value)
            .firstOrNull ??
        ThemePreference.system;
  }
}

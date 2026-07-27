/// Supported runtime locale selection.
enum LocalePreference { system, english, thai }

/// Supported runtime theme selection.
enum ThemePreference { system, light, dark }

/// User-owned non-schedule application preferences.
class AppSettings {
  const AppSettings({
    this.locale = LocalePreference.system,
    this.theme = ThemePreference.system,
    this.demoMode = false,
  });

  final LocalePreference locale;
  final ThemePreference theme;
  final bool demoMode;

  AppSettings copyWith({
    LocalePreference? locale,
    ThemePreference? theme,
    bool? demoMode,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      theme: theme ?? this.theme,
      demoMode: demoMode ?? this.demoMode,
    );
  }
}

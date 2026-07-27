import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// Convenient localization lookup for presentation code.
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

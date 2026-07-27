import 'package:flutter/material.dart';

import '../../../domain/entities/app_settings.dart';
import '../../../l10n/l10n.dart';

/// Functional language, theme, and demo-mode settings.
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.settings,
    required this.onChanged,
    required this.openShiftTemplates,
    super.key,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings> onChanged;
  final VoidCallback openShiftTemplates;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        context.l10n.workspaceSettings,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.language,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SegmentedButton<LocalePreference>(
                segments: [
                  ButtonSegment(
                    value: LocalePreference.system,
                    label: Text(context.l10n.followSystem),
                  ),
                  ButtonSegment(
                    value: LocalePreference.thai,
                    label: Text(context.l10n.thai),
                  ),
                  ButtonSegment(
                    value: LocalePreference.english,
                    label: Text(context.l10n.english),
                  ),
                ],
                selected: {settings.locale},
                onSelectionChanged: (value) =>
                    onChanged(settings.copyWith(locale: value.single)),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.theme,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SegmentedButton<ThemePreference>(
                segments: [
                  ButtonSegment(
                    value: ThemePreference.system,
                    label: Text(context.l10n.systemTheme),
                  ),
                  ButtonSegment(
                    value: ThemePreference.light,
                    label: Text(context.l10n.lightTheme),
                  ),
                  ButtonSegment(
                    value: ThemePreference.dark,
                    label: Text(context.l10n.darkTheme),
                  ),
                ],
                selected: {settings.theme},
                onSelectionChanged: (value) =>
                    onChanged(settings.copyWith(theme: value.single)),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Card(
        child: ListTile(
          leading: const Icon(Icons.view_timeline_outlined),
          title: Text(context.l10n.shiftTemplates),
          subtitle: Text(context.l10n.shiftTemplatesDescription),
          trailing: const Icon(Icons.chevron_right),
          onTap: openShiftTemplates,
        ),
      ),
      const SizedBox(height: 16),
      Card(
        child: SwitchListTile(
          title: Text(context.l10n.demoMode),
          subtitle: Text(context.l10n.demoModeDescription),
          value: settings.demoMode,
          onChanged: (value) => onChanged(settings.copyWith(demoMode: value)),
        ),
      ),
      const SizedBox(height: 16),
      Card(
        child: ListTile(
          leading: const Icon(Icons.architecture_outlined),
          title: Text(context.l10n.phaseStatus),
          subtitle: Text(context.l10n.phaseStatusDescription),
        ),
      ),
    ],
  );
}

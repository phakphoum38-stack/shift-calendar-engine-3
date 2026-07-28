import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/l10n.dart';
import '../../../l10n/localized_date_format.dart';
import '../application/drive_roster_source_controller.dart';
import '../domain/drive_roster_source.dart';

class GoogleDriveSourcePanel extends StatelessWidget {
  const GoogleDriveSourcePanel({required this.controller, super.key});

  final DriveRosterSourceController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final l10n = context.l10n;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.googleDrive,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(l10n.googleDriveDescription),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: controller.loading ? null : controller.refresh,
                    icon: const Icon(Icons.add_to_drive_outlined),
                    label: Text(l10n.openGoogleDrive),
                  ),
                ],
              ),
              if (controller.loading) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
              if (controller.errorCode != null) ...[
                const SizedBox(height: 16),
                Text(
                  controller.errorCode == 'google_drive_not_configured'
                      ? l10n.googleDriveNotConfigured
                      : l10n.googleDriveLoadFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                l10n.recentlyModified,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (controller.recentSources.isEmpty)
                Text(l10n.noDriveRosterFiles)
              else
                for (final source in controller.recentSources)
                  CheckboxListTile(
                    value: controller.selectedSource?.id == source.id,
                    onChanged: (selected) =>
                        controller.select(selected == true ? source : null),
                    title: Text(source.name),
                    subtitle: Text(_sourceDetails(context, source)),
                    secondary: const Icon(Icons.description_outlined),
                  ),
              const Divider(height: 32),
              Text(
                l10n.lastImported,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (controller.lastImported case final source?)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history),
                  title: Text(source.name),
                  subtitle: Text(_sourceDetails(context, source)),
                )
              else
                Text(l10n.noLastImportedSource),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed:
                      controller.selectedSource == null || controller.loading
                      ? null
                      : () => _loadSelected(context),
                  icon: const Icon(Icons.download_outlined),
                  label: Text(l10n.loadCurrentSource),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  String _sourceDetails(BuildContext context, DriveRosterSource source) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final rosterMonth = formatLocalizedDate(
      DateFormat.yMMMM(locale),
      source.rosterMonth,
      locale: locale,
    );
    final modifiedTime = formatLocalizedDate(
      DateFormat.yMMMd(locale).add_Hm(),
      source.modifiedTime,
      locale: locale,
    );
    return '$rosterMonth • $modifiedTime';
  }

  Future<void> _loadSelected(BuildContext context) async {
    final loaded = await controller.loadCurrentSource();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loaded
              ? context.l10n.driveSourceLoaded
              : context.l10n.googleDriveLoadFailed,
        ),
      ),
    );
  }
}

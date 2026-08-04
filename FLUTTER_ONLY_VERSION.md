# Shift Calendar Engine 3 — Flutter-only Drive Version

Branch: `flutter-only-drive`

This branch is the standalone Flutter version of Shift Calendar Engine 3.

## Architecture

- Flutter is the application runtime.
- Local persistence remains the primary source for offline use.
- Google Drive integration is the external storage and backup boundary.
- No Laravel, PHP, Composer, Sanctum, backend database, or backend deployment is required.

## Data flow

```text
Flutter UI
    ↓
Application services
    ↓
Domain repositories
    ↓
Local storage / Google Drive
```

## Intended capabilities

- Run on Web, Android, iOS, Windows, macOS, and Linux.
- Manage roster data locally.
- Select or receive files from the owner's Google Drive.
- Upload backups and updated roster files to Google Drive.
- Continue working offline and synchronize when a connection is available.

## Security

Do not commit Google OAuth secrets, access tokens, refresh tokens, private roster data, or exported user reports.

## Development

```bash
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter run
```

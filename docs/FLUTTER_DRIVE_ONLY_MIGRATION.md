# Flutter + Google Drive Migration

Branch: `feature/flutter-drive-only`

## Goal

Keep the current Flutter application and remove the Laravel runtime dependency. Data ownership moves to Flutter repositories with local persistence and Google Drive backup/sync.

## Target architecture

```text
Flutter UI
    ↓
Application services
    ↓
Domain repository contracts
    ↓
Flutter infrastructure
    ├── SharedPreferences / local files
    └── Google Drive
```

## Completed foundation

- Production dependency wiring uses local Flutter repositories.
- Laravel API authentication is bypassed.
- The login/session gate is removed from the application root.
- Employee data uses the local repository instead of the remote Laravel repository.
- Laravel-only client packages are removed from `pubspec.yaml`.
- Laravel CI is removed from this branch.
- `main` remains unchanged.

## Remaining cleanup

- Delete the unused `backend/` Laravel source tree from this branch.
- Delete unused Flutter API/auth/network classes and their tests.
- Replace the unconfigured Drive gateway with Google Sign-In and Google Drive API implementations.
- Add backup, restore, conflict handling, and sync status.
- Run formatting, analysis, tests, and platform builds.

## Safety

Do not commit OAuth client secrets, access tokens, personal roster data, or generated reports.

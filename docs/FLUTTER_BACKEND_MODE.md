# Flutter Backend Mode

This version runs without Laravel or a separate application server.

The Flutter application owns the application service layer and persists data through local repositories. Google Drive is the optional external storage and synchronization boundary.

## Runtime architecture

```text
Flutter UI
  -> Application controllers/services
  -> Domain repositories
  -> SharedPreferences / local files
  -> Google Drive (optional backup, restore, and file exchange)
```

## Removed runtime dependencies

- Laravel
- PHP and Composer
- Sanctum authentication
- API base URL configuration
- Remote employee repository
- Server-side database requirement

The `main` branch remains unchanged. This document applies to the dedicated Flutter-only branch.

# Testing

Every feature requires focused tests for domain behavior, controller state,
repository failures, and critical widget paths.

Local gate:

```bash
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
git diff --check
```

Tests must be deterministic and must not require live Google accounts,
production data, network access, or platform signing.

Integration tests will cover import-to-roster, validation-to-preview,
approval-to-roster, and roster-to-calendar workflows as those phases land.

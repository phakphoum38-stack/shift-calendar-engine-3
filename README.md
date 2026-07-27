# Shift Calendar Engine 3.0

Clean-room, cross-platform Flutter implementation of a configurable roster
system for workplaces, clinics, and hospitals.

Supported targets:

- Web
- Android
- iOS
- Windows
- macOS
- Linux

## Current milestone

Phase 0 foundation and the first Phase 2 vertical slice are operational:

- canonical `Schedule` aggregate
- explicit `AppDependencies` composition root
- Material 3 responsive shell
- Dashboard and monthly roster viewer
- canonical employee directory projection
- Thai and English localization
- system/light/dark themes
- deterministic opt-in Demo mode
- atomic local persistence for the canonical schedule
- persistent employee and configurable shift-template catalogs
- canonical manual roster editing with preview and explicit save
- format, analysis, test, security, and multi-platform build workflows

Phase 2 is complete with a canonical monthly A4 report, Thai/English PDF
rendering, preview, printing, and sharing.

The repository is intentionally separate from the production
`phakphum-calendar` migration. No legacy runtime was copied into this project.

## Run locally

Requirements:

- Flutter stable compatible with Dart 3.12 or newer
- platform toolchain for the target being built

```bash
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter run
```

## Architecture

```text
Presentation
    ↓
Application controllers and services
    ↓
Domain entities and repository contracts
    ↑
Infrastructure repository implementations

AppDependencies constructs the graph.
```

The canonical `Schedule` is the only scheduling source of truth. Provider,
import, report, and compatibility models must adapt at explicit boundaries.

See:

- [Architecture](docs/ARCHITECTURE.md)
- [Roadmap](docs/ROADMAP.md)
- [Contributing](CONTRIBUTING.md)
- [Testing](docs/TESTING.md)
- [Installation](docs/INSTALLATION.md)
- [User guide](docs/USER_GUIDE.md)
- [Security](SECURITY.md)

## Repository safety

Do not commit Google credentials, OAuth secrets, service-account files,
calendar identifiers, personal roster data, or generated user reports.

## License

No license has been selected yet. Source is publicly visible, but reuse rights
remain reserved until an explicit license is added.

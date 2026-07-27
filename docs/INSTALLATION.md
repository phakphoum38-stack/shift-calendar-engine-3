# Installation Guide

Shift Calendar Engine 3.0 is a Flutter application for Android, iOS, Web,
Windows, macOS, and Linux. This guide covers development installation. Signed
store releases are not available yet.

## Requirements

- Git
- Flutter stable with Dart 3.12 or newer
- A supported platform toolchain from `flutter doctor`

Additional platform requirements:

- Android: Android Studio, Android SDK, and a compatible JDK
- iOS and macOS: macOS with Xcode and CocoaPods
- Windows: Visual Studio with Desktop development with C++
- Linux: CMake, Ninja, Clang, and GTK 3 development libraries
- Web: Chrome or another Flutter-supported browser

## Clone and verify

```bash
git clone https://github.com/phakphoum38-stack/shift-calendar-engine-3.git
cd shift-calendar-engine-3
flutter doctor
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

Do not add Google credentials, signing files, personal roster data, or
generated reports to the repository.

## Run the application

List available devices:

```bash
flutter devices
```

Run on a selected target:

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

For Android or iOS, start an emulator/simulator or connect a device before
running `flutter run`.

## Build release artifacts

```bash
flutter build web --release
flutter build apk --release
flutter build windows --release
flutter build macos --release
flutter build linux --release
flutter build ios --release --no-codesign
```

Only run commands supported by the host operating system. GitHub Actions
validates all six targets after changes reach `main`.

## Local data

The current implementation stores the canonical schedule, employees, shift
templates, and application settings in platform SharedPreferences. Storage is
local to the application installation and device. Uninstalling the application
or clearing application data can remove it. Backup and restore are planned for
Phase 8.

## PDF and printing

The report screen uses the platform print/share services supported by the
`printing` package. Browser restrictions, desktop print configuration, or
mobile share-sheet availability can affect the actions. PDF generation itself
is local and embeds the bundled Noto Sans Thai font.

## Troubleshooting

- Run `flutter doctor -v` and resolve target-specific warnings.
- Run `flutter clean` only for generated build artifacts, then
  `flutter pub get`; it does not repair application data.
- If generated localization classes are stale, run `flutter gen-l10n`.
- If printing is unavailable, confirm that the target has a configured printer
  or share provider and retry PDF preview first.
- Compare local failures with the latest GitHub Actions run before changing
  dependencies or platform configuration.

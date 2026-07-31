# Development Guide

## Requirements

- Flutter stable compatible with Dart 3.12 or newer
- Git
- A supported platform toolchain for the target you are building
- Optional: Docker and VS Code Dev Containers
- Optional: Python `pre-commit`

## Bootstrap

```bash
git clone https://github.com/phakphoum38-stack/shift-calendar-engine-3.git
cd shift-calendar-engine-3
make bootstrap
```

Equivalent commands:

```bash
flutter pub get
flutter gen-l10n
```

## Run locally

```bash
flutter run -d chrome
```

Use `flutter devices` to inspect available targets.

## Quality gate

Run before opening a pull request:

```bash
make quality
flutter build web --release
```

The quality gate checks formatting, static analysis, and tests.

## Dev Container

Open the repository in VS Code and choose **Dev Containers: Reopen in Container**. The container restores Flutter dependencies and generates localization files automatically.

## Pre-commit hooks

Install and activate the optional hooks:

```bash
python -m pip install pre-commit
pre-commit install
pre-commit install --hook-type pre-push
```

The commit hook checks Dart formatting and analysis. The pre-push hook runs the test suite.

## Branch and commit conventions

Create focused branches from `main` and use Conventional Commit prefixes such as `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, and `chore:`.

Do not commit credentials, OAuth secrets, signing keys, production data, or personal roster information.

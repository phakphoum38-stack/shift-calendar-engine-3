# Engineering Fleet and Version Roadmap

## Current version

The application manifest currently reports:

- App version: `1.0.0+1`
- Active development milestone: Sprint 7.4 / roster evaluation foundation
- Active branch: `feature/roster-constraint-engine-v1`

The manifest version is not automatically increased for every sprint. A version is changed only when a release boundary is approved and validated.

## Eight-worker engineering fleet

### Code workers

1. **Code 1 — Format and localization**
   - restore dependencies
   - generate localization
   - verify Dart formatting

2. **Code 2 — Flutter analysis**
   - run static analysis for the Flutter application

3. **Code 3 — Application tests**
   - run Flutter tests
   - collect coverage

4. **Code 4 — Workforce Core tests**
   - restore package dependencies
   - run package analysis
   - run framework-independent domain tests

### Build workers

1. **Build 1 — Web**
   - create a release web bundle

2. **Build 2 — Android**
   - create a release APK

3. **Build 3 — Linux**
   - create a Linux desktop release bundle

4. **Build 4 — Windows**
   - create a Windows desktop release bundle

The GitHub workflow runs the four code workers first. All four must pass before the four build workers start.

## Local execution

From the repository root on PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\run_flutter_fleet.ps1
```

The local script runs every supported task in sequence and stops immediately on the first failure. Platform builds that cannot run on the current operating system are delegated to GitHub Actions.

## Release roadmap

### Version 1.1.0 — Constraint and evaluation foundation

- roster constraints
- leave and availability validation
- fairness scoring
- unified evaluation report
- complete framework-independent tests

### Version 1.2.0 — Scheduler foundation

- scheduler request and result models
- deterministic greedy scheduler
- constraint-aware candidate selection
- evaluation of generated schedules
- reproducibility tests

### Version 1.3.0 — Organization-aware scheduling

- branch, department, and team restrictions
- skills and role requirements
- minimum staffing rules
- shift-template integration

### Version 2.0.0 — Production roster workflow

- scheduler UI
- preview and explicit save
- conflict explanation
- manual correction flow
- audit trail

### Version 3.0.0 — Calendar and data exchange

- Google Calendar synchronization
- Google Sheets import and export
- resilient sync and duplicate prevention
- offline queue and retry behavior

### Version 4.0.0 — Optimization and reporting

- advanced fairness optimization
- holiday and weekend balancing
- organization dashboards
- production reports and operational analytics

### Version 5.0.0 — AI-assisted scheduling

- explainable scheduling assistant
- rule-aware suggestions
- optimization recommendations
- guarded approval workflow
- no autonomous publishing without explicit confirmation

## Definition of done for each version

Every release must pass:

```text
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
packages/workforce_core: dart analyze
packages/workforce_core: dart test
flutter build web --release
flutter build apk --release
flutter build linux --release
flutter build windows --release
```

A release is not marked complete until the required checks and supported platform builds succeed in GitHub Actions.

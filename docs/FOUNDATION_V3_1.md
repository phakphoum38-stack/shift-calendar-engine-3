# Foundation v3.1

## Goal

Strengthen the existing Flutter application without performing a risky all-at-once monorepo migration.

## Delivery order

1. Document architecture decisions.
2. Complete and refactor the Employee module.
3. Add controller and widget tests.
4. Define scheduling rule contracts inside the existing project.
5. Extract packages only after stable boundaries and tests exist.

## Guardrails

- Preserve the current canonical domain model.
- Keep business logic outside Flutter widgets.
- Avoid breaking persistence formats without an explicit migration.
- Keep Thai and English localization complete.
- Require `dart format`, `flutter analyze`, and relevant tests before merge.
- Prefer small, reviewable pull requests.

## Planned increments

### Increment 1 — Architecture records

- ADR process
- Clean Architecture decision
- Package extraction decision
- Rule engine decision
- Offline-first decision
- Testing strategy

### Increment 2 — Employee presentation refactor

- Extract header, summary, filters, list, card, empty state, and dialog widgets.
- Preserve existing behavior while reducing page complexity.
- Add widget tests for search, filters, sorting, empty state, edit, and deactivate flows.

### Increment 3 — Rule engine contracts

- `SchedulingRule`
- `RuleContext`
- `RuleResult`
- deterministic rule evaluation order
- unit tests with no Flutter dependency

### Increment 4 — Package extraction assessment

Package extraction will begin only when dependency boundaries are stable and test coverage protects behavior. The first candidates are workforce core and rule engine. The Flutter application will remain at the repository root until a migration plan proves that moving it provides more benefit than disruption.

## Definition of done

Foundation v3.1 is complete when architecture decisions are recorded, Employee presentation responsibilities are separated, relevant tests pass, and the first framework-independent rule contracts exist.

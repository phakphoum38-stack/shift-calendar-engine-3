# Architecture

## Principles

- Canonical `Schedule` is the roster source of truth.
- Domain code has no Flutter widget or provider dependencies.
- Business rules live in application/domain services, never widgets.
- Repositories are domain contracts; infrastructure implements them.
- `AppDependencies` is the single production composition root.
- Controllers receive dependencies explicitly and own observable UI state.
- Compatibility adapters exist only at system boundaries.
- Bulk mutations require preview and confirmation.

## Topology

```text
lib/
├── app/
│   ├── app.dart
│   ├── app_controller.dart
│   ├── app_dependencies.dart
│   └── app_shell.dart
├── core/
│   ├── result/
│   └── widgets/
├── domain/
│   ├── entities/
│   └── repositories/
├── features/
│   ├── dashboard/
│   ├── employees/
│   ├── exchange/
│   ├── foundation/
│   ├── reports/
│   ├── roster/
│   └── settings/
├── l10n/
└── main.dart
```

Each production feature grows through:

```text
domain → application → infrastructure → presentation
```

Dependencies point inward. Infrastructure may depend on domain contracts;
domain code never imports infrastructure or presentation.

## Lifecycle

`main.dart` creates `AppDependencies.production()`. The root app creates and
owns `AppController`. Feature routes own and dispose their independently
created controllers. Expensive provider clients will be created lazily when
their feature route is opened.

## Persistence roadmap

The Phase 0 repository is deliberately process-local. Phase 2 introduces a
versioned canonical schedule codec and atomic local repository. Legacy data
migration is not relevant to this clean repository and must be implemented only
as an explicit opt-in import adapter.

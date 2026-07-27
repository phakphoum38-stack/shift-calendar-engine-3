# Contributing

1. Create a focused branch from `main`.
2. Keep domain decisions independent from Flutter widgets.
3. Register production dependencies only in `AppDependencies`.
4. Add tests and documentation with every feature.
5. Run the full local gate before opening a pull request.
6. Never commit credentials or personal roster information.

Public classes require DartDoc. Files should remain below 500 lines. Prefer
composition over inheritance and avoid singletons or service locators.

Pull requests must explain behavior, architecture impact, tests, remaining
limitations, and any migration boundary.

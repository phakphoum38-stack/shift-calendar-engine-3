# SCE 3.0 Roadmap

| Phase | Scope | Status |
|---|---|---|
| 0 | Foundation, canonical schedule, DI, responsive shell, l10n, CI | In progress |
| 1 | Navigation surfaces, Dashboard, roster, employees, exchange, reports, settings | In progress |
| 2 | Employee directory, shift templates, manual roster builder, persistence, A4 grid | Next |
| 3 | Rule, conflict, policy, and preview engines | Planned |
| 4 | Shift exchange, approval, audit history, notifications | Planned |
| 5 | Payroll, OT, allowances, monthly summaries, exports | Planned |
| 6 | Excel and Google Sheets import, mapping, relationship engine, diff | Planned |
| 7 | Google Calendar preview, sync, retry, resume, history | Planned |
| 8 | Workspace, hospital/personal profiles, backup and restore | Planned |
| 9 | Integration tests, performance, security, offline support, release | Planned |

## Completion rule

A capability is complete only when its model, repository boundary, service or
use case, controller, UI, documentation, and focused tests are present and the
full CI matrix is green.

## Parallel production migration

The existing `phakphum-calendar` repository remains the active production
migration track. Proven clean components may move there only through reviewed
adapters and without resetting or deleting its legacy compatibility paths.

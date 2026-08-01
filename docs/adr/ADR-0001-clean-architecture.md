# ADR-0001: Use Clean Architecture boundaries

- Status: Accepted
- Date: 2026-07-31

## Context

Shift Calendar Engine must support Flutter user interfaces, local persistence, external integrations, reporting, and a future scheduling engine without coupling business rules to a specific framework or database.

## Decision

The project will separate responsibilities into these boundaries:

1. Domain: entities, value objects, repository contracts, and business rules.
2. Application: use cases and orchestration.
3. Infrastructure/Data: persistence and external service implementations.
4. Presentation: Flutter widgets and presentation controllers.

Dependencies must point inward. Domain code must not import Flutter, storage libraries, Google APIs, or presentation code.

Business rules must not be implemented in widgets. Presentation controllers may coordinate use cases but must not directly depend on concrete databases.

## Consequences

### Positive

- Business logic can be tested without Flutter.
- Storage and integrations can be replaced with lower migration risk.
- Scheduler and rule engines can later be reused by API, CLI, web, or desktop clients.
- Feature modules follow a consistent structure.

### Trade-offs

- More interfaces and files are required.
- Small changes may touch more than one layer.
- Contributors must understand dependency direction.

## Enforcement

Pull requests should pass formatting, static analysis, relevant tests, and architecture review before merge.

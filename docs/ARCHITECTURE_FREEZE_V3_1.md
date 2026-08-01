# Architecture Freeze v3.1

Status: Accepted

This document freezes the target architecture for the next implementation cycle. Changes to these boundaries require an Architecture Decision Record (ADR) and review before implementation.

## Product boundary

Shift Calendar Engine is a cross-platform workforce scheduling platform for workplaces, clinics, and hospitals. The current Flutter application remains operational while the platform grows through explicit boundaries rather than a rewrite.

## System topology

```text
Figma Design System
        |
        v
Flutter application
        |
        +-- design_system
        +-- workforce_core
        +-- rule_engine
        +-- scheduler_engine
        +-- report_engine
        +-- sync_engine
        |
        v
Repository contracts
        |
        +-- local/offline implementations
        +-- Laravel API implementation
                    |
                    v
              PostgreSQL
```

## Ownership rules

### Figma

Figma is the visual source of truth for foundations, semantic tokens, reusable components, responsive behavior, and developer handoff. Generated Figma-to-Flutter code is not a production dependency.

### Flutter

Flutter owns cross-platform presentation, offline workflows, local projections, input validation for user feedback, and orchestration of Dart business packages.

### Dart business packages

- `workforce_core`: stable workforce entities, value objects, repository contracts, and domain events.
- `rule_engine`: deterministic policy evaluation and violations.
- `scheduler_engine`: roster generation, optimization, and conflict detection.
- `report_engine`: canonical report models and deterministic projections.
- `sync_engine`: synchronization state, version checks, and conflict resolution policies.

Scheduling rules must not be duplicated in PHP. Laravel may validate integrity and authorization, but Dart engines remain the canonical owners of scheduling behavior.

### Laravel

Laravel owns authentication, authorization, organizations, API transport, server-side integrity validation, synchronization endpoints, notifications, integrations, and audit logging.

### PostgreSQL

PostgreSQL is the server-side system of record for shared and published data. Local Flutter storage is an offline cache and working copy, not an independent source of truth.

## Deployment boundary

The initial deployment is a modular monolith:

- one Flutter client codebase
- one Laravel API
- one PostgreSQL database
- Docker for reproducible environments
- GitHub Actions for CI/CD

Redis, microservices, Kubernetes, and AI services are deferred until a measurable requirement exists.

## Data conventions

- Public identifiers use UUIDs.
- API timestamps use ISO 8601.
- Server timestamps are stored in UTC.
- Business dates remain explicit local dates and are not silently converted to UTC instants.
- Shared mutable records include a version for optimistic concurrency.
- Deletion uses soft delete where auditability or synchronization requires it.
- Published schedules are immutable revisions; edits create a new draft revision.

## Dependency direction

```text
presentation -> application -> domain
infrastructure -------------> domain contracts
```

Domain packages must not import Flutter widgets, Laravel concepts, HTTP clients, database drivers, or platform plugins.

## Schedule lifecycle

```text
Draft -> Under review -> Approved -> Published -> Archived
```

Only a published revision is visible as the official roster. Draft editing never mutates a published revision in place.

## API conventions

- Base path: `/api/v1`
- Authentication and authorization are enforced server-side.
- Responses use a stable envelope with `data`, `message`, `errors`, and `meta`.
- Validation runs on both client and server.
- Version conflicts return an explicit conflict response; schedule conflicts are never resolved with silent last-write-wins behavior.

## Audit requirements

Important mutations record:

- actor
- organization
- action
- target type and identifier
- previous values where appropriate
- new values where appropriate
- timestamp
- request/device context when available

## Quality gates

Every production change must pass applicable formatting, static analysis, unit tests, widget tests, API tests, localization checks, and secret scanning.

## First proof of architecture

The Employee module is the first complete vertical slice:

```text
Figma component mapping
  -> Flutter UI
  -> workforce_core model
  -> repository contract
  -> Laravel `/api/v1/employees`
  -> PostgreSQL schema
  -> tests
```

Completion of this slice establishes the template for later Shift, Leave, Calendar, and Report modules.

# Employee Domain v3.1

Status: Draft for implementation

## Purpose

Define the stable domain contract for the first end-to-end vertical slice without coupling the model to Flutter widgets, local persistence, HTTP, Laravel, or PostgreSQL.

## Aggregate

`Employee` is the aggregate root for a worker who may participate in scheduling.

Required fields:

- `id`: UUID
- `organizationId`: UUID
- `employeeCode`: organization-scoped human-readable code
- `displayName`: primary name shown in rosters and reports
- `status`: active, inactive, or archived
- `version`: optimistic concurrency version
- `createdAt`: UTC instant
- `updatedAt`: UTC instant

Optional profile fields:

- `givenName`
- `familyName`
- `preferredName`
- `email`
- `phone`
- `departmentId`
- `positionId`
- `employmentType`
- `startDate`
- `endDate`
- `notes`

Scheduling profile fields must be modeled separately from identity/profile data so later rule changes do not destabilize the Employee aggregate.

## Invariants

1. `id` and `organizationId` must be valid UUIDs.
2. `employeeCode` is required, normalized, and unique within an organization.
3. `displayName` is required after trimming whitespace.
4. An archived employee cannot be assigned to a new schedule.
5. `endDate` cannot be before `startDate`.
6. `version` is a positive integer and increments after each accepted shared mutation.
7. Domain equality uses `id`; display names and employee codes are not identity.

## Status

```text
active   -> available for normal workforce workflows
inactive -> retained but unavailable for new assignments by default
archived -> historical record; read-only except restoration policy
```

Hard deletion is not part of the normal application workflow.

## Value objects

Recommended value objects:

- `EmployeeId`
- `OrganizationId`
- `EmployeeCode`
- `PersonName`
- `EmailAddress`
- `PhoneNumber`
- `RecordVersion`

Value objects validate and normalize at construction boundaries.

## Repository contract

```dart
abstract interface class EmployeeRepository {
  Future<Employee?> findById(EmployeeId id);

  Future<EmployeePage> list(EmployeeQuery query);

  Future<Employee> create(NewEmployee command);

  Future<Employee> update(
    Employee employee, {
    required RecordVersion expectedVersion,
  });

  Future<void> archive(
    EmployeeId id, {
    required RecordVersion expectedVersion,
  });
}
```

The domain contract must not expose JSON maps, SQL rows, HTTP responses, or Flutter state types.

## Application use cases

- List employees
- View employee details
- Create employee
- Edit employee
- Activate employee
- Deactivate employee
- Archive employee

Each use case performs authorization-independent domain validation and returns typed failures. Server authorization remains a Laravel responsibility.

## Failure model

Expected failures include:

- validation failure
- employee code already exists
- employee not found
- version conflict
- employee referenced by an operation that forbids the requested state change
- repository unavailable

Failures should be typed and localizable; domain code must not contain UI strings.

## API mapping

Resource path:

```text
GET    /api/v1/employees
POST   /api/v1/employees
GET    /api/v1/employees/{employeeId}
PATCH  /api/v1/employees/{employeeId}
DELETE /api/v1/employees/{employeeId}
```

`DELETE` represents archive/soft delete, not physical deletion.

Mutation requests include the expected record version. A stale version returns HTTP 409 with machine-readable conflict details.

## PostgreSQL mapping

Table: `employees`

Minimum columns:

- `id uuid primary key`
- `organization_id uuid not null`
- `employee_code varchar not null`
- `display_name varchar not null`
- profile columns as nullable values
- `status varchar not null`
- `version bigint not null default 1`
- `created_by uuid null`
- `updated_by uuid null`
- `created_at timestamptz not null`
- `updated_at timestamptz not null`
- `deleted_at timestamptz null`

Required unique index:

```text
unique (organization_id, employee_code) where deleted_at is null
```

## Figma to Flutter mapping

```text
Employee/List screen    <-> EmployeeListPage
Employee/Row             <-> EmployeeListTile
Employee/Card            <-> EmployeeCard
Employee/Form            <-> EmployeeForm
Employee/Status badge    <-> EmployeeStatusBadge
Foundation/Button        <-> AppFilledButton
Foundation/Text field    <-> AppTextField
Foundation/Empty state   <-> AppEmptyState
```

Feature widgets consume semantic design tokens and must not introduce independent colors, spacing scales, or typography systems.

## Acceptance criteria

- Domain model compiles without Flutter dependencies.
- Employee code uniqueness is enforced locally where possible and finally by PostgreSQL.
- Create, edit, list, detail, deactivate, and archive flows exist.
- Version conflict behavior is covered by tests.
- Thai and English labels and validation messages are supported.
- UI supports keyboard navigation and does not rely on color alone for status.
- API tests cover authorization, validation, uniqueness, soft delete, and conflict responses.

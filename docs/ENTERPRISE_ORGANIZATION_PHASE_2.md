# Enterprise Organization Phase 2

This branch introduces the application and repository boundaries required to evolve the employee directory into a multi-organization roster platform.

## Included

- Organization, branch, department, and team repository contracts
- Cross-entity organization hierarchy validation
- Tests for valid and invalid employee/team relationships
- Backward-compatible employee and department domain extensions from Phase 1

## Hierarchy

`Organization -> Branch -> Department -> Team -> Employee`

## Next work after CI passes

1. SharedPreferences repository implementations and schema migration
2. Application controllers and dependency composition
3. Organization management UI
4. Employee form updates and filters
5. Google Sheet and Calendar mapping integration

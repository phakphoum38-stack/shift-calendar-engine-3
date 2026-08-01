# Versioning Policy

Shift Calendar Engine follows Semantic Versioning using `MAJOR.MINOR.PATCH`.
The application build number follows the version after `+` in `pubspec.yaml`.

Example:

```yaml
version: 1.4.2+18
```

## Version increments

- **MAJOR**: incompatible changes to persisted data, public APIs, integration contracts, or supported workflows.
- **MINOR**: backward-compatible features, modules, reports, integrations, or scheduler capabilities.
- **PATCH**: backward-compatible fixes, security patches, documentation corrections, and internal improvements.
- **BUILD**: monotonically increasing package build identifier.

## Tags

Release tags use the `v` prefix and must match the semantic version in
`pubspec.yaml`:

```text
v1.4.2
```

Pre-release tags may use identifiers such as:

```text
v2.0.0-alpha.1
v2.0.0-beta.1
v2.0.0-rc.1
```

## Compatibility

A major version change is required when a release intentionally breaks any of
the following without an automatic migration:

- canonical schedule persistence
- employee or shift-template data contracts
- REST API contracts
- synchronization behavior
- supported import/export formats
- documented extension interfaces

## Source of truth

Before creating a release, the version in `pubspec.yaml`, the release heading in
`CHANGELOG.md`, and the Git tag must agree.

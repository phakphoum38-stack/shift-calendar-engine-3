# Conventional Commits

Commit subjects use this format:

```text
<type>(optional-scope): <description>
```

Supported types:

- `feat`: user-visible backward-compatible feature
- `fix`: defect correction
- `docs`: documentation only
- `test`: tests only
- `refactor`: internal change without a behavior change
- `perf`: performance improvement
- `build`: build system or dependency change
- `ci`: continuous-integration change
- `chore`: maintenance work
- `revert`: revert of an earlier commit
- `release`: release preparation

Examples:

```text
feat(employee): add department filter
fix(calendar): prevent duplicate synchronization
refactor(schedule): isolate validation policy
ci(release): publish tagged web artifact
```

Use imperative, lower-case descriptions without a trailing period. Keep each
commit focused. Explain motivation and migration details in the commit body when
needed.

Breaking changes must include `!` after the type or scope and a
`BREAKING CHANGE:` footer:

```text
feat(storage)!: introduce versioned schedule envelope

BREAKING CHANGE: existing unversioned schedule files require migration.
```

Pull request titles should follow the same format because squash merges commonly
use the pull request title as the resulting commit subject.

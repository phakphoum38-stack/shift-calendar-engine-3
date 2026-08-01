# Release Process

## 1. Prepare

1. Confirm the release branch is up to date with `main`.
2. Run:

```bash
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build web --release
```

3. Update `pubspec.yaml` with the new semantic version and build number.
4. Move completed entries from `Unreleased` into a dated release section in
   `CHANGELOG.md`.
5. Confirm migrations, persisted-data compatibility, security impact, and
   platform support.

## 2. Review

Open a pull request titled:

```text
release: prepare vX.Y.Z
```

The pull request must include:

- user-visible changes
- breaking changes and migrations
- test results
- known limitations
- rollback considerations

Merge only after required checks pass.

## 3. Tag

After the release pull request is merged into `main`:

```bash
git checkout main
git pull --ff-only
git tag -s vX.Y.Z -m "Shift Calendar Engine vX.Y.Z"
git push origin vX.Y.Z
```

An annotated unsigned tag may be used when signing has not yet been configured:

```bash
git tag -a vX.Y.Z -m "Shift Calendar Engine vX.Y.Z"
```

## 4. Automated release

Pushing a matching `v*.*.*` tag starts the release workflow. The workflow:

- verifies that the tag matches `pubspec.yaml`
- restores Flutter dependencies
- runs formatting, analysis, and tests
- builds the Flutter web release
- packages the web output
- creates a GitHub Release with generated notes
- uploads the packaged web artifact

## 5. Verify and recover

Verify the release page, artifact, application startup, localization, and the
monthly PDF workflow. Never move an existing release tag. For a defect, publish
a new patch release. For a compromised or invalid artifact, mark the release as
withdrawn and document the replacement version.

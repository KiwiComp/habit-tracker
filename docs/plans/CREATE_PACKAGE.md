# Creating a new package in this workspace

Follow these steps, in order, whenever a new package is added under `packages/`.

## 1. Scaffold the package

```sh
very_good create dart_package PACKAGE_NAME -o packages
```

Use `dart_package` for a pure-Dart package (no Flutter SDK dependency — e.g. a service client,
error tracking, business logic with no widgets). Use `flutter_package` instead if the package needs
Flutter APIs (widgets, `BuildContext`, anything from `package:flutter`).

This generates `packages/PACKAGE_NAME/` with a standard layout: `lib/PACKAGE_NAME.dart`,
`lib/src/PACKAGE_NAME.dart`, `test/`, `analysis_options.yaml`, `pubspec.yaml`, README, CI
workflows, etc. Leave the generated boilerplate class/test as-is unless asked to implement real
functionality — scaffolding and implementation are separate steps.

## 2. Align `analysis_options.yaml` with the root

Check the root `analysis_options.yaml` first, then mirror its **rule overrides** in the new
package's `analysis_options.yaml` — for example, if root disables `public_member_api_docs`:

```yaml
include: package:very_good_analysis/analysis_options.yaml

linter:
  rules:
    public_member_api_docs: false
```

Do **not** copy `include:` entries for lint packages the new package doesn't depend on (e.g.
`bloc_lint`, if this package has no `bloc` dependency) — an include with no matching dev
dependency breaks `dart analyze`. Only port over the rule overrides that apply regardless of
dependencies.

## 3. Add `CHANGELOG.md`

`very_good create` does not generate one. Add it at the package root:

```markdown
# Changelog

## 0.1.0+1

- Initial package scaffolding via `very_good create dart_package PACKAGE_NAME`.
```

Keep it current afterward: every future change to the package gets a new entry here plus a
matching version bump in `pubspec.yaml`, in the same change — never one without the other.

## 4. Add `resolution: workspace` to the package's `pubspec.yaml`

```yaml
environment:
  sdk: ^3.12.0

resolution: workspace
```

## 5. Register the package in the root `pubspec.yaml`

Add it to **both** places, in the same file:

```yaml
workspace:
  - packages/app_ui
  - packages/PACKAGE_NAME

dependencies:
  app_ui:
    path: packages/app_ui
  PACKAGE_NAME:
    path: packages/PACKAGE_NAME
```

## 6. Run `flutter pub get` at the root and resolve any conflicts

Pub workspaces resolve **one shared lockfile** across every member package. A pure-Dart package's
`dev_dependencies` can collide with what the Flutter app pins — most commonly, a `test: ^x.y.z`
constraint in the new package conflicting with the exact `test_api` version the Flutter SDK's
`flutter_test` requires. If `flutter pub get` fails with a `test_api` version conflict, find the
`test` version whose `test_api` dependency matches what `flutter_test` needs (check
`https://pub.dev/api/packages/test` for the version-to-`test_api` mapping) and narrow the new
package's `test` constraint to include that exact version. Re-run `flutter pub get` until it
resolves cleanly, then confirm with `dart analyze` in the new package (should report no issues).

# error_tracking package — setup instructions

This file is a blueprint for creating the `error_tracking` package, before it exists. Follow
`CREATE_PACKAGE.md` first for the general package-scaffolding steps, then this file for the
package's actual content.

## Scaffold choice

This package needs `FlutterError`, which lives in `package:flutter`. Scaffold it with the
**`flutter_package`** template, not `dart_package`:

```sh
very_good create flutter_package error_tracking -o packages
```

If it's ever scaffolded as a plain `dart_package` by mistake, the fix is: add
`flutter: { sdk: flutter }` under `dependencies` in its `pubspec.yaml`, add
`flutter: ^3.44.0` (or whatever the workspace's Flutter constraint is) under `environment`, and
use `flutter_test` instead of the plain `test` package under `dev_dependencies` — otherwise the
code below won't compile, and a plain `test` dependency will fight the Flutter app's `flutter_test`
over `test_api`'s version once both are resolved together in the workspace's shared lockfile.

## What to build: `ErrorTracking`

A static-only class exposing one entry point, `ErrorTracking.init`, that:
1. Sets `FlutterError.onError` to catch Flutter framework errors (widget build/layout errors —
   these are Flutter's own internal error channel, not general Dart exceptions).
2. Wraps the caller's app-startup logic in `runZonedGuarded`, to catch uncaught async errors
   anywhere else in the app (unawaited futures, errors in timers/callbacks with no listener).
3. Routes both to one internal reporter. For a first implementation with no chosen backend yet,
   just log to the console, gated behind a `debug` flag — but log through this one internal
   method, not inline, so a real backend (Sentry, Crashlytics, ...) can be substituted later by
   editing only this file, with zero change to any call site.

`lib/src/error_tracking.dart`:
```dart
import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Initializes error handling and runs the app inside it.
///
/// Covers two error sources: Flutter framework errors (widget build/layout
/// errors, via [FlutterError.onError]) and uncaught async errors anywhere
/// else in the app (via [runZonedGuarded]).
///
/// This currently only logs to the console in debug mode. Because callers
/// only ever go through [init], the internals can be swapped for a real
/// backend (Sentry, Crashlytics, ...) later without changing any call site.
abstract class ErrorTracking {
  /// Sets up error handling for [environment], then runs [appRunner].
  static Future<void> init({
    required bool debug,
    required String environment,
    required FutureOr<void> Function() appRunner,
  }) async {
    FlutterError.onError = (details) {
      _report(
        debug: debug,
        environment: environment,
        error: details.exceptionAsString(),
        stackTrace: details.stack,
      );
      FlutterError.presentError(details);
    };

    await runZonedGuarded(
      appRunner,
      (error, stackTrace) => _report(
        debug: debug,
        environment: environment,
        error: error.toString(),
        stackTrace: stackTrace,
      ),
    );
  }

  static void _report({
    required bool debug,
    required String environment,
    required String error,
    StackTrace? stackTrace,
  }) {
    if (!debug) return;
    developer.log(
      error,
      name: 'ErrorTracking ($environment)',
      stackTrace: stackTrace ?? StackTrace.empty,
    );
  }
}
```

Doc-comment gotcha: reference a parameter with `[paramName]` only from the doc comment directly
attached to the member that declares it (`init`'s own doc can say `[environment]`/`[appRunner]`).
Referencing a parameter name from the *class-level* doc comment (`[appRunner]`, `[debug]`) fails
to resolve, because the parameter isn't a symbol visible at that scope — use plain, unbracketed
text there instead.

`lib/error_tracking.dart` (the public barrel) just needs:
```dart
export 'src/error_tracking.dart';
```

## Test

The generated placeholder test instantiates the boilerplate class directly
(`expect(ErrorTracking(), isNotNull)`), which no longer compiles once `ErrorTracking` becomes an
abstract, static-only class. Replace it with a real behavioral test:

```dart
import 'package:error_tracking/error_tracking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorTracking.init', () {
    test('runs appRunner', () async {
      var didRun = false;

      await ErrorTracking.init(
        debug: false,
        environment: 'test',
        appRunner: () async {
          didRun = true;
        },
      );

      expect(didRun, isTrue);
    });
  });
}
```

## Finishing up

Once implemented: bump the package's `pubspec.yaml` version and add a `CHANGELOG.md` entry
describing the change (per `CREATE_PACKAGE.md`'s discipline), then verify with `dart analyze`
(should report no issues) and `flutter test` (should pass) from inside the package directory.

This package is not wired into the app's `bootstrap.dart` by this step — see `BOOTSTRAP.md` for
that.
